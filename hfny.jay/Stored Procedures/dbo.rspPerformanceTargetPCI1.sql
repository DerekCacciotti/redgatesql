
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130222
-- Description:	gets data for Performance Target report - PCI1. Primary Care Taker 1 breast feeding
-- exec [rspPerformanceTargetPCI1] '07/01/2012', '09/30/2012', <<table>>, null
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, 1
-- based on initial work on PTHD1 by dkhalsa
-- =============================================
create procedure [dbo].[rspPerformanceTargetPCI1]
(
    @StartDate      datetime,
    @EndDate		datetime,
    @tblPTCases		PTCases readonly,
    @ReportType		char(7)    = null
)

as
begin

	declare @TotalCases int = 0
	declare @TotalValidCases int = 0
	declare @NumberMeetingPT int = 0;
	
	with cteTotalCases
	as
	(
	select
		  ptc.HVCaseFK
		 , ptc.PC1ID
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
		select *
			from cteTotalCases
			where datediff(day,tcdob,@StartDate) <= 457
				 and datediff(day,tcdob,lastdate) >= 183
		)
	,
	cteInterval
	as
		(
			select HVCaseFK
					, max(Interval) as Interval
			from cteCohort
				inner join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays >= DueBy
			group by HVCaseFK
		)
	,
	cteExpectedForm
	as
		(
		select 'PCI1' as TargetCode
			  , c.HVCaseFK
			  , PC1ID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FollowUpDate as FormDate
			  --, cd.[DueBy]
			  --, cd.[Interval]
			  --, cd.[MaximumDue]
			  --, cd.[MinimumDue]
			  --, TimeBreastFed
			  , case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
			  , case when (FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , case when TimeBreastFed >= '04' then 1 else 0 end as MeetsStandard
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK
			inner join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca on ca.HVCaseFK = fu.HVCaseFK and FormType='FU' 
												and fu.FollowUpInterval = ca.FormInterval 
		)
	
	
	-- select * from cteCohort
	select * from cteExpectedForm
	

	--	begin
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
