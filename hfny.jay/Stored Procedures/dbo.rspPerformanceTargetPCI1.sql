
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
CREATE procedure [dbo].[rspPerformanceTargetPCI1]
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
		select c.HVCaseFK
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
	
	--,
	--cteValid
	--as
	--	(
	--	select distinct
	--				   coh.HVCaseFK
	--				  ,coh.TCIDPK
	--				  ,case when count(TCMedical.TCIDFK) > 0 then 1 else 0 end as valid
	--		from cteTotalCases coh
	--			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--		where TCItemDate between coh.TCDOB and dateadd(dd,365,coh.TCDOB)
	--		group by coh.HVCaseFK
	--				,coh.TCIDPK
	--	)
	--,
	----HD1: Meet 1 - count DTaP i.e. Diptheria Tetanus Pertussis shots for each child                              
	--cteChildrenBreastFed
	--as
	--	(
	--	select distinct
	--				   coh.HVCaseFK
	--				  ,coh.TCIDPK
	--				  ,count(coh.TCIDPK) as 'DTaP_1Y'
	--		from cteTotalCases coh
	--			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem and cmi.MedicalItemTitle = 'DTaP'
	--		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
	--		group by coh.HVCaseFK
	--				,coh.TCIDPK
	--	)

	----HD1: Meet 2 - count Polio i.e. Polio Immunization  shots for each child      
	--,
	--ctePolio_1YCount
	--as
	--	(
	--	select distinct
	--				   coh.HVCaseFK
	--				  ,coh.TCIDPK
	--				  ,count(coh.TCIDPK) as 'Polio_1Y'
	--		from cteTotalCases coh
	--			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem and cmi.MedicalItemTitle = 'Polio'
	--		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
	--		group by coh.HVCaseFK
	--				,coh.TCIDPK
	--	)
	--,
	--cteMeet
	--as 
	--	(
	--	-- HD1: number who meet Performance Target
	--	-- Inner join HD1: Meet 1 and HD1: Meet 2
	--	select dtap.HVCaseFK
	--		  ,dtap.TCIDPK
	--		  ,DTaP_1Y
	--		  ,Polio_1Y
	--		from cteDTaP_1YCount dtap
	--			inner join ctePolio_1YCount polio on dtap.hvcasefk = polio.hvcasefk and dtap.TCIDPK = polio.TCIDPK
	--		where DTaP_1Y >= 3
	--			 and Polio_1Y >= 2
	--	)
	--,
	--cteNotMeetingPT
	--as 
	--	(
	--	select
	--		  'HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age'
	--		  as ReportTitleText
	--		 ,PC1ID
	--		 ,TCDOB
	--		 ,'Missing Shots or Not on Time' as Reason
	--		 ,CurrentWorkerFullName
	--		 ,CurrentLevel
	--		 ,'' as Explanation

	--		from cteTotalCases cht
	--		where cht.HVCaseFK not in (select HVCaseFK
	--									   from cteMeet)
	--	)

	----SELECT * FROM cteNotMeetingPT

	---- add all these into a row in a table
	--insert into @tblPTReportTotalCases
	--		   (
	--		   NumberMeetingPT
	--		  ,TotalValidCases
	--		  ,TotalCases
	--		   )
	--	select
	--		  (select count(HVCaseFK)
	--			   from cteTotalCases) as NumberMeetingPT
	--		 ,(select count(HVCaseFK)
	--			   from cteValid) as TotalValidCases
	--		 ,(select count(HVCaseFK)
	--			   from cteMeet) as TotalCases

	---- --  rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'

	--if @ReportType = 'summary'

	--	begin
	--		set @TotalCases = (select NumberMeetingPT
	--							   from @tblPTReportTotalCases)
	--		set @TotalValidCases = (select TotalValidCases
	--									from @tblPTReportTotalCases)
	--		set @NumberMeetingPT = (select TotalCases
	--									from @tblPTReportTotalCases)

	--		if @TotalCases is null
	--			set @TotalCases = 0

	--		if @TotalValidCases is null
	--			set @TotalValidCases = 0

	--		if @NumberMeetingPT is null
	--			set @NumberMeetingPT = 0

	--		declare @tblPTReportSummary table(
	--			ReportTitleText [varchar](max),
	--			PercentageMeetingPT [varchar](200),
	--			NumberMeetingPT int,
	--			TotalValidCases int,
	--			TotalCases int
	--		)

	--		insert into @tblPTReportSummary ([ReportTitleText]
	--										,[PercentageMeetingPT]
	--										,[NumberMeetingPT]
	--										,[TotalValidCases]
	--										,[TotalCases])
	--			values (
	--				   'HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age'
	--				   ,' ('+CONVERT(varchar,round(COALESCE(cast(@NumberMeetingPT as float)*100/NULLIF(@TotalCases,0),0),0))+'%)'
	--				   ,@NumberMeetingPT
	--				   ,@TotalValidCases
	--				   ,@TotalCases
	--				   )
	--		select *
	--			from @tblPTReportSummary
	--	end
	--else
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
