SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD5. Target child well baby Medical Provider visits by 15 months>
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 5 ,'01/01/2012' ,'03/31/2012'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD5]
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
		  ,h.IntakeDate 
		from @tblPTCases ptc
			inner join HVCase h on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp on h.hvcasePK = cp.HVCaseFK -- AND cp.DischargeDate IS NULL
	)
	,
	
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
		where DATEADD(dd,365.25*1.25,TCDOB)  < lastdate -- 15 months 
		AND DATEADD(dd,365.25*1.75,TCDOB) > @StartDate  -- 21 months
		
	)	

	,
	cteWBV -- WellBabyVisit
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as WBVCount
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountWBV
		from cteCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,457,TCDOB)
				and MedicalItemTitle = 'WBV'
		group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)


	
	,
	cteWellBabyVisitCounts
	as
	(
		select 'HD1' as PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , NULL as FormDate	
			  , case when WBVCount IS NULL OR WBVCount = FormReviewedCountWBV -- # of shots = # of forms reveiwed
					then 1 
					else 0 
					end as FormReviewed				
			, 0 as FormOutOfWindow -- not out of window
			, 0 as FormMissing
			, case when WBVCount >= 5 then 1 else 0 end as MeetsStandard
	 from cteCohort coh
	 LEFT join cteWBV wbv on wbv.HVCaseFK = coh.HVCaseFK AND coh.TCIDPK = wbv.TCIDPK 
	 
	)
		
	
	SELECT * FROM cteWellBabyVisitCounts 	


end
GO
