SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130303
-- Description:	gets data for Performance Target report - FLC5. Education of Participants under 21 at 
--				Target Child's 6 months birthday
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- rspPerformanceTargetReportSummary 19, '10/01/2012', '12/31/2012'
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetFLC5]
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
				, HighestGrade
			from cteTotalCases tc
			inner join HVCase c on c.HVCasePK = tc.HVCaseFK
			inner join Intake i on i.HVCaseFK = c.HVCasePK
			inner join CommonAttributes ca on ca.HVCaseFK = c.HVCasePK and FormFK = IntakePK and FormType = 'IN-PC1'
			inner join PC P on P.PCPK = c.PC1FK
			where datediff(day,tc.tcdob,@StartDate) <= 365
				 and datediff(day,tc.tcdob,lastdate) >= 183
				 and HighestGrade < '03'
				 and (datediff(month,PCDOB,c.IntakeDate) / 12) < 21
		)
	,
	cteInterval
	as
		(
			select HVCaseFK					
					, max(Interval) as Interval
			from cteCohort
				inner join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays >= MaximumDue
				-- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
				where Interval <> (select dbd.Interval from codeDueByDates dbd where dbd.EventDescription = '18 month Follow Up') 
			group by HVCaseFK
		)
	,
	cteExpectedForm
	as
		(
		select 'FLC5' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FollowUpDate as FormDate
			  , case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
			  , case when (FollowUpPK is null or FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , EducationalEnrollment
			  , e.ProgramType
			from cteCohort c
			left outer join cteInterval i on c.HVCaseFK = i.HVCaseFK
			left outer join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca on ca.HVCaseFK = fu.HVCaseFK and FormType = 'FU-PC1' 
												and fu.FollowUpInterval = ca.FormInterval 
			left outer join Education e on e.FormType = 'FU' and e.FormFK = ca.FormFK
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
							EducationalEnrollment = '1' and ProgramType in ('01','02','03','06') 
						then 1 
						else 0 
						end as FormMeetsStandard
	from cteExpectedForm
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
