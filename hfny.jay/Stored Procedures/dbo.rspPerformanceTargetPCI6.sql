
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130228
-- Description:	gets data for Performance Target report - PCI6. Reducing Parental-Child Dysfunctional Interaction Stress (PCDI) in
--				highly stressed families by the target child's first birthday.
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetPCI6]
(
    @StartDate      datetime,
    @EndDate		datetime,
    @tblPTCases		PTCases readonly,
    @ReportType		char(7)    = null
)

as
begin

	with cteTotalCases
	as
	(
	select
		  ptc.HVCaseFK
		 , ptc.PC1ID
		 , ptc.OldID
		 , ptc.PC1FullName
		 , ptc.CurrentWorkerFK
		 , ptc.CurrentWorkerFullName
		 , ptc.CurrentLevelName
		 , ptc.ProgramFK
		 , ptc.TCIDPK
		 , ptc.TCDOB
		 , DischargeDate
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  datediff(day,ptc.tcdob,DischargeDate)
			  else
				  datediff(day,ptc.tcdob,@EndDate)
		  end as tcAgeDays
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  else
				  @EndDate
		  end as lastdate
		from @tblPTCases ptc
			inner join HVCase h on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK -- AND cp.DischargeDate IS NULL
	)
	,
	cteCohort
	as
		(
		select tc.*	
			from cteTotalCases tc
			inner join HVCase c on c.HVCasePK = tc.HVCaseFK
			inner join PSI P on P.HVCaseFK = c.HVCasePK
			where datediff(day,tc.tcdob,@StartDate) <= 548
				 and datediff(day,tc.tcdob,lastdate) >= 365
				 and PSIInterval = '00'
				 and ParentChildDysfunctionalInteractionValid = 1
				 and ParentChildDisfunctionalInteractionScore > 25
		)
	,
	--cteExpectedForm
	--as
	--	(
	--	select coh.HVCaseFK
	--			, PSIPK
	--		from cteCohort coh
	--		left outer join PSI P on coh.hvcaseFK = P.HVCaseFK 
	--		where PSIInterval = '00' -- in ('00','01','02')
	--	)
	--,
	cteMain
	as
		(select 'PCI5' as PTCode
					, coh.HVCaseFK
					, PC1ID
					, OldID
					, TCDOB
					, PC1FullName
					, CurrentWorkerFullName
					, CurrentLevelName
					, '1 year PSI' as FormName
					, PSIDateComplete as FormDate		
					, case when (PSIPK is not null and dbo.IsFormReviewed(PSIDateComplete,'PS',PSIPK) = 1) then 1 else 0 end as FormReviewed
					, case when (PSIPK is not null and PSIInWindow = 1) then 0 else 1 end as FormOutOfWindow
					, case when PSIPK is null then 1 else 0 end as FormMissing
					--, case when PSIPK is not null then 1 else 0 end as FormMeetsTarget
					, ParentChildDysfunctionalInteractionValid
					, ParentChildDisfunctionalInteractionScore
			  from cteCohort coh
			  left outer join PSI P on coh.HVCaseFK = P.HVCaseFK and PSIInterval = '02'
		)
	select PTCode
			  , HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FormName
			  , FormDate
			  , FormReviewed
			  , FormOutOfWindow
			  , FormMissing
			  , case when FormMissing = 0 and FormOutOfWindow = 0 and FormReviewed = 1 and
							ParentChildDysfunctionalInteractionValid = 1 and 
							ParentChildDisfunctionalInteractionScore <= 25 then 1 else 0 end as FormMeetsTarget
			  , case when FormReviewed = 0 then 'Form not reviewed by supervisor'
						when FormOutOfWindow = 1 then 'Form out of window'
						when FormMissing = 1 then 'Form missing'
						when ParentChildDysfunctionalInteractionValid <> 1 
							then 'PCDI score invalid'
						when ParentChildDisfunctionalInteractionScore > 25 
							then 'PCDI score above cutoff'
						else '' end as ReasonNotMeeting
	from cteMain
	-- order by OldID

--select * from cteTotalCases
	--select * from cteCohort	--	begin
	--		select ReportTitleText
	--			  ,PC1ID
	--			  ,TCDOB
	--			  ,Reason
	--			  ,CurrentWorker
	--			  ,LevelAtEndOfReport
	--			  ,Explanation
	--			from @tblPTReportNotMeetingPT
	--			order by CurrentWorker
	--					,PC1ID
	--	end
end
GO
