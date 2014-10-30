
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014-07-28
-- Description:	Gets all the data needed to display the Case Home Page
-- exec spGetAllDataForCaseHomePage 'DS90010007908'
-- =============================================
CREATE procedure [dbo].[spGetAllDataForCaseHomePage]
(
	@PC1ID char(13)
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	declare @HVCaseFK int
	set @HVCaseFK = (select HVCaseFK 
						from CaseProgram cp
	 					where PC1ID = @PC1ID
					);
					
	with ctePreAssessmentCount 
	as
		(
		  select count(PreassessmentPK) as CountOfPreassessments
			  from Preassessment pa
			  where HVCaseFK = @HVCaseFK
		)
	, ctePreIntakeCount
	as
		(
		select count(PreintakePK) as CountOfPreintakes
			from Preintake pi
			where HVCaseFK = @HVCaseFK
		)
	, cteServiceReferralCount
	as
		(
		select count(ServiceReferralPK) as CountOfServiceReferrals
			from ServiceReferral sr
			where HVCaseFK = @HVCaseFK
		)
	, cteHomeVisitLogCount
	as
		(
		select count(HVLogPK) as CountOfHomeVisitLogs
			from HVLog hl
			where HVCaseFK = @HVCaseFK
		)
	, ctePC1MedicalCount
	as
		(
		select count(PC1MedicalPK) as CountOfPC1MedicalForms
			from PC1Medical pm
			where HVCaseFK = @HVCaseFK
		)
	, cteFatherFigureCount
	as
		(
		select count(FatherFigurePK) as CountOfFatherFigures
			from FatherFigure ff
			where HVCaseFK = @HVCaseFK
		)
	, cteTCIDCount
	as
		(
		select count(TCIDPK) as CountOfTCIDs
			from TCID t
			where HVCaseFK = @HVCaseFK
		)
	, cteTCMedicalCount
	as
		(
		select count(TCMedicalPK) as CountOfTCMedicalForms
			from TCMedical tm
			where HVCaseFK = @HVCaseFK
		)
	, ctePSICount
	as
		(
		select count(PSIPK) as CountOfPSIs
			from PSI p
			where HVCaseFK = @HVCaseFK
		)
	, cteASQCount
	as
		(
		select count(ASQPK) as CountOfASQs
			from ASQ a
			where HVCaseFK = @HVCaseFK
		)
	, cteASQSECount
	as
		(
		select count(ASQSEPK) as CountOfASQSEs
			from ASQSE ase
			where HVCaseFK = @HVCaseFK
		)
	, cteFollowUpCount
	as
		(
		select count(FollowUpPK) as CountOfFollowUps
			from FollowUp fu
			where HVCaseFK = @HVCaseFK
		)
	-- the following 5 CTEs get the medical provider/facility information
	, cteMPFUP
	as 
		(--Step 1 : Get most recent followup data
		  select top 1
					FormDate as FUDate
				  , FormInterval as FUFormInterval
				  , PC1HasMedicalProvider
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType like 'FU'
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPPC
	as 
		(--Step 2: Get most recent medical / facility data from PC
		  select top 1
					FormDate as PCDate
				  , FormType as PCFormType
				  , FormInterval as PCFormInterval
				  , PC1MedicalProviderFK
				  , PC1MedicalFacilityFK
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType in ('CH', 'IN')
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPTCFU
	as 
		(--Step 3 : Get TC Has medical provider
		  select top 1
					TCHasMedicalProvider
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType = 'FU'
		  order by	FormDate desc
				  , CommonAttributesPK desc
		) 
	, cteMPTC
	as 
		(--Step 4: Get most recent medical / facility data from PC
		  select top 1
					FormDate as TCDate
				  , FormType as TCFormType
				  , FormInterval as TCFormInterval
				  , TCMedicalProviderFK
				  , TCMedicalFacilityFK
				  , ca.HVCaseFK as HVCaseFK
				  , CommonAttributesPK
		  from		CommonAttributes ca
		  where	HVCaseFK = @HVCaseFK
				and FormType in ('CH', 'IN', 'TC')
		  order by	FormDate desc
				  , CommonAttributesPK desc
		)
	, cteMedicalProviders_Facilities
	as
		(-- now bring together all the medical provider/facility info to determine what to display
			select case when FUDate is not null and PCDate is not null and FUDate >= PCDate 
						then 
							case when PC1HasMedicalProvider is not null and PC1MedicalProviderFK is not null 
								and PC1HasMedicalProvider = '1' and PC1MedicalProviderFK > 0
							then lmppc1.MPLastName + ', ' + lmppc1.MPLastName 
							end
						else 'None'
						end 
					as PC1MedicalProviderName
					
					, case when FUDate is not null and PCDate is not null and FUDate < PCDate 
						then 
							case when PC1MedicalProviderFK is not null and PC1MedicalProviderFK > 0
							then lmppc1.MPLastName + ', ' + lmppc1.MPLastName 
							end
						else 'None'
						end 
					as PC1MedicalFacilityName
			
			from cteMPPC mppc
			left outer join cteMPTC mptc on mptc.HVCaseFK = mppc.HVCaseFK
			left outer join cteMPTCFU mptcfu on mptcfu.HVCaseFK = mppc.HVCaseFK
			left outer join cteMPFUP mpfup on mpfup.HVCaseFK = mppc.HVCaseFK
			left outer join listMedicalProvider lmppc1 on lmppc1.listMedicalProviderPK = mppc.PC1MedicalProviderFK
			left outer join listMedicalProvider lmptc on lmptc.listMedicalProviderPK = mptc.TCMedicalProviderFK
			left outer join listMedicalFacility lmfpc1 on lmfpc1.listMedicalFacilityPK = mppc.PC1MedicalFacilityFK
			left outer join listMedicalFacility lmftc on lmftc.listMedicalFacilityPK = mptc.TCMedicalFacilityFK
		)
	, cteFormReview
	as
		(-- get all the data we need to render FormReview info
		select frfl.FormType
			 , frfl.FormFK
			 , frfl.IsReviewRequired
			 , frfl.IsFormReviewed
			 , frfl.IsApproved
		from  FormReviewFormList(@HVCaseFK) frfl
		)

--select * from cteFormReview

	, cteRawFormApprovals
	as
		(
			select distinct cf.codeFormAbbreviation as FormType
					, replace(replace(codeFormName, ' ', ''), '-', '') as FormName
					, coalesce(max(IsReviewRequired) over (partition by cf.codeFormAbbreviation), 0) as ReviewOn
					, coalesce(min(IsFormReviewed)  over (partition by cf.codeFormAbbreviation), 1) as FormsReviewed
			from cteFormReview fr
			right outer join codeForm cf on cf.codeFormAbbreviation = fr.FormType
			group by cf.codeFormAbbreviation, replace(replace(codeFormName, ' ', ''), '-', ''), IsReviewRequired, IsFormReviewed
			--select distinct cf.codeFormName
			--		, max(IsReviewRequired) over (partition by cf.codeFormName) as ReviewOn
			--		, min(IsFormReviewed) over (partition by cf.codeFormName) as FormsReviewed
			--from cteFormReview fr
			--inner join codeForm cf on cf.codeFormAbbreviation = fr.FormType
			--group by cf.codeFormName, IsReviewRequired, IsFormReviewed
		)

	--select * from cteRawFormApprovals
	
	, cteFormApprovals
	as
		(
			select HVScreen_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'SC')
				, HVScreen_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'SC')
				, Preassessment_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PA')
				, Preassessment_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PA')
				, Kempe_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'KE')
				, Kempe_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'KE')
				, Preintake_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PI')
				, Preintake_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PI')
				, IDContact_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'ID')
				, IDContact_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'ID')
				, TCID_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'TC')
				, TCID_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'TC')
				, Intake_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'IN')
				, Intake_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'IN')
				, TCMedical_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'TM')
				, TCMedical_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'TM')
				, HomeVisitLog_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'VL')
				, HomeVisitLog_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'VL')
				, ServiceReferral_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'SR')
				, ServiceReferral_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'SR')
				, ASQ_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'AQ')
				, ASQ_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'AQ')
				, ASQSE_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'AS')
				, ASQSE_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'AS')
				, FollowUp_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'FU')
				, FollowUp_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'FU')
				, PC1Medical_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PM')
				, PC1Medical_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PM')
				, Discharge_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'DS')
				, Discharge_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'DS')
				, LevelForm_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'LV')
				, LevelForm_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'LV')
				, ParentalStressIndex_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'PS')
				, ParentalStressIndex_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'PS')
				, FatherFigure_ReviewOn = (select ReviewOn from cteRawFormApprovals where FormType = 'FF')
				, FatherFigure_FormsReviewed = (select FormsReviewed from cteRawFormApprovals where FormType = 'FF')
		)
	
	select HVCasePK
			, PC1ID
			, hc.ScreenDate
			, hc.TCDOB
			, rtrim(pc.PCFirstName) + ' ' + rtrim(pc.PCLastName) as PC1Name
			, rtrim(ec.PCFirstName) + ' ' + rtrim(ec.PCLastName) as EmergencyContactName
			, LevelName as CurrentLevelname
			, hc.KempeDate
			, DischargeDate
			, rtrim(obp.PCFirstName) + ' ' + rtrim(obp.PCLastName) as OBPName
			, rtrim(t.TCFirstName) + ' ' + rtrim(t.TCLastName) as TargetChildName
			, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerName
			, hc.IntakeDate
			, rtrim(pc2.PCFirstName) + ' ' + rtrim(pc2.PCLastName) as PC2Name
			, cfca.FormDate as ChangeFormCommonAttributesFormDate
			, CountOfPreassessments
			, CountOfPreintakes
			, CountOfServiceReferrals
			, CountOfHomeVisitLogs
			, CountOfPC1MedicalForms
			, CountOfFatherFigures
			, CountOfTCIDs
			, CountOfTCMedicalForms
			, CountOfPSIs
			, CountOfASQs
			, CountOfASQSEs
			, CountOfFollowUps
			, mpf.PC1MedicalProviderName
			, mpf.PC1MedicalFacilityName
			--, cfr.FormType
			--, cfr.FormFK
			--, cfr.IsReviewRequired
			--, cfr.IsFormReviewed
			--, cfr.IsApproved
			, cfa.HVScreen_ReviewOn
			, cfa.HVScreen_FormsReviewed
			, cfa.Preassessment_ReviewOn
			, cfa.Preassessment_FormsReviewed
			, cfa.Kempe_ReviewOn
			, cfa.Kempe_FormsReviewed
			, cfa.Preintake_ReviewOn
			, cfa.Preintake_FormsReviewed
			, cfa.IDContact_ReviewOn
			, cfa.IDContact_FormsReviewed
			, cfa.TCID_ReviewOn
			, cfa.TCID_FormsReviewed
			, cfa.Intake_ReviewOn
			, cfa.Intake_FormsReviewed
			, cfa.TCMedical_ReviewOn
			, cfa.TCMedical_FormsReviewed
			, cfa.HomeVisitLog_ReviewOn
			, cfa.HomeVisitLog_FormsReviewed
			, cfa.ServiceReferral_ReviewOn
			, cfa.ServiceReferral_FormsReviewed
			, cfa.ASQ_ReviewOn
			, cfa.ASQ_FormsReviewed
			, cfa.ASQSE_ReviewOn
			, cfa.ASQSE_FormsReviewed
			, cfa.FollowUp_ReviewOn
			, cfa.FollowUp_FormsReviewed
			, cfa.PC1Medical_ReviewOn
			, cfa.PC1Medical_FormsReviewed
			, cfa.Discharge_ReviewOn
			, cfa.Discharge_FormsReviewed
			, cfa.LevelForm_ReviewOn
			, cfa.LevelForm_FormsReviewed
			, cfa.ParentalStressIndex_ReviewOn
			, cfa.ParentalStressIndex_FormsReviewed
			, cfa.FatherFigure_ReviewOn
			, cfa.FatherFigure_FormsReviewed
		from HVCase hc
		inner join CaseProgram cp on cp.HVCaseFK = hc.HVCasePK 
		inner join PC pc on pc.PCPK = hc.PC1FK
		left outer join PC ec on ec.PCPK = hc.CPFK
		left outer join PC obp on obp.PCPK = hc.OBPFK
		left outer join PC pc2 on pc2.PCPK = hc.PC2FK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
		--inner join HVScreen s on s.HVCaseFK = hc.HVCasePK
		inner join TCID t on t.HVCaseFK = hc.HVCasePK
		inner join Intake i on i.HVCaseFK = hc.HVCasePK
		left outer join CommonAttributes cfca on cfca.HVCaseFK = hc.HVCasePK and cfca.FormFK = cp.CaseProgramPK and cfca.FormType = 'CH'
		left outer join CommonAttributes pc1ca on pc1ca.HVCaseFK = hc.HVCasePK and pc1ca.FormFK = i.IntakePK and pc1ca.FormType = 'IN'
		left outer join CommonAttributes tcca on tcca.HVCaseFK = hc.HVCasePK and tcca.FormFK = t.TCIDPK and tcca.FormType = 'TC'
		inner join cteMedicalProviders_Facilities mpf on 1 = 1
		inner join ctePreAssessmentCount on 1 = 1
		inner join ctePreIntakeCount on 1 = 1
		inner join cteServiceReferralCount on 1 = 1
		inner join cteHomeVisitLogCount on 1 = 1
		inner join ctePC1MedicalCount on 1 = 1
		inner join cteFatherFigureCount on 1 = 1
		inner join cteTCIDCount on 1 = 1
		inner join cteTCMedicalCount on 1 = 1
		inner join ctePSICount on 1 = 1
		inner join cteASQCount on 1 = 1
		inner join cteASQSECount on 1 = 1
		inner join cteFollowUpCount on 1 = 1
		--inner join cteFormReview cfr on 1 = 1
		--inner join FormReview fr on fr.FormFK = cfr.FormFK and fr.FormType = cfr.FormType
		inner join cteFormApprovals cfa on 1=1
		--left outer join ctePC on ctePC.HVCaseFK = hc.HVCasePK
		--left outer join cteTC on cteTC.HVCaseFK = hc.HVCasePK
		--left outer join cteTCFU on cteTCFU.HVCaseFK = hc.HVCasePK
		--left outer join cteFUP on cteFUP.HVCaseFK = hc.HVCasePK
		where PC1ID = @PC1ID

end
GO
