SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130228
-- Description:	gets data for Performance Target report - PCI3. Reducing Parental Stress in highly stressed families 
--				by the target child's six month birthday
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetPCI3]
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
			where datediff(day,tc.tcdob,@StartDate) <= 365
				 and datediff(day,tc.tcdob,lastdate) >= 183
				 and PSIInterval = '00'
				 and PSITotalScoreValid = 1
				 and PSITotalScore > 85
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
		(select 'PCI3' as PTCode
					, coh.HVCaseFK
					, PC1ID
					, OldID
					, TCDOB
					, PC1FullName
					, CurrentWorkerFullName
					, CurrentLevelName
					, PSIDateComplete as FormDate		
					, case when (PSIPK is not null and dbo.IsFormReviewed(PSIDateComplete,'PS',PSIPK) = 1) then 1 else 0 end as FormReviewed
					, case when (PSIPK is not null and PSIInWindow = 1) then 0 else 1 end as FormOutOfWindow
					, case when PSIPK is null then 1 else 0 end as FormMissing
					--, case when PSIPK is not null then 1 else 0 end as FormMeetsStandard
					, PSITotalScoreValid
					, PSITotalScore
			  from cteCohort coh
			  left outer join PSI P on coh.HVCaseFK = P.HVCaseFK and PSIInterval = '01'
		)
	select PTCode
			  , HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FormDate
			  , FormReviewed
			  , FormOutOfWindow
			  , FormMissing
			  , case when FormMissing = 0 and FormOutOfWindow = 0 and FormReviewed = 1 and
						PSITotalScoreValid = 1 and PSITotalScore <= 85 then 1 else 0 end as FormMeetsStandard
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
