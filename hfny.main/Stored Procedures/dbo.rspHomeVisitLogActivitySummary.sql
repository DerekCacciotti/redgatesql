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
						  , count(distinct (case when substring(VisitType, 4, 1) != '1' then a.HVCaseFK
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
						  , sum(case when substring(VisitType, 4, 1) != '1'
										  and isnull(h.TCDOB, h.EDC) > a.VisitStartTime then 1
									 else 0
								end) [CompletedPenatalVisit]
						  , sum(case when substring(VisitType, 1, 3) in ('100', '110', '010') then 1
									 else 0
								end) [InHome]
						  , sum(case when substring(VisitType, 1, 3) = '001' then 1
									 else 0
								end) [OutOfHome]
						  , sum(case when substring(VisitType, 1, 3) in ('101', '111', '011') then 1
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
						  , sum(case when FatherAdvocateParticipated > 0 then 1
									 else 0
								end) [FatherAdvocateParticipated]
						  , sum(case when TCParticipated = 1 then 1
									 else 0
								end) * 100 [TCParticipated]
						  , sum(case when GrandParentParticipated = 1 then 1
									 else 0
								end) * 100 [GrandParentParticipated]
						  , sum(case when SiblingParticipated = 1 then 1
									 else 0
								end) * 100 [SiblingParticipated]
						  , sum(case when NonPrimaryFSWParticipated = 1 then 1
									 else 0
								end) * 100 [NonPrimaryFSWParticipated]
						  , sum(case when HVSupervisorParticipated = 1 then 1
									 else 0
								end) * 100 [HVSupervisorParticipated]
						  , sum(case when SupervisorObservation = 1 then 1
									 else 0
								end) * 100 [SupervisorObservation]
						  , sum(case when OtherParticipated = 1 then 1
									 else 0
								end) * 100 [OtherParticipated]
						  ,

-- child development
							sum(case when CDChildDevelopment = 1 then 1
									 else 0
								end) * 100 [CDChildDevelopment]
						  , sum(case when CDChildDevelopment = 1 then 1
									 else 0
								end) * 100 [CDChildDevelopmentNon]
						  , sum(case when CDToys = 1 then 1
									 else 0
								end) * 100 [CDToys]
						  , sum(case when CDToys = 1 then 1
									 else 0
								end) * 100 [CDToysNon]
						  , sum(case when CDOther = 1 then 1
									 else 0
								end) * 100 [CDOther]
						  , sum(case when CDOther = 1 then 1
									 else 0
								end) * 100 [CDOtherNon]
						  , sum(case when CDChildDevelopment = 1
										  or CDToys = 1
										  or CDOther = 1 then 1
									 else 0
								end) * 100 [CD1]
						  , sum(case when CDChildDevelopment = 1
										  or CDToys = 1
										  or CDOther = 1 then 1
									 else 0
								end) * 100 [CD2]
						  ,

-- parent/child interaction
							sum(case when PCChildInteraction = 1 then 1
									 else 0
								end) * 100 [PCChildInteraction]
						  , sum(case when PCChildInteraction = 1 then 1
									 else 0
								end) * 100 [PCChildInteractionNon]
						  , sum(case when PCChildManagement = 1 then 1
									 else 0
								end) * 100 [PCChildManagement]
						  , sum(case when PCChildManagement = 1 then 1
									 else 0
								end) * 100 [PCChildManagementNon]
						  , sum(case when PCFeelings = 1 then 1
									 else 0
								end) * 100 [PCFeelings]
						  , sum(case when PCFeelings = 1 then 1
									 else 0
								end) * 100 [PCFeelingsNon]
						  , sum(case when PCStress = 1 then 1
									 else 0
								end) * 100 [PCStress]
						  , sum(case when PCStress = 1 then 1
									 else 0
								end) * 100 [PCStressNon]
						  , sum(case when PCBasicNeeds = 1 then 1
									 else 0
								end) * 100 [PCBasicNeeds]
						  , sum(case when PCBasicNeeds = 1 then 1
									 else 0
								end) * 100 [PCBasicNeedsNon]
						  , sum(case when PCShakenBaby = 1 then 1
									 else 0
								end) * 100 [PCShakenBaby]
						  , sum(case when PCShakenBaby = 1 then 1
									 else 0
								end) * 100 [PCShakenBabyNon]
						  , sum(case when PCShakenBabyVideo = 1 then 1
									 else 0
								end) * 100 [PCShakenBabyVideo]
						  , sum(case when PCShakenBabyVideo = 1 then 1
									 else 0
								end) * 100 [PCShakenBabyVideoNon]
						  , sum(case when PCOther = 1 then 1
									 else 0
								end) * 100 [PCOther]
						  , sum(case when PCOther = 1 then 1
									 else 0
								end) * 100 [PCOtherNon]
						  , sum(case when PCChildInteraction = 1
										  or PCChildManagement = 1
										  or PCFeelings= 1
										  or PCStress = 1
										  or PCBasicNeeds = 1
										  or PCShakenBaby = 1
										  or PCShakenBabyVideo = 1
										  or PCOther = 1 then 1
									 else 0
								end) * 100 [PC1]
						  , sum(case when PCChildInteraction = 1
										  or PCChildManagement = 1
										  or PCFeelings = 1
										  or PCStress = 1
										  or PCBasicNeeds = 1
										  or PCShakenBaby = 1
										  or PCShakenBabyVideo = 1
										  or PCOther = 1 then 1
									 else 0
								end) * 100 [PC2]
						  ,

-- Health care
							sum(case when HCGeneral = 1 then 1
									 else 0
								end) * 100 [HCGeneral]
						  , sum(case when HCGeneral = 1 then 1
									 else 0
								end) * 100 [HCGeneralNon]
						  , sum(case when HCChild = 1 then 1
									 else 0
								end) * 100 [HCChild]
						  , sum(case when HCChild = 1 then 1
									 else 0
								end) * 100 [HCChildNon]
						  , sum(case when HCDental = 1 then 1
									 else 0
								end) * 100 [HCDental]
						  , sum(case when HCDental = 1 then 1
									 else 0
								end) * 100 [HCDentalNon]
						  , sum(case when HCFeeding = 1 then 1
									 else 0
								end) * 100 [HCFeeding]
						  , sum(case when HCFeeding = 1 then 1
									 else 0
								end) * 100 [HCFeedingNon]
						  , sum(case when HCBreastFeeding = 1 then 1
									 else 0
								end) * 100 [HCBreastFeeding]
						  , sum(case when HCBreastFeeding = 1 then 1
									 else 0
								end) * 100 [HCBreastFeedingNon]
						  , sum(case when HCNutrition = 1 then 1
									 else 0
								end) * 100 [HCNutrition]
						  , sum(case when HCNutrition = 1 then 1
									 else 0
								end) * 100 [HCNutritionNon]
						  , sum(case when HCFamilyPlanning = 1 then 1
									 else 0
								end) * 100 [HCFamilyPlanning]
						  , sum(case when HCFamilyPlanning = 1 then 1
									 else 0
								end) * 100 [HCFamilyPlanningNon]
						  , sum(case when HCProviders = 1 then 1
									 else 0
								end) * 100 [HCProviders]
						  , sum(case when HCProviders = 1 then 1
									 else 0
								end) * 100 [HCProvidersNon]
						  , sum(case when HCFASD = 1 then 1
									 else 0
								end) * 100 [HCFASD]
						  , sum(case when HCFASD = 1 then 1
									 else 0
								end) * 100 [HCFASDNon]
						  , sum(case when HCSexEducation = 1 then 1
									 else 0
								end) * 100 [HCSexEducation]
						  , sum(case when HCSexEducation = 1 then 1
									 else 0
								end) * 100 [HCSexEducationNon]
						  , sum(case when HCPrenatalCare = 1 then 1
									 else 0
								end) * 100 [HCPrenatalCare]
						  , sum(case when HCPrenatalCare = 1 then 1
									 else 0
								end) * 100 [HCPrenatalCareNon]
						  , sum(case when HCMedicalAdvocacy = 1 then 1
									 else 0
								end) * 100 [HCMedicalAdvocacy]
						  , sum(case when HCMedicalAdvocacy = 1 then 1
									 else 0
								end) * 100 [HCMedicalAdvocacyNon]
						  , sum(case when HCSafety = 1 then 1
									 else 0
								end) * 100 [HCSafety]
						  , sum(case when HCSafety = 1 then 1
									 else 0
								end) * 100 [HCSafetyNon]
						  , sum(case when HCSmoking = 1 then 1
									 else 0
								end) * 100 [HCSmoking]
						  , sum(case when HCSmoking = 1 then 1
									 else 0
								end) * 100 [HCSmokingNon]
						  , sum(case when HCSIDS = 1 then 1
									 else 0
								end) * 100 [HCSIDS]
						  , sum(case when HCSIDS = 1 then 1
									 else 0
								end) * 100 [HCSIDSNon]
						  , sum(case when HCOther = 1 then 1
									 else 0
								end) * 100 [HCOther]
						  , sum(case when HCOther = 1 then 1
									 else 0
								end) * 100 [HCOtherNon]
						  , sum(case when HCGeneral = 1
										  or HCChild = 1
										  or HCDental = 1
										  or HCFeeding = 1
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
						  , sum(case when HCGeneral = 1  
										  or  HCChild = 1  
										  or  HCDental = 1  
										  or  HCFeeding = 1  
										  or  HCBreastFeeding = 1  
										  or  HCNutrition = 1  
										  or  HCFamilyPlanning = 1  
										  or  HCProviders = 1  
										  or  HCFASD = 1  
										  or  HCSexEducation = 1  
										  or  HCPrenatalCare = 1  
										  or  HCMedicalAdvocacy = 1  
										  or  HCSafety = 1  
										  or  HCSmoking = 1  
										  or  HCSIDS = 1  
										  or  HCOther = 1   then 1
									 else 0
								end) * 100 [HC2]
						  ,

-- family functioning
							sum(case when FFDomesticViolence = 1 then 1
									 else 0
								end) * 100 [FFDomesticViolence]
						  , sum(case when FFDomesticViolence = 1 then 1
									 else 0
								end) * 100 [FFDomesticViolenceNon]
						  , sum(case when FFFamilyRelations = 1 then 1
									 else 0
								end) * 100 [FFFamilyRelations]
						  , sum(case when FFFamilyRelations = 1 then 1
									 else 0
								end) * 100 [FFFamilyRelationsNon]
						  , sum(case when FFSubstanceAbuse = 1 then 1
									 else 0
								end) * 100 [FFSubstanceAbuse]
						  , sum(case when FFSubstanceAbuse = 1 then 1
									 else 0
								end) * 100 [FFSubstanceAbuseNon]
						  , sum(case when FFMentalHealth = 1 then 1
									 else 0
								end) * 100 [FFMentalHealth]
						  , sum(case when FFMentalHealth = 1 then 1
									 else 0
								end) * 100 [FFMentalHealthNon]
						  , sum(case when FFCommunication = 1 then 1
									 else 0
								end) * 100 [FFCommunication]
						  , sum(case when FFCommunication = 1 then 1
									 else 0
								end) * 100 [FFCommunicationNon]
						  , sum(case when FFOther = 1 then 1
									 else 0
								end) * 100 [FFOther]
						  , sum(case when FFOther = 1 then 1
									 else 0
								end) * 100 [FFOtherNon]
						  , sum(case when FFDomesticViolence = 1
										  or FFFamilyRelations = 1
										  or FFSubstanceAbuse = 1
										  or FFMentalHealth = 1
										  or FFCommunication = 1
										  or FFOther = 1 then 1
									 else 0
								end) * 100 [FF1]
						  , sum(case when FFDomesticViolence = 1
										  or FFFamilyRelations = 1
										  or FFSubstanceAbuse = 1
										  or FFMentalHealth = 1
										  or FFCommunication = 1
										  or FFOther = 1 then 1
									 else 0
								end) * 100 [FF2]
						  ,

-- self sufficiency
							sum(case when SSCalendar = 1 then 1
									 else 0
								end) * 100 [SSCalendar]
						  , sum(case when SSCalendar = 1 then 1
									 else 0
								end) * 100 [SSCalendarNon]
						  , sum(case when SSHousekeeping = 1 then 1
									 else 0
								end) * 100 [SSHousekeeping]
						  , sum(case when SSHousekeeping = 1 then 1
									 else 0
								end) * 100 [SSHousekeepingNon]
						  , sum(case when SSTransportation = 1 then 1
									 else 0
								end) * 100 [SSTransportation]
						  , sum(case when SSTransportation = 1 then 1
									 else 0
								end) * 100 [SSTransportationNon]
						  , sum(case when SSEmployment = 1 then 1
									 else 0
								end) * 100 [SSEmployment]
						  , sum(case when SSEmployment = 1 then 1
									 else 0
								end) * 100 [SSEmploymentNon]
						  , sum(case when SSMoneyManagement = 1 then 1
									 else 0
								end) * 100 [SSMoneyManagement]
						  , sum(case when SSMoneyManagement = 1 then 1
									 else 0
								end) * 100 [SSMoneyManagementNon]
						  , sum(case when SSChildCare = 1 then 1
									 else 0
								end) * 100 [SSChildCare]
						  , sum(case when SSChildCare = 1 then 1
									 else 0
								end) * 100 [SSChildCareNon]
						  , sum(case when SSProblemSolving = 1 then 1
									 else 0
								end) * 100 [SSProblemSolving]
						  , sum(case when SSProblemSolving = 1 then 1
									 else 0
								end) * 100 [SSProblemSolvingNon]
						  , sum(case when SSEducation = 1 then 1
									 else 0
								end) * 100 [SSEducation]
						  , sum(case when SSEducation = 1 then 1
									 else 0
								end) * 100 [SSEducationNon]
						  , sum(case when SSJob = 1 then 1
									 else 0
								end) * 100 [SSJob]
						  , sum(case when SSJob = 1 then 1
									 else 0
								end) * 100 [SSJobNon]
						  , sum(case when SSOther = 1 then 1
									 else 0
								end) * 100 [SSOther]
						  , sum(case when SSOther = 1 then 1
									 else 0
								end) * 100 [SSOtherNon]
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
								end) * 100 [SS2]
						  ,

-- crisis intervention
							sum(case when CIProblems = 1   then 1
									 else 0
								end) * 100 [CIProblems]
						  , sum(case when CIProblems = 1   then 1
									 else 0
								end) * 100 [CIProblemsNon]
						  , sum(case when CIOther = 1   then 1
									 else 0
								end) * 100 [CIOther]
						  , sum(case when CIOther = 1   then 1
									 else 0
								end) * 100 [CIOtherNon]
						  , sum(case when CIProblems = 1  
										  or CIOther = 1   then 1
									 else 0
								end) * 100 [CI1]
						  , sum(case when CIProblems = 1  
										  or CIOther = 1   then 1
									 else 0
								end) * 100 [CI2]
						  ,

-- program activities
							sum(case when PAForms = 1   then 1
									 else 0
								end) * 100 [PAForms]
						  , sum(case when PAForms = 1   then 1
									 else 0
								end) * 100 [PAFormsNon]
						  , sum(case when PAVideo = 1   then 1
									 else 0
								end) * 100 [PAVideo]
						  , sum(case when PAVideo = 1   then 1
									 else 0
								end) * 100 [PAVideoNon]
						  , sum(case when PAGroups = 1   then 1
									 else 0
								end) * 100 [PAGroups]
						  , sum(case when PAGroups = 1   then 1
									 else 0
								end) * 100 [PAGroupsNon]
						  , sum(case when PAIFSP = 1   then 1
									 else 0
								end) * 100 [PAIFSP]
						  , sum(case when PAIFSP = 1   then 1
									 else 0
								end) * 100 [PAIFSPNon]
						  , sum(case when PARecreation = 1   then 1
									 else 0
								end) * 100 [PARecreation]
						  , sum(case when PARecreation = 1   then 1
									 else 0
								end) * 100 [PARecreationNon]
						  , sum(case when PAOther = 1   then 1
									 else 0
								end) * 100 [PAOther]
						  , sum(case when PAOther = 1   then 1
									 else 0
								end) * 100 [PAOtherNon]
						  , sum(case when PAForms = 1  
										  or  PAVideo = 1  
										  or  PAGroups = 1  
										  or  PAIFSP = 1  
										  or  PARecreation = 1  
										  or  PAOther = 1   then 1
									 else 0
								end) * 100 [PA1]
						  , sum(case when PAForms = 1  
										  or  PAVideo = 1  
										  or  PAGroups = 1  
										  or  PAIFSP = 1  
										  or  PARecreation = 1  
										  or  PAOther = 1   then 1
									 else 0
								end) * 100 [PA2]
						  ,

-- concrete activities
							sum(case when CATransportation = 1   then 1
									 else 0
								end) * 100 [CATransportation]
						  , sum(case when CATransportation = 1   then 1
									 else 0
								end) * 100 [CATransportationNon]
						  , sum(case when CAGoods = 1   then 1
									 else 0
								end) * 100 [CAGoods]
						  , sum(case when CAGoods = 1   then 1
									 else 0
								end) * 100 [CAGoodsNon]
						  , sum(case when CALegal = 1   then 1
									 else 0
								end) * 100 [CALegal]
						  , sum(case when CALegal = 1   then 1
									 else 0
								end) * 100 [CALegalNon]
						  , sum(case when CAHousing = 1   then 1
									 else 0
								end) * 100 [CAHousing]
						  , sum(case when CAHousing = 1   then 1
									 else 0
								end) * 100 [CAHousingNon]
						  , sum(case when CAAdvocacy = 1   then 1
									 else 0
								end) * 100 [CAAdvocacy]
						  , sum(case when CAAdvocacy = 1   then 1
									 else 0
								end) * 100 [CAAdvocacyNon]
						  , sum(case when CATranslation = 1   then 1
									 else 0
								end) * 100 [CATranslation]
						  , sum(case when CATranslation = 1   then 1
									 else 0
								end) * 100 [CATranslationNon]
						  , sum(case when CALaborSupport = 1   then 1
									 else 0
								end) * 100 [CALaborSupport]
						  , sum(case when CALaborSupport = 1   then 1
									 else 0
								end) * 100 [CALaborSupportNon]
						  , sum(case when CAChildSupport = 1   then 1
									 else 0
								end) * 100 [CAChildSupport]
						  , sum(case when CAChildSupport = 1   then 1
									 else 0
								end) * 100 [CAChildSupportNon]
						  , sum(case when CAParentRights = 1   then 1
									 else 0
								end) * 100 [CAParentRights]
						  , sum(case when CAParentRights = 1   then 1
									 else 0
								end) * 100 [CAParentRightsNon]
						  , sum(case when CAVisitation = 1   then 1
									 else 0
								end) * 100 [CAVisitation]
						  , sum(case when CAVisitation = 1   then 1
									 else 0
								end) * 100 [CAVisitationNon]
						  , sum(case when CAOther = 1   then 1
									 else 0
								end) * 100 [CAOther]
						  , sum(case when CAOther = 1   then 1
									 else 0
								end) * 100 [CAOtherNon]
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
								end) * 100 [CA2]
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
			  , [CompletedPenatalVisit]
			  , [InHome]
			  , [OutOfHome]
			  , [BothInAndOutHome]
			  , ([AvgMinuteForCompletedVisit] / x) [AvgMinuteForCompletedVisit]
			  , [PC1Participated] / x [PC1Participated]
			  , [PC2Participated] / x [PC2Participated]
			  , [OBPParticipated] / x [OBPParticipated]
			  , [FatherFigureParticipated] / x [FatherFigureParticipated]
			  , [FatherAdvocateParticipated] / x [FatherAdvocateParticipated]
			  , case when (x - [CompletedPenatalVisit]) > 0
						then [TCParticipated] / (x - [CompletedPenatalVisit]) 
						else 0 end as [TCParticipated]
			  , [GrandParentParticipated] / x [GrandParentParticipated]
			  , [SiblingParticipated] / x [SiblingParticipated]
			  , [NonPrimaryFSWParticipated] / x [NonPrimaryFSWParticipated]
			  , [HVSupervisorParticipated] / x [HVSupervisorParticipated]
			  , [SupervisorObservation] / x [SupervisorObservation]
			  , [OtherParticipated] / x [OtherParticipated]
			  ,

-- child development
				[CDChildDevelopment] / x [CDChildDevelopment]
			  , [CDChildDevelopmentNon] / x [CDChildDevelopmentNon]
			  , [CDToys] / x [CDToys]
			  , [CDToysNon] / x [CDToysNon]
			  , [CDOther] / x [CDOther]
			  , [CDOtherNon] / x [CDOtherNon]
			  , [CD1] / x [CD1]
			  , [CD2] / x [CD2]
			  ,

-- parent/child interaction
				[PCChildInteraction] / x [PCChildInteraction]
			  , [PCChildInteractionNon] / x [PCChildInteractionNon]
			  , [PCChildManagement] / x [PCChildManagement]
			  , [PCChildManagementNon] / x [PCChildManagementNon]
			  , [PCFeelings] / x [PCFeelings]
			  , [PCFeelingsNon] / x [PCFeelingsNon]
			  , [PCStress] / x [PCStress]
			  , [PCStressNon] / x [PCStressNon]
			  , [PCBasicNeeds] / x [PCBasicNeeds]
			  , [PCBasicNeedsNon] / x [PCBasicNeedsNon]
			  , [PCShakenBaby] / x [PCShakenBaby]
			  , [PCShakenBabyNon] / x [PCShakenBabyNon]
			  , [PCShakenBabyVideo] / x [PCShakenBabyVideo]
			  , [PCShakenBabyVideoNon] / x [PCShakenBabyVideoNon]
			  , [PCOther] / x [PCOther]
			  , [PCOtherNon] / x [PCOtherNon]
			  , [PC1] / x [PC1]
			  , [PC2] / x [PC2]
			  ,

-- Health care
				[HCGeneral] / x [HCGeneral]
			  , [HCGeneralNon] / x [HCGeneralNon]
			  , [HCChild] / x [HCChild]
			  , [HCChildNon] / x [HCChildNon]
			  , [HCDental] / x [HCDental]
			  , [HCDentalNon] / x [HCDentalNon]
			  , [HCFeeding] / x [HCFeeding]
			  , [HCFeedingNon] / x [HCFeedingNon]
			  , [HCBreastFeeding] / x [HCBreastFeeding]
			  , [HCBreastFeedingNon] / x [HCBreastFeedingNon]
			  , [HCNutrition] / x [HCNutrition]
			  , [HCNutritionNon] / x [HCNutritionNon]
			  , [HCFamilyPlanning] / x [HCFamilyPlanning]
			  , [HCFamilyPlanningNon] / x [HCFamilyPlanningNon]
			  , [HCProviders] / x [HCProviders]
			  , [HCProvidersNon] / x [HCProvidersNon]
			  , [HCFASD] / x [HCFASD]
			  , [HCFASDNon] / x [HCFASDNon]
			  , [HCSexEducation] / x [HCSexEducation]
			  , [HCSexEducationNon] / x [HCSexEducationNon]
			  , [HCPrenatalCare] / x [HCPrenatalCare]
			  , [HCPrenatalCareNon] / x [HCPrenatalCareNon]
			  , [HCMedicalAdvocacy] / x [HCMedicalAdvocacy]
			  , [HCMedicalAdvocacyNon] / x [HCMedicalAdvocacyNon]
			  , [HCSafety] / x [HCSafety]
			  , [HCSafetyNon] / x [HCSafetyNon]
			  , [HCSmoking] / x [HCSmoking]
			  , [HCSmokingNon] / x [HCSmokingNon]
			  , [HCSIDS] / x [HCSIDS]
			  , [HCSIDSNon] / x [HCSIDSNon]
			  , [HCOther] / x [HCOther]
			  , [HCOther] / x [HCOther]
			  , [HCOtherNon] / x [HCOtherNon]
			  , [HC1] / x [HC1]
			  , [HC2] / x [HC2]
			  ,

-- family functioning
				[FFDomesticViolence] / x [FFDomesticViolence]
			  , [FFDomesticViolenceNon] / x [FFDomesticViolenceNon]
			  , [FFFamilyRelations] / x [FFFamilyRelations]
			  , [FFFamilyRelationsNon] / x [FFFamilyRelationsNon]
			  , [FFSubstanceAbuse] / x [FFSubstanceAbuse]
			  , [FFSubstanceAbuseNon] / x [FFSubstanceAbuseNon]
			  , [FFMentalHealth] / x [FFMentalHealth]
			  , [FFMentalHealthNon] / x [FFMentalHealthNon]
			  , [FFCommunication] / x [FFCommunication]
			  , [FFCommunicationNon] / x [FFCommunicationNon]
			  , [FFOther] / x [FFOther]
			  , [FFOtherNon] / x [FFOtherNon]
			  , [FF1] / x [FF1]
			  , [FF2] / x [FF2]
			  ,

-- self sufficiency
				[SSCalendar] / x [SSCalendar]
			  , [SSCalendarNon] / x [SSCalendarNon]
			  , [SSHousekeeping] / x [SSHousekeeping]
			  , [SSHousekeepingNon] / x [SSHousekeepingNon]
			  , [SSTransportation] / x [SSTransportation]
			  , [SSTransportationNon] / x [SSTransportationNon]
			  , [SSEmployment] / x [SSEmployment]
			  , [SSEmploymentNon] / x [SSEmploymentNon]
			  , [SSMoneyManagement] / x [SSMoneyManagement]
			  , [SSMoneyManagementNon] / x [SSMoneyManagementNon]
			  , [SSChildCare] / x [SSChildCare]
			  , [SSChildCareNon] / x [SSChildCareNon]
			  , [SSProblemSolving] / x [SSProblemSolving]
			  , [SSProblemSolvingNon] / x [SSProblemSolvingNon]
			  , [SSEducation] / x [SSEducation]
			  , [SSEducationNon] / x [SSEducationNon]
			  , [SSJob] / x [SSJob]
			  , [SSJobNon] / x [SSJobNon]
			  , [SSOther] / x [SSOther]
			  , [SSOtherNon] / x [SSOtherNon]
			  , [SS1] / x [SS1]
			  , [SS2] / x [SS2]
			  ,

-- crisis intervention
				[CIProblems] / x [CIProblems]
			  , [CIProblemsNon] / x [CIProblemsNon]
			  , [CIOther] / x [CIOther]
			  , [CIOtherNon] / x [CIOtherNon]
			  , [CI1] / x [CI1]
			  , [CI2] / x [CI2]
			  ,

-- program activities
				[PAForms] / x [PAForms]
			  , [PAFormsNon] / x [PAFormsNon]
			  , [PAVideo] / x [PAVideo]
			  , [PAVideoNon] / x [PAVideoNon]
			  , [PAGroups] / x [PAGroups]
			  , [PAGroupsNon] / x [PAGroupsNon]
			  , [PAIFSP] / x [PAIFSP]
			  , [PAIFSPNon] / x [PAIFSPNon]
			  , [PARecreation] / x [PARecreation]
			  , [PARecreationNon] / x [PARecreationNon]
			  , [PAOther] / x [PAOther]
			  , [PAOtherNon] / x [PAOtherNon]
			  , [PA1] / x [PA1]
			  , [PA2] / x [PA2]
			  ,

-- concrete activities
				[CATransportation] / x [CATransportation]
			  , [CATransportationNon] / x [CATransportationNon]
			  , [CAGoods] / x [CAGoods]
			  , [CAGoodsNon] / x [CAGoodsNon]
			  , [CALegal] / x [CALegal]
			  , [CALegalNon] / x [CALegalNon]
			  , [CAHousing] / x [CAHousing]
			  , [CAHousingNon] / x [CAHousingNon]
			  , [CAAdvocacy] / x [CAAdvocacy]
			  , [CAAdvocacyNon] / x [CAAdvocacyNon]
			  , [CATranslation] / x [CATranslation]
			  , [CATranslationNon] / x [CATranslationNon]
			  , [CALaborSupport] / x [CALaborSupport]
			  , [CALaborSupportNon] / x [CALaborSupportNon]
			  , [CAChildSupport] / x [CAChildSupport]
			  , [CAChildSupportNon] / x [CAChildSupportNon]
			  , [CAParentRights] / x [CAParentRights]
			  , [CAParentRightsNon] / x [CAParentRightsNon]
			  , [CAVisitation] / x [CAVisitation]
			  , [CAVisitationNon] / x [CAVisitationNon]
			  , [CAOther] / x [CAOther]
			  , [CAOtherNon] / x [CAOtherNon]
			  , [CA1] / x [CA1]
			  , [CA2] / x [CA2]
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
