
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 13, 2013>
-- Description:	<gets you data for Performance Target report - HD1. Immunizations at one year>
-- exec [rspPerformanceTargetHD1] '07/01/2012','09/30/2012','01',null,null
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- mods by jrobohn 20130222 - clean up names, code and layout
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD1]
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
		where datediff(day,tcdob,@StartDate) <= 548
			 and datediff(day,tcdob,lastdate) >= 365
	)
	,
	cteImmunizationsPolio
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountPolio
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountPolio
		from cteCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
				and MedicalItemTitle = 'Polio'
		group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)
	
	,
	cteImmunizationsDTaP
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountDTaP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountDTaP
		from cteCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
				and MedicalItemTitle = 'DTaP'
				 group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	
	
	
	,
	cteImmunizationCounts
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
			  , case when ( (ImmunizationCountPolio is null or ImmunizationCountPolio = FormReviewedCountPolio) 
						AND (ImmunizationCountDTaP IS NULL OR ImmunizationCountDTaP = FormReviewedCountDTaP)) -- # of shots = # of forms reveiwed
					then 1 
					else 0 
					end as FormReviewed				
			, 0 as FormOutOfWindow -- not out of window
			, 0 as FormMissing
			, case when ((ImmunizationCountDTaP >= 3) AND (ImmunizationCountPolio >= 2)) then 1 else 0 end as MeetsStandard
	 from cteCohort coh
	 LEFT join cteImmunizationsPolio immPolio on immPolio.HVCaseFK = coh.HVCaseFK AND coh.TCIDPK = immPolio.TCIDPK 
	 LEFT join cteImmunizationsDTaP immDTaP on immDTaP.HVCaseFK = coh.HVCaseFK AND coh.TCIDPK = immDTaP.TCIDPK 
	)
		
	
	SELECT * FROM cteImmunizationCounts 

end
GO
