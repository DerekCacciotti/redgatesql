SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD3. Lead Assessment>
-- exec [rspPerformanceTargetHD3_bak20130301] '07/01/2012','09/30/2012','01',null,null
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- mods by jrobohn 20130222 - clean up names, code and layout
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD3_bak20130301]
(
    @StartDate      datetime,
    @EndDate      datetime,
    @tblPTCases  PTCases                           readonly
)

as
begin

	;
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
		 , cp.DischargeDate
		 ,case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  datediff(day,ptc.tcdob,DischargeDate)
			  else
				  datediff(day,ptc.tcdob,@EndDate)
		  end as tcAgeDays
		 ,case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  else
				  @EndDate
		  end as lastdate
		from @tblPTCases ptc
			inner join HVCase h on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp on h.hvcasePK = cp.HVCaseFK -- AND cp.DischargeDate IS NULL
	)
	,
	-- Report: HD1. Immunization at one year
	cteCohort
	as
	(
	select HVCaseFK
		  , PC1ID
		  , OldID		 
		  , PC1FullName
		  , CurrentWorkerFK
		  , CurrentWorkerFullName
		  , CurrentLevelName
		  , ProgramFK
		  , TCIDPK
		  , TCDOB
		  , DischargeDate
		  , tcAgeDays
		  , lastdate
		from cteTotalCases
		where datediff(day, tcdob + (.75 * 365.25), lastdate) > 0 -- Target children between 9 months and older
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
		select 'HD3' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FollowUpDate as FormDate
			  , case when dbo.IsFormReviewed(FollowUpDate,'FU',FollowUpPK) = 1 then 1 else 0 end as FormReviewed
			  , case when (FollowUpPK IS NOT NULL AND FUPInWindow = 1) then 0 else 1 end as FormOutOfWindow
			  , case when FollowUpPK is null then 1 else 0 end as FormMissing
			  , case when fu.LeadAssessment IS NOT NULL then 1 else 0 end as FormMeetsStandard
			 --, fu.LeadAssessment
			from cteCohort c
			inner join cteInterval i on c.HVCaseFK = i.HVCaseFK
			--inner join codeDueByDates cd on ScheduledEvent = 'Lead' 
			--								and i.Interval = cd.Interval 																					
											
									
			-- to get dueby, max, min (given interval)
			-- The following line gets those fu's that are due for the Interval
			-- note 'Interval' is the minimum interval 
			left outer join FollowUp fu on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			--left outer join CommonAttributes ca on ca.HVCaseFK = fu.HVCaseFK and FormType='FU' 
			--									and fu.FollowUpInterval = ca.FormInterval 
		)

	
	
	
	
	
	SELECT * FROM cteExpectedForm
	
	--SELECT * FROM cteInterval
	--SELECT * FROM cteCohort 
	
	--SELECT * FROM cteImmunizationCounts 
	--SELECT * FROM cteImmunizations
	-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	
	
		
	
	
	
end
GO
