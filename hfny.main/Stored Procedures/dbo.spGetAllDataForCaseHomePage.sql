
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

	with cteHVCaseFK as 
		(
		  select HVCaseFK 
		  from CaseProgram cp
	 	  where PC1ID = @PC1ID
		)
	, ctePreAssessmentCount 
	as
		(
		  select count(PreassessmentPK) as CountOfPreassessments
		  from Preassessment pa
		  inner join cteHVCaseFK fk on fk.HVCaseFK = pa.HVCaseFK
		)
	, ctePreIntakeCount
	as
		(
		select count(PreintakePK) as CountOfPreintakes
			from Preintake pi
			inner join cteHVCaseFK fk on fk.HVCaseFK = pi.HVCaseFK
		)
	, cteServiceReferralCount
	as
		(
		select count(ServiceReferralPK) as CountOfServiceReferrals
			from ServiceReferral sr
			inner join cteHVCaseFK fk on fk.HVCaseFK = sr.HVCaseFK
		)
	, cteHomeVisitLogCount
	as
		(
		select count(HVLogPK) as CountOfHomeVisitLogs
			from HVLog hl
			inner join cteHVCaseFK fk on fk.HVCaseFK = hl.HVCaseFK
		)
	, ctePC1MedicalCount
	as
		(
		select count(PC1MedicalPK) as CountOfPC1MedicalForms
			from PC1Medical pm
			inner join cteHVCaseFK fk on fk.HVCaseFK = pm.HVCaseFK
		)
	, cteFatherFigureCount
	as
		(
		select count(FatherFigurePK) as CountOfFatherFigures
			from FatherFigure ff
			inner join cteHVCaseFK fk on fk.HVCaseFK = ff.HVCaseFK
		)
	, cteTCIDCount
	as
		(
		select count(TCIDPK) as CountOfTCIDs
			from TCID t
			inner join cteHVCaseFK fk on fk.HVCaseFK = t.HVCaseFK
		)
	, cteTCMedicalCount
	as
		(
		select count(TCMedicalPK) as CountOfTCMedicalForms
			from TCMedical tm
			inner join cteHVCaseFK fk on fk.HVCaseFK = tm.HVCaseFK
		)
	, ctePSICount
	as
		(
		select count(PSIPK) as CountOfPSIs
			from PSI p
			inner join cteHVCaseFK fk on fk.HVCaseFK = p.HVCaseFK
		)
	, cteASQCount
	as
		(
		select count(ASQPK) as CountOfASQs
			from ASQ a
			inner join cteHVCaseFK fk on fk.HVCaseFK = a.HVCaseFK
		)
	, cteASQSECount
	as
		(
		select count(ASQSEPK) as CountOfASQSEs
			from ASQSE ase
			inner join cteHVCaseFK fk on fk.HVCaseFK = ase.HVCaseFK
		)
	, cteFollowUpCount
	as
		(
		select count(FollowUpPK) as CountOfFollowUps
			from FollowUp fu
			inner join cteHVCaseFK fk on fk.HVCaseFK = fu.HVCaseFK
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
		  inner join cteHVCaseFK fk on fk.HVCaseFK = ca.HVCaseFK
		  where		FormType like 'FU'
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
		  inner join cteHVCaseFK fk on fk.HVCaseFK = ca.HVCaseFK
		  where		FormType in ('CH', 'IN')
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
		  inner join cteHVCaseFK fk on fk.HVCaseFK = ca.HVCaseFK
		  where		FormType = 'FU'
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
		  inner join cteHVCaseFK fk on fk.HVCaseFK = ca.HVCaseFK
		  where		FormType in ('CH', 'IN', 'TC')
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
	--, cteFormReview
	--as
	--	(-- get all the data we need to render FormReview info
	--	select * 
	--	from  FormReviewFormList(select HVCaseFK from cteHVCaseFK)
	--	)
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
		--left outer join ctePC on ctePC.HVCaseFK = hc.HVCasePK
		--left outer join cteTC on cteTC.HVCaseFK = hc.HVCasePK
		--left outer join cteTCFU on cteTCFU.HVCaseFK = hc.HVCasePK
		--left outer join cteFUP on cteFUP.HVCaseFK = hc.HVCasePK
		where PC1ID = @PC1ID

end
GO
