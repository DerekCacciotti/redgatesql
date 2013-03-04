
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130302
-- Description:	gets data for Performance Target report - FLC1. Employment, Education and Training at 
--				target child's first birthday
-- exec [rspPerformanceTargetPCI1] '07/01/2012', '09/30/2012', <<table>>, null
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012'
-- rspPerformanceTargetReportSummary 19 ,'10/01/2012' ,'12/31/2012'	
-- testing siteFK below
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, 1
-- based on initial work on PTHD1 by dkhalsa
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetFLC1]
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
		select *
			from cteTotalCases
			where datediff(day,tcdob,@StartDate) <= 548
				 and datediff(day,tcdob,lastdate) >= 365
		)
	,
	cteInterval
	as
		(
			select HVCaseFK					
					, max(Interval) as Interval
			from cteCohort
				inner join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays >= DueBy
				-- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
				where Interval <> (select dbd.Interval from codeDueByDates dbd where dbd.EventDescription = '18 month Follow Up') 
			group by HVCaseFK
		)
	,
	cteExpectedForm
	as
		(
		select 'FLC1' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FollowUpDate as FormDate
			  , case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
			  , case when (FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , FormType
			  , PC1InHome
			  , PC2InHome
			  , OBPInHome
			  , IsCurrentlyEmployed
			  , EducationalEnrollment
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK
			inner join codeDueByDates cd on ScheduledEvent = 'Follow Up' 
											and i.Interval = cd.Interval 
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left outer join CommonAttributes ca on ca.HVCaseFK = fu.HVCaseFK and FormType like 'FU-%' 
												and fu.FollowUpInterval = ca.FormInterval 
		)
	,
	cteStandardElements
	as
		(
			select HVCaseFK
				, count(HVCaseFK) as PersonCount
				, sum(case when FormType = 'FU-PC1' and 
								(PC1InHome= '0' or 
									(PC1InHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1')))
								then 1
								else 0
								end)
						as PC1Score
				, sum(case when FormType = 'FU-PC2' and 
								(PC2InHome= '0' or 
									(PC2InHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1')))
								then 1
								else 0
								end)
						as PC2Score
				, sum(case when FormType = 'FU-OBP' and 
								(OBPInHome= '0' or 
									(OBPInHome = '1' and 
										(IsCurrentlyEmployed = '1' or EducationalEnrollment = '1')))
								then 1
								else 0
								end)
						as OBPScore
			from cteExpectedForm
			group by HVCaseFK
		)
	,
	cteDistinctFollowUps
	as
		(
		select distinct PTCode
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
			from cteExpectedForm
		)
	,
	cteMain 
	as
		(
		select PTCode
				, dfu.HVCaseFK
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
				, case when PersonCount = (PC1Score + PC2Score + OBPScore) 
						then 1
						else 0
						end
					as FormMeetsStandard
			from cteDistinctFollowUps dfu
			inner join cteStandardElements se on se.HVCaseFK = dfu.HVCaseFK
		)
	
	select * from cteMain

	-- select * from cteExpectedForm
	-- select * from cteCohort
	--select PTCode
	--		, HVCaseFK
	--		, PC1ID
	--		, OldID
	--		, TCDOB
	--		, PC1FullName
	--		, CurrentWorkerFullName
	--		, CurrentLevelName
	--		, FormDate
	--		, FormReviewed
	--		, FormOutOfWindow
	--		, FormMissing
	--		, case when (TimeBreastFed >= '04' and FormReviewed = 1 and FormOutOfWindow = 0 and FormMissing = 0) then 1 else 0 end as FormMeetsStandard
	--from cteExpectedForm
	-- order by OldID

end
GO
