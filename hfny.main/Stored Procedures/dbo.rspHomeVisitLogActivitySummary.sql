SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary
-- [rspHomeVisitLogActivitySummary] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- [rspHomeVisitLogActivitySummary] 1,'10/01/2013','04/30/2014',null,'','N','N'
-- =============================================
CREATE procedure [dbo].[rspHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@ProgramFK int = null
   , @StartDt datetime
   , @EndDt datetime
   , @workerfk int = null
   , @pc1id varchar(13) = ''
   , @showWorkerDetail char(1) = 'N'
   , @showPC1IDDetail char(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null
	)

--DECLARE	@programfk INT = 6
--DECLARE @StartDt DATETIME = '01/01/2011'
--DECLARE @EndDt DATETIME = '01/01/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = NULL
--DECLARE @showWorkerDetail CHAR(1) = 'Y'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'
as --DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '09/30/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
						else @SiteFK
					end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	with	base1
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , x = sum(case substring(VisitType, 4, 1)
									  when '1' then 0
									  else 1
									end)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1ID = '' then cp.PC1ID
												else @pc1ID
										   end
							-- and cp.ProgramFK = @programfk
							and case when @SiteFK = 0 then 1
									 when wp.SiteFK = @SiteFK then 1
									 else 0
								end = 1
				  group by	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end
				 ) ,
			base11
			  as (select	FSWFK
						  , PC1ID
						  , case when x = 0 then 1
								 else x
							end x
				  from		base1
				 ) ,
			base2
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
--,count(DISTINCT a.HVCaseFK) [UniqueFamilies],
						  , count(distinct (case when substring(VisitType, 4, 1) <> '1' then a.HVCaseFK
												 else null
											end)) [UniqueFamilies]
						  , sum(case substring(VisitType, 4, 1) 
								  when '1' then 1
								  else 0
								end) [Attempted]
						  , sum(case substring(VisitType, 4, 1)
								  when '1' then 0
								  else 1
								end) [CompletedVisit]
						  , sum(case when substring(VisitType, 4, 1) <> '1'
										  and isnull(h.TCDOB, h.EDC) > a.VisitStartTime then 1
									 else 0
								end) [CompletedPrenatalVisit]
						  , sum(case when (SUBSTRING(a.VisitType, 1, 1) = '1' 
											   OR SUBSTRING(a.VisitType, 2, 1) = '1'
											   OR SUBSTRING(a.VisitType, 3, 1) = '1')
											   AND substring(a.VisitType, 5, 1) = '0' THEN 1
											 else 0
										end) [InHome]
						  , sum(case when substring(a.VisitType, 5, 1) = '1' 
											 AND  SUBSTRING(a.VisitType, 1, 3) = '000' THEN 1
											 else 0
										end) [OutOfHome]
						  , sum(case when (SUBSTRING(a.VisitType, 1, 1) = '1' 
											   OR SUBSTRING(a.VisitType, 2, 1) = '1'
											   OR SUBSTRING(a.VisitType, 3, 1) = '1')
											   AND substring(a.VisitType, 5, 1) = '1' then 1
											 else 0
										end) [BothInAndOutHome]
						  , sum(VisitLengthHour * 60 + VisitLengthMinute) [AvgMinuteForCompletedVisit]
						  , sum(case when PC1Participated = 1 then 1
									 else 0
								end) * 100 [PC1Participated]
						  , sum(case when PC2Participated = 1 then 1
									 else 0
								end) * 100 [PC2Participated]
						  , sum(case when OBPParticipated = 1 then 1
									 else 0
								end) * 100 [OBPParticipated]
						  , sum(case when FatherFigureParticipated = 1 then 1
									 else 0
								end) * 100 [FatherFigureParticipated]
						  , sum(case when NonPrimaryFSWParticipated = 1 then 1
									 else 0
								end) * 100 [NonPrimaryFSWParticipated]
						  , sum(case when FatherAdvocateParticipated > 0 then 1
									 else 0
								end) * 100 [FatherAdvocateParticipated]
						  , sum(case when TCParticipated = 1 then 1
									 else 0
								end) * 100 [TCParticipated]
						  , sum(case when GrandParentParticipated = 1 then 1
									 else 0
								end) * 100 [GrandParentParticipated]
						  , sum(case when SiblingParticipated = 1 then 1
									 else 0
								end) * 100 [SiblingParticipated]
						  , sum(case when HVSupervisorParticipated = 1 then 1
									 else 0
								end) * 100 [HVSupervisorParticipated]
						  , sum(case when SupervisorObservation = 1 then 1
									 else 0
								end) * 100 [SupervisorObservation]
						  , sum(case when OtherParticipated = 1 then 1
									 else 0
								end) * 100 [OtherParticipated]
						  , SUM(CASE WHEN HouseholdChangesNew = 1 THEN 1 
									ELSE 0 END) * 100 AS HouseholdChangesNew
						  , SUM(CASE WHEN HouseholdChangesLeft = 1 THEN 1 
									ELSE 0 END) * 100 AS HouseholdChangesLeft
						  , SUM(CASE WHEN HouseholdChangesNew = 1 
										  OR HouseholdChangesLeft = 1 THEN 1 
									ELSE 0 END) * 100 AS HouseholdChanges1
						  ,
-- Reflective strategies
						  sum(case WHEN RSATP = 1 then 1
									 else 0
								end) * 100 RSATP
						  , sum(case when RSSATP = 1 then 1
									 else 0
								end) * 100  RSSATP
						  , sum(case when RSFFF = 1 then 1
									 else 0
								end) * 100  RSFFF
						  , sum(case when RSEW = 1 then 1
									 else 0
								end) * 100  RSEW
						  , sum(case when RSNormalizing = 1 then 1
									 else 0
								end) * 100  RSNormalizing
						  , sum(case when RSSFT = 1 then 1
									 else 0
								end) * 100  RSSFT
						  , sum(case when RSATP = 1 OR
										  RSSATP = 1 OR
										  RSFFF = 1 OR
										  RSEW = 1 OR
										  RSNormalizing = 1 OR
										  RSSFT = 1 then 1
									 else 0
								end) * 100  RS1
						  ,

-- child development
							sum(case when CDChildDevelopment = 1 then 1
									 else 0
								end) * 100 [CDChildDevelopment]
						  , sum(case when CDToys = 1 then 1
									 else 0
								end) * 100 [CDToys]
						  , sum(case when CDParentConcerned > 0 then 1
									 else 0
								end) * 100 [CDParentConcerned]
						  , sum(case when CDSocialEmotionalDevelopment > 0 then 1
									 else 0
								end) * 100 [CDSocialEmotionalDevelopment]
						  , sum(case when CDFollowUpEIServices > 0 then 1
									 else 0
								end) * 100 [CDFollowUpEIServices]
						  , sum(case when CDOther = 1 then 1
									 else 0
								end) * 100 [CDOther]
						  , sum(case when CDChildDevelopment = 1
										  or CDToys = 1
										  or CDOther = 1 
										  OR CDParentConcerned = 1
										  OR CDSocialEmotionalDevelopment = 1
										  OR CDFollowUpEIServices = 1 then 1
									 else 0
								end) * 100 [CD1]
						  ,

-- parent/child interaction
							sum(case when PCChildInteraction = 1 then 1
									 else 0
								end) * 100 [PCChildInteraction]
						  , sum(case when PCChildManagement = 1 then 1
									 else 0
								end) * 100 [PCChildManagement]
						  , sum(case when PCFeelings = 1 then 1
									 else 0
								end) * 100 [PCFeelings]
						  , sum(case when PCStress = 1 then 1
									 else 0
								end) * 100 [PCStress]
						  , sum(case when PCBasicNeeds = 1 then 1
									 else 0
								end) * 100 [PCBasicNeeds]
						  , sum(case when PCShakenBaby = 1 then 1
									 else 0
								end) * 100 [PCShakenBaby]
						  , sum(case when PCShakenBabyVideo = 1 then 1
									 else 0
								end) * 100 [PCShakenBabyVideo]
						  , sum(case when PCTechnologyEffects > 0 then 1
									 else 0
								end) [PCTechnologyEffects]
						  , sum(case when PCOther = 1 then 1
									 else 0
								end) * 100 [PCOther]
						  , sum(case when PCChildInteraction = 1
										  or PCChildManagement = 1
										  or PCFeelings= 1
										  or PCStress = 1
										  or PCBasicNeeds = 1
										  or PCShakenBaby = 1
										  or PCShakenBabyVideo = 1
										  OR PCTechnologyEffects = 1
										  or PCOther = 1 then 1
									 else 0
								end) * 100 [PC1]
						  ,
-- Curriculum - primary
							  sum(Case WHEN (CurriculumPartnersHealthyBaby IS NULL 
								OR CurriculumPartnersHealthyBaby = 0) THEN 0 ELSE 1 END) * 100
								CurriculumPartnersHealthyBaby
        
							, sum(Case WHEN (CurriculumPAT IS NULL 
								OR CurriculumPAT = 0) THEN 0 ELSE 1 END) * 100
								CurriculumPAT

							, sum(Case WHEN (CurriculumSanAngelo IS NULL 
								OR CurriculumSanAngelo = 0) THEN 0 ELSE 1 END) * 100
								CurriculumSanAngelo
       
							, sum(Case WHEN (CurriculumGrowingGreatKids IS NULL 
								OR CurriculumGrowingGreatKids = 0) THEN 0 ELSE 1 END) * 100
								CurriculumGrowingGreatKids

							, SUM(CASE WHEN CurriculumPartnersHealthyBaby = 1
											OR CurriculumPAT = 1
											OR CurriculumSanAngelo = 1
											OR CurriculumGrowingGreatKids = 1
											THEN 1 ELSE 0 END) * 100
								CurriculumPrimary1

--Curriculum - supplemental

							, sum(Case WHEN (CurriculumParentsForLearning IS NULL 
								OR CurriculumParentsForLearning = 0) THEN 0 ELSE 1 END) * 100
								CurriculumParentsForLearning

							, sum(Case WHEN (CurriculumHelpingBabiesLearn IS NULL 
								OR CurriculumHelpingBabiesLearn = 0) THEN 0 ELSE 1 END) * 100
								CurriculumHelpingBabiesLearn
    
							, sum(Case WHEN (Curriculum247Dads IS NULL 
								OR Curriculum247Dads = 0) THEN 0 ELSE 1 END) * 100
								Curriculum247Dads

							, sum(Case WHEN (CurriculumBoyz2Dads IS NULL 
								OR CurriculumBoyz2Dads = 0) THEN 0 ELSE 1 END) * 100
								CurriculumBoyz2Dads

							, sum(Case WHEN (CurriculumGreatBeginnings IS NULL 
							   OR CurriculumGreatBeginnings = 0) THEN 0 ELSE 1 END) * 100
							   CurriculumGreatBeginnings

							, sum(Case WHEN (CurriculumInsideOutDads IS NULL 
								OR CurriculumInsideOutDads = 0) THEN 0 ELSE 1 END) * 100
								CurriculumInsideOutDads

							, sum(Case WHEN (CurriculumMomGateway IS NULL 
								OR CurriculumMomGateway = 0) THEN 0 ELSE 1 END) * 100
								CurriculumMomGateway

							, sum(Case WHEN (CurriculumPATFocusFathers IS NULL 
								OR CurriculumPATFocusFathers = 0) THEN 0 ELSE 1 END) * 100
								CurriculumPATFocusFathers

							, sum(Case WHEN (CurriculumOther IS NULL 
								OR CurriculumOther = 0) THEN 0 ELSE 1 END) * 100
								CurriculumOther

							, sum(Case WHEN (CurriculumOtherSupplementalInformation IS NULL 
								OR CurriculumOtherSupplementalInformation = 0) THEN 0 ELSE 1 END) * 100
								CurriculumOtherSupplementalInformation

							, sum(Case WHEN ((CurriculumPartnersHealthyBaby IS NULL OR CurriculumPartnersHealthyBaby = 0) AND 
								(CurriculumPAT IS NULL OR CurriculumPAT = 0) AND
								(CurriculumSanAngelo IS NULL OR CurriculumSanAngelo = 0) AND
								(CurriculumParentsForLearning IS NULL OR CurriculumParentsForLearning = 0) AND
								(CurriculumHelpingBabiesLearn IS NULL OR CurriculumHelpingBabiesLearn = 0) AND
								(CurriculumGrowingGreatKids IS NULL OR CurriculumGrowingGreatKids = 0) AND
								(Curriculum247Dads IS NULL OR Curriculum247Dads = 0) AND
								(CurriculumBoyz2Dads IS NULL OR CurriculumBoyz2Dads = 0) AND 
								(CurriculumInsideOutDads IS NULL OR CurriculumInsideOutDads = 0) AND
								(CurriculumMomGateway IS NULL OR CurriculumMomGateway = 0) AND
								(CurriculumPATFocusFathers IS NULL OR CurriculumPATFocusFathers = 0) AND 
								(CurriculumGreatBeginnings IS NULL OR CurriculumGreatBeginnings = 0) AND 
								(CurriculumOtherSupplementalInformation IS NULL OR CurriculumOtherSupplementalInformation = 0) AND
								(CurriculumOther IS NULL OR CurriculumOther = 0)
								) THEN 1 ELSE 0 END) * 100 CurriculumNone

							, SUM(CASE WHEN CurriculumParentsForLearning = 1 OR
								CurriculumHelpingBabiesLearn = 1 OR
								Curriculum247Dads = 1 OR
								CurriculumBoyz2Dads = 1 OR 
								CurriculumInsideOutDads = 1 OR
								CurriculumMomGateway = 1 OR
								CurriculumPATFocusFathers = 1 OR 
								CurriculumGreatBeginnings = 1 OR 
								CurriculumOtherSupplementalInformation = 1 OR
								CurriculumOther = 1 THEN 1 
								ELSE 0 END) * 100 CurriculumSupplemental1
-- Target Child Health
						  , SUM(CASE WHEN a.HealthTCMedicalWellBabyAppointments = 1 THEN 1
									ELSE 0 END) * 100 HealthTCMedicalWellBabyAppointments
						  , SUM(CASE WHEN a.HealthTCImmunizations = 1 THEN 1
									ELSE 0 END) * 100 HealthTCImmunizations
						  , SUM(CASE WHEN a.HealthTCERVisits = 1 THEN 1
									ELSE 0 END) * 100 HealthTCERVisits
						  , SUM(CASE WHEN a.HealthTCMedicalWellBabyAppointments = 1 OR 
										  a.HealthTCImmunizations = 1 OR
                                          a.HealthTCERVisits = 1
										  THEN 1
								ELSE 0 END) * 100 HealthTC1							
-- Parents or Other Caregiver Health
						  , SUM(CASE WHEN a.HealthPC1MedicalPrenatalAppointments = 1 THEN 1
									ELSE 0 END) * 100 HealthPC1MedicalPrenatalAppointments
						  , SUM(CASE WHEN a.HealthPC1ERVisits = 1 THEN 1
									ELSE 0 END) * 100 HealthPC1ERVisits
						  , SUM(CASE WHEN a.HealthPC1MedicalPrenatalAppointments = 1 OR
                                          a.HealthPC1ERVisits = 1
										  THEN 1
								ELSE 0 END) * 100 HealthPC1		
-- Health care
						  , SUM(case when HCGeneral = 1 then 1
									 else 0
								end) * 100 [HCGeneral]
						  , sum(case when HCChild = 1 then 1
									 else 0
								end) * 100 [HCChild]
						  , sum(case when HCDental = 1 then 1
									 else 0
								end) * 100 [HCDental]
						  , sum(case when HCFeeding = 1 then 1
									 else 0
								end) * 100 [HCFeeding]
						  , sum(case when HCLaborDelivery = 1 then 1
									 else 0
								end) * 100 [HCLaborDelivery]
						  , sum(case when HCBreastFeeding = 1 then 1
									 else 0
								end) * 100 [HCBreastFeeding]
						  , sum(case when HCNutrition = 1 then 1
									 else 0
								end) * 100 [HCNutrition]
						  , sum(case when HCFamilyPlanning = 1 then 1
									 else 0
								end) * 100 [HCFamilyPlanning]
						  , sum(case when HCProviders = 1 then 1
									 else 0
								end) * 100 [HCProviders]
						  , sum(case when HCFASD = 1 then 1
									 else 0
								end) * 100 [HCFASD]
						  , sum(case when HCSexEducation = 1 then 1
									 else 0
								end) * 100 [HCSexEducation]
						  , sum(case when HCPrenatalCare = 1 then 1
									 else 0
								end) * 100 [HCPrenatalCare]
						  , sum(case when HCMedicalAdvocacy = 1 then 1
									 else 0
								end) * 100 [HCMedicalAdvocacy]
						  , sum(case when HCSafety = 1 then 1
									 else 0
								end) * 100 [HCSafety]
						  , sum(case when HCSmoking = 1 then 1
									 else 0
								end) * 100 [HCSmoking]
						  , sum(case when HCSIDS = 1 then 1
									 else 0
								end) * 100 [HCSIDS]
						  , sum(case when HCOther = 1 then 1
									 else 0
								end) * 100 [HCOther]
						  , sum(case when HCGeneral = 1
										  or HCChild = 1
										  or HCDental = 1
										  or HCFeeding = 1
										  OR HCLaborDelivery = 1
										  or HCBreastFeeding = 1
										  or HCNutrition = 1
										  or HCFamilyPlanning = 1
										  or HCProviders = 1
										  or HCFASD = 1
										  or HCSexEducation = 1
										  or HCPrenatalCare = 1
										  or HCMedicalAdvocacy = 1
										  or HCSafety = 1
										  or HCSmoking = 1
										  or HCSIDS = 1
										  or HCOther = 1 then 1
									 else 0
								end) * 100 [HC1]
						  ,
-- family functioning
							sum(case when FFDomesticViolence = 1 then 1
									 else 0
								end) * 100 [FFDomesticViolence]
						  , sum(case when FFFamilyRelations = 1 then 1
									 else 0
								end) * 100 [FFFamilyRelations]
						  , sum(case when FFSubstanceAbuse = 1 then 1
									 else 0
								end) * 100 [FFSubstanceAbuse]
						  , sum(case when FFMentalHealth = 1 then 1
									 else 0
								end) * 100 [FFMentalHealth]
						  , sum(case when FFDevelopmentalDisabilities = 1 then 1
									 else 0
								end) * 100 [FFDevelopmentalDisabilities]
						  , sum(case when FFImmigration = 1 then 1
									 else 0
								end) * 100 [FFImmigration]
						  , sum(case when FFCommunication = 1 then 1
									 else 0
								end) * 100 [FFCommunication]
						  , sum(case when FFChildProtectiveIssues = 1 then 1
									 else 0
								end) * 100 [FFChildProtectiveIssues]
						  , sum(case when FFOther = 1 then 1
									 else 0
								end) * 100 [FFOther]
						  , sum(case when FFDomesticViolence = 1
										  or FFFamilyRelations = 1
										  or FFSubstanceAbuse = 1
										  or FFMentalHealth = 1
										  OR FFDevelopmentalDisabilities = 1
										  OR FFImmigration = 1
										  or FFCommunication = 1
										  OR FFChildProtectiveIssues = 1
										  or FFOther = 1 then 1
									 else 0
								end) * 100 [FF1]
						  ,
-- self sufficiency
							SUM(CASE WHEN a.SSHomeEnvironment = 1 THEN 1
									ELSE 0 END) * 100 SSHomeEnvironment
						  , SUM(case when SSCalendar = 1 then 1
									 else 0
								end) * 100 [SSCalendar]
						  , sum(case when SSHousekeeping = 1 then 1
									 else 0
								end) * 100 [SSHousekeeping]
						  , sum(case when SSTransportation = 1 then 1
									 else 0
								end) * 100 [SSTransportation]
						  , SUM(CASE WHEN a.SSChildWelfareServices = 1 THEN 1
									ELSE 0 END) * 100 SSChildWelfareServices
						  , sum(case when SSEmployment = 1 then 1
									 else 0
								end) * 100 [SSEmployment]
						  , sum(case when SSMoneyManagement = 1 then 1
									 else 0
								end) * 100 [SSMoneyManagement]
						  , sum(case when SSChildCare = 1 then 1
									 else 0
								end) * 100 [SSChildCare]
						  , sum(case when SSProblemSolving = 1 then 1
									 else 0
								end) * 100 [SSProblemSolving]
						  , sum(case when SSEducation = 1 then 1
									 else 0
								end) * 100 [SSEducation]
						  , sum(case when SSJob = 1 then 1
									 else 0
								end) * 100 [SSJob]
						  , sum(case when SSOther = 1 then 1
									 else 0
								end) * 100 [SSOther]
						  , sum(case when SSCalendar = 1
										  or SSHousekeeping = 1
										  or SSTransportation = 1
										  or SSEmployment = 1
										  or SSMoneyManagement = 1
										  or SSChildCare = 1
										  or SSProblemSolving = 1
										  or SSEducation = 1
										  or SSJob = 1
										  or SSOther = 1 then 1
									 else 0
								end) * 100 [SS1]
						  ,
-- crisis intervention
							sum(case when CIProblems = 1   then 1
									 else 0
								end) * 100 [CIProblems]
						  , sum(case when CIOther = 1   then 1
									 else 0
								end) * 100 [CIOther]
						  , sum(case when CIProblems = 1  
										  or CIOther = 1   then 1
									 else 0
								end) * 100 [CI1]
						  ,
--Referrals
						  SUM(CASE WHEN a.ReferralsMade = 1 THEN 1
								ELSE 0 END) * 100 [ReferralsMade]
						, SUM(CASE WHEN a.ReferralsFollowUp = 1 THEN 1
								ELSE 0 END) * 100 [ReferralsFollowUp]
						, SUM(CASE WHEN a.ReferralsMade = 1 
										OR a.ReferralsFollowUp = 1 THEN 1 
								ELSE 0 END) * 100 [Referrals1]
						,
-- program activities
							sum(case when PAForms = 1   then 1
									 else 0
								end) * 100 [PAForms]
						  , sum(case when PAVideo = 1   then 1
									 else 0
								end) * 100 [PAVideo]
						  , sum(case when PAGroups = 1   then 1
									 else 0
								end) * 100 [PAGroups]
						  , sum(case when PAIFSP = 1   then 1
									 else 0
								end) * 100 [PAIFSP]
						  , sum(case when PARecreation = 1   then 1
									 else 0
								end) * 100 [PARecreation]
						  , sum(case when PAOther = 1   then 1
									 else 0
								end) * 100 [PAOther]
						  , sum(case when PAForms = 1  
										  or  PAVideo = 1  
										  or  PAGroups = 1  
										  or  PAIFSP = 1  
										  or  PARecreation = 1  
										  or  PAOther = 1   then 1
									 else 0
								end) * 100 [PA1]
						  ,
-- Screening tools
							SUM(CASE WHEN a.STASQ = 1 THEN 1
									ELSE 0 END) * 100 STASQ
						  , SUM(CASE WHEN a.STASQSE = 1 THEN 1
									ELSE 0 END) * 100 STASQSE
						  , SUM(CASE WHEN a.STPHQ9 = 1 THEN 1
									ELSE 0 END) * 100 STPHQ9
						  , SUM(CASE WHEN a.STPSI = 1 THEN 1
									ELSE 0 END) * 100 STPSI
						  , SUM(CASE WHEN a.STOther = 1 THEN 1
									ELSE 0 END) * 100 STOther
						  , SUM(CASE WHEN a.STASQ = 1
										OR a.STASQSE = 1
										OR a.STPHQ9 = 1
										OR a.STPSI = 1
										OR a.STOther = 1
										THEN 1 ELSE 0 END) * 100 ST1
						  ,
-- Parent survey content
							SUM(CASE WHEN a.PSCOngoingDiscussion = 1 THEN 1
									ELSE 0 END) * 100 PSCOngoingDiscussion
						  , SUM(CASE WHEN a.PSCEmergingIssues = 1 THEN 1
									ELSE 0 END) * 100 PSCEmergingIssues
						  , SUM(CASE WHEN a.PSCImplement = 1 THEN 1
									ELSE 0 END) * 100 PSCImplement
						  , SUM(CASE WHEN a.PSCOngoingDiscussion = 1
										OR a.PSCEmergingIssues = 1
										OR a.PSCImplement = 1
										THEN 1 ELSE 0 END) * 100 PSC1
						  ,
-- Family goal plan
							SUM(CASE WHEN a.FGPNewGoal = 1 THEN 1
									ELSE 0 END) * 100 FGPNewGoal
						  , SUM(CASE WHEN a.FGPDiscuss = 1 THEN 1
									ELSE 0 END) * 100 FGPDiscuss
						  , SUM(CASE WHEN a.FGPDevelopActivities = 1 THEN 1
									ELSE 0 END) * 100 FGPDevelopActivities
						  , SUM(CASE WHEN a.FGPProgress = 1 THEN 1
									ELSE 0 END) * 100 FGPProgress
						  , SUM(CASE WHEN a.FGPRevisions = 1 THEN 1
									ELSE 0 END) * 100 FGPRevisions
						  , SUM(CASE WHEN a.FGPGoalsCompleted = 1 THEN 1
									ELSE 0 END) * 100 FGPGoalsCompleted
						  , SUM(CASE WHEN a.FGPNoDiscussion = 1 THEN 1
									ELSE 0 END) * 100 FGPNoDiscussion
						  , SUM(CASE WHEN a.FGPNewGoal = 1
										OR a.FGPDiscuss = 1
										OR a.FGPDevelopActivities = 1
										OR a.FGPProgress = 1
										OR a.FGPRevisions = 1
										OR a.FGPGoalsCompleted = 1
										OR a.FGPNoDiscussion = 1
										THEN 1 ELSE 0 END) * 100 FGP1
						  ,
-- Transition plan
							SUM(CASE WHEN a.TPNotApplicable = 1 THEN 1
									ELSE 0 END) * 100 TPNotApplicable
						  , SUM(CASE WHEN a.TPInitiated = 1 THEN 1
									ELSE 0 END) * 100 TPInitiated
						  , SUM(CASE WHEN a.TPOngoingDiscussion = 1 THEN 1
									ELSE 0 END) * 100 TPOngoingDiscussion
						  , SUM(CASE WHEN a.TPPlanFinalized = 1 THEN 1
									ELSE 0 END) * 100 TPPlanFinalized
						  , SUM(CASE WHEN a.TPTransitionCompleted = 1 THEN 1
									ELSE 0 END) * 100 TPTransitionCompleted
						  , SUM(CASE WHEN a.TPParentDeclined = 1 THEN 1
									ELSE 0 END) * 100 TPParentDeclined
						  , SUM(CASE WHEN a.TPNotApplicable = 1
										OR a.TPInitiated = 1
										OR a.TPOngoingDiscussion = 1
										OR a.TPPlanFinalized = 1
										OR a.TPTransitionCompleted = 1
										OR a.TPParentDeclined = 1
										THEN 1 ELSE 0 END) * 100 TP1
						  ,
-- MIECHV only
						    SUM(CASE WHEN a.FamilyMemberReads IS NOT NULL AND a.FamilyMemberReads <> '' THEN 1
									ELSE 0 END) * 100 FamilyMemberReads
						  , SUM(CASE WHEN a.FamilyMemberReads IS NOT NULL AND a.FamilyMemberReads <> '' THEN 1
									ELSE 0 END) * 100 MIECHV1
						  ,
-- concrete activities
							sum(case when CATransportation = 1   then 1
									 else 0
								end) * 100 [CATransportation]
						  , sum(case when CAGoods = 1   then 1
									 else 0
								end) * 100 [CAGoods]
						  , sum(case when CALegal = 1   then 1
									 else 0
								end) * 100 [CALegal]
						  , sum(case when CAHousing = 1   then 1
									 else 0
								end) * 100 [CAHousing]
						  , sum(case when CAAdvocacy = 1   then 1
									 else 0
								end) * 100 [CAAdvocacy]
						  , sum(case when CATranslation = 1   then 1
									 else 0
								end) * 100 [CATranslation]
						  , sum(case when CALaborSupport = 1   then 1
									 else 0
								end) * 100 [CALaborSupport]
						  , sum(case when CAChildSupport = 1   then 1
									 else 0
								end) * 100 [CAChildSupport]
						  , sum(case when CAParentRights = 1   then 1
									 else 0
								end) * 100 [CAParentRights]
						  , sum(case when CAVisitation = 1   then 1
									 else 0
								end) * 100 [CAVisitation]
						  , sum(case when CAOther = 1   then 1
									 else 0
								end) * 100 [CAOther]
						  , sum(case when CATransportation = 1  
										  or  CAGoods = 1  
										  or  CALegal = 1  
										  or  CALegal = 1  
										  or  CAHousing = 1  
										  or  CAAdvocacy = 1  
										  or  CATranslation = 1  
										  or  CALaborSupport = 1  
										  or  CAChildSupport = 1  
										  or  CAVisitation = 1  
										  or  CAOther = 1   then 1
									 else 0
								end) * 100 [CA1]
						  , count(*) [Total]
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join HVCase as h on h.HVCasePK = a.HVCaseFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		
							cast(VisitStartTime as date) between @StartDt and @EndDt
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1ID = '' then cp.PC1ID
												else @pc1ID
										   end
							-- and cp.ProgramFK = @programfk
							and case when @SiteFK = 0 then 1
									 when wp.SiteFK = @SiteFK then 1
									 else 0
								end = 1
				  group by	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end
				 )
		select	a.*
			  , [UniqueFamilies]
			  , [Attempted]
			  , [CompletedVisit]
			  , [CompletedPrenatalVisit]
			  , [InHome]
			  , [OutOfHome]
			  , [BothInAndOutHome]
			  , ([AvgMinuteForCompletedVisit] / x) [AvgMinuteForCompletedVisit]
			  , [PC1Participated] / x [PC1Participated]
			  , [PC2Participated] / x [PC2Participated]
			  , [OBPParticipated] / x [OBPParticipated]
			  , [FatherFigureParticipated] / x [FatherFigureParticipated]
			  , [NonPrimaryFSWParticipated] / x [NonPrimaryFSWParticipated]
			  , [FatherAdvocateParticipated] / x [FatherAdvocateParticipated]
			  , case when (x - [CompletedPrenatalVisit]) > 0
						then [TCParticipated] / (x - [CompletedPrenatalVisit]) 
						else 0 end as [TCParticipated]
			  , [GrandParentParticipated] / x [GrandParentParticipated]
			  , [SiblingParticipated] / x [SiblingParticipated]
			  , [HVSupervisorParticipated] / x [HVSupervisorParticipated]
			  , [SupervisorObservation] / x [SupervisorObservation]
			  , [OtherParticipated] / x [OtherParticipated]
			  , b.HouseholdChangesNew / x HouseholdChangesNew
			  , b.HouseholdChangesLeft / x HouseholdChangesLeft
			  , b.HouseholdChanges1 / x HouseholdChanges1
			  ,

-- child development
				[CDChildDevelopment] / x [CDChildDevelopment]
			  , [CDToys] / x [CDToys]
			  , [CDParentConcerned] / x [CDParentConcerned]
              , [CDSocialEmotionalDevelopment] / x [CDSocialEmotionalDevelopment]
              , [CDFollowUpEIServices] / x [CDFollowUpEIServices]
			  , [CDOther] / x [CDOther]
			  , [CD1] / x [CD1]
			  ,
-- Reflective strategies
				b.RSATP / a.x RSATP
			  , b.RSSATP / a.x RSSATP
			  , b.RSFFF / a.x RSFFF
			  , b.RSEW / a.x RSEW
			  , b.RSNormalizing / a.x RSNormalizing
			  , b.RSSFT / a.x RSSFT
			  , b.RS1 / a.x RS1
			  ,

-- parent/child interaction
				[PCChildInteraction] / x [PCChildInteraction]
			  , [PCChildManagement] / x [PCChildManagement]
			  , [PCFeelings] / x [PCFeelings]
			  , [PCStress] / x [PCStress]
			  , [PCBasicNeeds] / x [PCBasicNeeds]
			  , [PCShakenBaby] / x [PCShakenBaby]
			  , [PCShakenBabyVideo] / x [PCShakenBabyVideo]
			  , [PCTechnologyEffects] / x [PCTechnologyEffects]
			  , [PCOther] / x [PCOther]
			  , [PC1] / x [PC1]
-- Curriculum - primary
			  , b.CurriculumPartnersHealthyBaby / a.x CurriculumPartnersHealthyBaby
			  , b.CurriculumPAT / a.x CurriculumPAT
			  , b.CurriculumSanAngelo / a.x CurriculumSanAngelo
			  , b.CurriculumGrowingGreatKids / a.x CurriculumGrowingGreatKids
			  , b.CurriculumPrimary1 / a.x CurriculumPrimary1

-- Curriculum - supplemental

			  , b.CurriculumParentsForLearning / a.x CurriculumParentsForLearning
			  , b.CurriculumHelpingBabiesLearn / a.x CurriculumHelpingBabiesLearn
			  , b.Curriculum247Dads / a.x Curriculum247Dads
			  , b.CurriculumBoyz2Dads / a.x CurriculumBoyz2Dads
			  , b.CurriculumGreatBeginnings / a.x CurriculumGreatBeginnings
			  , b.CurriculumInsideOutDads / a.x CurriculumInsideOutDads
			  , b.CurriculumMomGateway / a.x CurriculumMomGateway
			  , b.CurriculumPATFocusFathers / a.x CurriculumPATFocusFathers
			  , b.CurriculumOther / a.x CurriculumOther
			  , b.CurriculumOtherSupplementalInformation / a.x CurriculumOtherSupplementalInformation
			  , b.CurriculumNone / a.x CurriculumNone
			  , b.CurriculumSupplemental1 / a.x CurriculumSupplemental1

-- Target Child Health
			  , b.HealthTCMedicalWellBabyAppointments / a.x HealthTCMedicalWellBabyAppointments
			  , b.HealthTCImmunizations / a.x HealthTCImmunizations
			  , b.HealthTCERVisits / a.x HealthTCERVisits
			  , b.HealthTC1 / a.x HealthTC1

-- Parents or Other Caregiver Health
			  , b.HealthPC1MedicalPrenatalAppointments / a.x HealthPC1MedicalPrenatalAppointments
			  , b.HealthPC1ERVisits / a.x HealthPC1ERVisits
			  , b.HealthPC1 / a.x HealthPC1

-- Health care
			  , [HCGeneral] / x [HCGeneral]
			  , [HCChild] / x [HCChild]
			  , [HCDental] / x [HCDental]
			  , [HCFeeding] / x [HCFeeding]
			  , [HCLaborDelivery] / x [HCLaborDelivery]
			  , [HCBreastFeeding] / x [HCBreastFeeding]
			  , [HCNutrition] / x [HCNutrition]
			  , [HCFamilyPlanning] / x [HCFamilyPlanning]
			  , [HCProviders] / x [HCProviders]
			  , [HCFASD] / x [HCFASD]
			  , [HCSexEducation] / x [HCSexEducation]
			  , [HCPrenatalCare] / x [HCPrenatalCare]
			  , [HCMedicalAdvocacy] / x [HCMedicalAdvocacy]
			  , [HCSafety] / x [HCSafety]
			  , [HCSmoking] / x [HCSmoking]
			  , [HCSIDS] / x [HCSIDS]
			  , [HCOther] / x [HCOther]
			  , [HCOther] / x [HCOther]
			  , [HC1] / x [HC1]
			  ,

-- family functioning
				[FFDomesticViolence] / x [FFDomesticViolence]
			  , [FFFamilyRelations] / x [FFFamilyRelations]
			  , [FFSubstanceAbuse] / x [FFSubstanceAbuse]
			  , [FFMentalHealth] / x [FFMentalHealth]
			  , [FFDevelopmentalDisabilities] / x [FFDevelopmentalDisabilities]
			  , [FFImmigration] / x [FFImmigration]
			  , [FFCommunication] / x [FFCommunication]
			  , [FFChildProtectiveIssues] / x [FFChildProtectiveIssues]
			  , [FFOther] / x [FFOther]
			  , [FF1] / x [FF1]
			  ,

-- self sufficiency
				[SSHomeEnvironment] / x [SSHomeEnvironment]
			  , [SSCalendar] / x [SSCalendar]
			  , [SSHousekeeping] / x [SSHousekeeping]
			  , [SSTransportation] / x [SSTransportation]
			  , [SSChildWelfareServices] / x [SSChildWelfareServices]
			  , [SSEmployment] / x [SSEmployment]
			  , [SSMoneyManagement] / x [SSMoneyManagement]
			  , [SSChildCare] / x [SSChildCare]
			  , [SSProblemSolving] / x [SSProblemSolving]
			  , [SSEducation] / x [SSEducation]
			  , [SSJob] / x [SSJob]
			  , [SSOther] / x [SSOther]
			  , [SS1] / x [SS1]
			  ,

-- crisis intervention
				[CIProblems] / x [CIProblems]
			  , [CIOther] / x [CIOther]
			  , [CI1] / x [CI1]
			  ,

--Referrals
			    b.ReferralsMade / x ReferralsMade
			  , b.ReferralsFollowUp / x ReferralsFollowUp
			  , b.Referrals1 / x Referrals1
			  ,

-- program activities
				[PAForms] / x [PAForms]
			  , [PAVideo] / x [PAVideo]
			  , [PAGroups] / x [PAGroups]
			  , [PAIFSP] / x [PAIFSP]
			  , [PARecreation] / x [PARecreation]
			  , [PAOther] / x [PAOther]
			  , [PA1] / x [PA1]
			  ,

-- Screening tools
				b.STASQ / x STASQ
			  , b.STASQSE / x STASQSE
			  , b.STPHQ9 / x STPHQ9
			  , b.STPSI / x STPSI
			  , b.STOther / x STOther
			  , b.ST1 / x ST1
			  ,

-- Parent Survey content
			    b.PSCOngoingDiscussion / x PSCOngoingDiscussion
			  , b.PSCEmergingIssues / x PSCEmergingIssues
			  , b.PSCImplement / x PSCImplement
			  , b.PSC1 / x PSC1
			  ,

-- Family goal plan
				b.FGPNewGoal / x FGPNewGoal
			  , b.FGPDiscuss / x FGPDiscuss
			  , b.FGPDevelopActivities / x FGPDevelopActivities
			  , b.FGPProgress / x FGPProgress
			  , b.FGPRevisions / x FGPRevisions
			  , b.FGPGoalsCompleted / x FGPGoalsCompleted
			  , b.FGPNoDiscussion / x FGPNoDiscussion
			  , b.FGP1 / x FGP1
			  ,

-- Transition plan
				b.TPNotApplicable / x TPNotApplicable
			  , b.TPInitiated / x TPInitiated
			  , b.TPOngoingDiscussion / x TPOngoingDiscussion
			  , b.TPPlanFinalized / x TPPlanFinalized
			  , b.TPTransitionCompleted / x TPTransitionCompleted
			  , b.TPParentDeclined / x TPParentDeclined
			  , b.TP1 / x TP1
			  ,

-- MIECHV only
				b.FamilyMemberReads / x FamilyMemberReads
			  , b.MIECHV1 / x MIECHV1
			  ,

-- concrete activities
				[CATransportation] / x [CATransportation]
			  , [CAGoods] / x [CAGoods]
			  , [CALegal] / x [CALegal]
			  , [CAHousing] / x [CAHousing]
			  , [CAAdvocacy] / x [CAAdvocacy]
			  , [CATranslation] / x [CATranslation]
			  , [CALaborSupport] / x [CALaborSupport]
			  , [CAChildSupport] / x [CAChildSupport]
			  , [CAParentRights] / x [CAParentRights]
			  , [CAVisitation] / x [CAVisitation]
			  , [CAOther] / x [CAOther]
			  , [CA1] / x [CA1]
			  , [Total]
			  , case when c.WorkerPK is null then 'All Workers'
					 else rtrim(c.LastName) + ', ' + rtrim(c.FirstName)
				end WorkerName
		from	base11 as a
		join	base2 as b on a.FSWFK = b.FSWFK
							  and a.PC1ID = b.PC1ID
		left outer join Worker as c on case	when (@showWorkerDetail = 'N'
												  and @workerfk is not null
												 ) then @workerfk
											else a.FSWFK
									   end = c.WorkerPK
		order by WorkerName
			  , a.PC1ID
GO
