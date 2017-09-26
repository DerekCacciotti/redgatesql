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
						  , sum(case when CDToys = 1 then 1
									 else 0
								end) * 100 [CDToys]
						  , sum(case when CDParentConcerned > 0 then 1
									 else 0
								end) [CDParentConcerned]
						  , sum(case when CDSocialEmotionalDevelopment > 0 then 1
									 else 0
								end) [CDSocialEmotionalDevelopment]
						  , sum(case when CDFollowUpEIServices > 0 then 1
									 else 0
								end) [CDFollowUpEIServices]
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
-- Health care
							sum(case when HCGeneral = 1 then 1
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
						  , sum(case when FFCommunication = 1 then 1
									 else 0
								end) * 100 [FFCommunication]
						  , sum(case when FFOther = 1 then 1
									 else 0
								end) * 100 [FFOther]
						  , sum(case when FFDomesticViolence = 1
										  or FFFamilyRelations = 1
										  or FFSubstanceAbuse = 1
										  or FFMentalHealth = 1
										  or FFCommunication = 1
										  or FFOther = 1 then 1
									 else 0
								end) * 100 [FF1]
						  ,
-- self sufficiency
							sum(case when SSCalendar = 1 then 1
									 else 0
								end) * 100 [SSCalendar]
						  , sum(case when SSHousekeeping = 1 then 1
									 else 0
								end) * 100 [SSHousekeeping]
						  , sum(case when SSTransportation = 1 then 1
									 else 0
								end) * 100 [SSTransportation]
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
			  , [FatherAdvocateParticipated] / x [FatherAdvocateParticipated]
			  , case when (x - [CompletedPrenatalVisit]) > 0
						then [TCParticipated] / (x - [CompletedPrenatalVisit]) 
						else 0 end as [TCParticipated]
			  , [GrandParentParticipated] / x [GrandParentParticipated]
			  , [SiblingParticipated] / x [SiblingParticipated]
			  , [HVSupervisorParticipated] / x [HVSupervisorParticipated]
			  , [SupervisorObservation] / x [SupervisorObservation]
			  , [OtherParticipated] / x [OtherParticipated]
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
			  ,

-- Health care
				[HCGeneral] / x [HCGeneral]
			  , [HCChild] / x [HCChild]
			  , [HCDental] / x [HCDental]
			  , [HCFeeding] / x [HCFeeding]
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
			  , [FFCommunication] / x [FFCommunication]
			  , [FFOther] / x [FFOther]
			  , [FF1] / x [FF1]
			  ,

-- self sufficiency
				[SSCalendar] / x [SSCalendar]
			  , [SSHousekeeping] / x [SSHousekeeping]
			  , [SSTransportation] / x [SSTransportation]
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

-- program activities
				[PAForms] / x [PAForms]
			  , [PAVideo] / x [PAVideo]
			  , [PAGroups] / x [PAGroups]
			  , [PAIFSP] / x [PAIFSP]
			  , [PARecreation] / x [PARecreation]
			  , [PAOther] / x [PAOther]
			  , [PA1] / x [PA1]
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
