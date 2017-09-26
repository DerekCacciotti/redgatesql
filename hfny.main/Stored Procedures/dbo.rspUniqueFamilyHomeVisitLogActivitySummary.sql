SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/30/2013
-- Description:	Unique Family Home Visit Log Activity Summary
-- =============================================
CREATE procedure [dbo].[rspUniqueFamilyHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@programfk int = null
   , @StartDt datetime
   , @EndDt datetime
   , @workerfk int = null
   , @pc1id varchar(13) = ''
   , @showWorkerDetail char(1) = 'N'
   , @showPC1IDDetail char(1) = 'N'
   , @SiteFK int = null
   , @CaseFiltersPositive varchar(200) = null
	)
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
;
	with	base1
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , x = count(distinct a.HVCaseFK)
						  , CompletedVisit = count(*)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and substring(a.VisitType, 4, 1) <> '1'
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
												else @pc1id
										   end
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
						  , CompletedVisit
						  , x [UniqueFamilies]
						  , case when x = 0 then 1
								 else x
							end x
				  from		base1
				 ) ,
			base0
			  as (select	case when @showWorkerDetail = 'N' then 0
								 else a.FSWFK
							end FSWFK
						  , case when @showPC1IDDetail = 'N' then ''
								 else cp.PC1ID
							end PC1ID
						  , AttemptedFamily = count(distinct a.HVCaseFK)
						  , Attempted = count(*)
				  from		HVLog as a
				  inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
				  inner join Worker fsw on a.FSWFK = fsw.workerpk
				  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
				  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
				  where		cast(VisitStartTime as date) between @StartDt and @EndDt
							and substring(a.VisitType, 4, 1) = '1'
							and a.FSWFK = isnull(@workerfk, a.FSWFK)
							and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
												else @pc1id
										   end
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
			base2
			  as (select	FSWFK
						  , PC1ID
						  , avg([AvgMinuteForCompletedVisit]) [AvgMinuteForCompletedVisit]
						  , sum(case when x.[InHome] > 0 then 1
									 else 0
								end) [InHome]
						  , sum(case when x.[OutOfHome] > 0 then 1
									 else 0
								end) [OutOfHome]
						  , sum(case when x.[BothInAndOutHome] > 0 then 1
									 else 0
								end) [BothInAndOutHome]
						  , sum(case when PC1Participated > 0 then 1
									 else 0
								end) [PC1Participated]
						  , sum(case when PC2Participated > 0 then 1
									 else 0
								end) [PC2Participated]
						  , sum(case when OBPParticipated > 0 then 1
									 else 0
								end) [OBPParticipated]
						  , sum(case when FatherFigureParticipated > 0 then 1
									 else 0
								end) [FatherFigureParticipated]
						  , sum(case when FatherAdvocateParticipated > 0 then 1
									 else 0
								end) [FatherAdvocateParticipated]
						  , sum(case when TCParticipated > 0 then 1
									 else 0
								end) [TCParticipated]
						  , sum(case when GrandParentParticipated > 0 then 1
									 else 0
								end) [GrandParentParticipated]
						  , sum(case when SiblingParticipated > 0 then 1
									 else 0
								end) [SiblingParticipated]
						  , sum(case when HVSupervisorParticipated > 0 then 1
									 else 0
								end) [HVSupervisorParticipated]
						  , sum(case when SupervisorObservation > 0 then 1
									 else 0
								end) [SupervisorObservation]
						  , sum(case when OtherParticipated > 0 then 1
									 else 0
								end) [OtherParticipated]


-- child development
						  , sum(case when CDChildDevelopment > 0 then 1
									 else 0
								end) [CDChildDevelopment]
						  , sum(case when CDToys > 0 then 1
									 else 0
								end) [CDToys]
						  , sum(case when CDParentConcerned > 0 then 1
									 else 0
								end) [CDParentConcerned]
						  , sum(case when CDSocialEmotionalDevelopment > 0 then 1
									 else 0
								end) [CDSocialEmotionalDevelopment]
						  , sum(case when CDFollowUpEIServices > 0 then 1
									 else 0
								end) [CDFollowUpEIServices]
						  , sum(case when CDOther > 0 then 1
									 else 0
								end) [CDOther]
						  , sum(case when CD1 > 0 then 1
									 else 0
								end) [CD1]
						  , sum(case when CD2 > 0 then 1
									 else 0
								end) [CD2]
-- parent child interaction
						  , sum(case when PCChildInteraction > 0 then 1
									 else 0
								end) [PCChildInteraction]
						  , sum(case when PCChildManagement > 0 then 1
									 else 0
								end) [PCChildManagement]
						  , sum(case when PCFeelings > 0 then 1
									 else 0
								end) [PCFeelings]
						  , sum(case when PCStress > 0 then 1
									 else 0
								end) [PCStress]
						  , sum(case when PCBasicNeeds > 0 then 1
									 else 0
								end) [PCBasicNeeds]
						  , sum(case when PCShakenBaby > 0 then 1
									 else 0
								end) [PCShakenBaby]
						  , sum(case when PCShakenBabyVideo > 0 then 1
									 else 0
								end) [PCShakenBabyVideo]
						  , sum(case when PCTechnologyEffects > 0 then 1
									 else 0
								end) [PCTechnologyEffects]
						  , sum(case when PCOther > 0 then 1
									 else 0
								end) [PCOther]
						  , sum(case when PC1 > 0 then 1
									 else 0
								end) [PC1]
						  , sum(case when PC2 > 0 then 1
									 else 0
								end) [PC2]
-- health care
						  , sum(case when HCGeneral > 0 then 1
									 else 0
								end) [HCGeneral]
						  , sum(case when HCChild > 0 then 1
									 else 0
								end) [HCChild]
						  , sum(case when HCDental > 0 then 1
									 else 0
								end) [HCDental]
						  , sum(case when HCFeeding > 0 then 1
									 else 0
								end) [HCFeeding]
						  , sum(case when HCBreastFeeding > 0 then 1
									 else 0
								end) [HCBreastFeeding]
						  , sum(case when HCNutrition > 0 then 1
									 else 0
								end) [HCNutrition]
						  , sum(case when HCFamilyPlanning > 0 then 1
									 else 0
								end) [HCFamilyPlanning]
						  , sum(case when HCProviders > 0 then 1
									 else 0
								end) [HCProviders]
						  , sum(case when HCFASD > 0 then 1
									 else 0
								end) [HCFASD]
						  , sum(case when HCSexEducation > 0 then 1
									 else 0
								end) [HCSexEducation]
						  , sum(case when HCPrenatalCare > 0 then 1
									 else 0
								end) [HCPrenatalCare]
						  , sum(case when HCMedicalAdvocacy > 0 then 1
									 else 0
								end) [HCMedicalAdvocacy]
						  , sum(case when HCSafety > 0 then 1
									 else 0
								end) [HCSafety]
						  , sum(case when HCSmoking > 0 then 1
									 else 0
								end) [HCSmoking]
						  , sum(case when HCSIDS > 0 then 1
									 else 0
								end) [HCSIDS]
						  , sum(case when HCOther > 0 then 1
									 else 0
								end) [HCOther]
						  , sum(case when HC1 > 0 then 1
									 else 0
								end) [HC1]
						  , sum(case when HC2 > 0 then 1
									 else 0
								end) [HC2]
-- family functioning
						  , sum(case when FFDomesticViolence > 0 then 1
									 else 0
								end) [FFDomesticViolence]
						  , sum(case when FFFamilyRelations > 0 then 1
									 else 0
								end) [FFFamilyRelations]
						  , sum(case when FFSubstanceAbuse > 0 then 1
									 else 0
								end) [FFSubstanceAbuse]
						  , sum(case when FFMentalHealth > 0 then 1
									 else 0
								end) [FFMentalHealth]
						  , sum(case when FFCommunication > 0 then 1
									 else 0
								end) [FFCommunication]
						  , sum(case when FFOther > 0 then 1
									 else 0
								end) [FFOther]
						  , sum(case when FF1 > 0 then 1
									 else 0
								end) [FF1]
						  , sum(case when FF2 > 0 then 1
									 else 0
								end) [FF2]
-- self sufficiency
						  , sum(case when SSCalendar > 0 then 1
									 else 0
								end) [SSCalendar]
						  , sum(case when SSHousekeeping > 0 then 1
									 else 0
								end) [SSHousekeeping]
						  , sum(case when SSTransportation > 0 then 1
									 else 0
								end) [SSTransportation]
						  , sum(case when SSEmployment > 0 then 1
									 else 0
								end) [SSEmployment]
						  , sum(case when SSMoneyManagement > 0 then 1
									 else 0
								end) [SSMoneyManagement]
						  , sum(case when SSChildCare > 0 then 1
									 else 0
								end) [SSChildCare]
						  , sum(case when SSProblemSolving > 0 then 1
									 else 0
								end) [SSProblemSolving]
						  , sum(case when SSEducation > 0 then 1
									 else 0
								end) [SSEducation]
						  , sum(case when SSJob > 0 then 1
									 else 0
								end) [SSJob]
						  , sum(case when SSOther > 0 then 1
									 else 0
								end) [SSOther]
						  , sum(case when SS1 > 0 then 1
									 else 0
								end) [SS1]
						  , sum(case when SS2 > 0 then 1
									 else 0
								end) [SS2]
-- crisis intervention
						  , sum(case when CIProblems > 0 then 1
									 else 0
								end) [CIProblems]
						  , sum(case when CIOther > 0 then 1
									 else 0
								end) [CIOther]
						  , sum(case when CI1 > 0 then 1
									 else 0
								end) [CI1]
						  , sum(case when CI2 > 0 then 1
									 else 0
								end) [CI2]
-- program activities
						  , sum(case when PAForms > 0 then 1
									 else 0
								end) [PAForms]
						  , sum(case when PAVideo > 0 then 1
									 else 0
								end) [PAVideo]
						  , sum(case when PAGroups > 0 then 1
									 else 0
								end) [PAGroups]
						  , sum(case when PAIFSP > 0 then 1
									 else 0
								end) [PAIFSP]
						  , sum(case when PARecreation > 0 then 1
									 else 0
								end) [PARecreation]
						  , sum(case when PAOther > 0 then 1
									 else 0
								end) [PAOther]
						  , sum(case when PA1 > 0 then 1
									 else 0
								end) [PA1]
						  , sum(case when PA2 > 0 then 1
									 else 0
								end) [PA2]
-- concrete activities
						  , sum(case when CATransportation > 0 then 1
									 else 0
								end) [CATransportation]
						  , sum(case when CAGoods > 0 then 1
									 else 0
								end) [CAGoods]
						  , sum(case when CALegal > 0 then 1
									 else 0
								end) [CALegal]
						  , sum(case when CAHousing > 0 then 1
									 else 0
								end) [CAHousing]
						  , sum(case when CAAdvocacy > 0 then 1
									 else 0
								end) [CAAdvocacy]
						  , sum(case when CATranslation > 0 then 1
									 else 0
								end) [CATranslation]
						  , sum(case when CALaborSupport > 0 then 1
									 else 0
								end) [CALaborSupport]
						  , sum(case when CAChildSupport > 0 then 1
									 else 0
								end) [CAChildSupport]
						  , sum(case when CAParentRights > 0 then 1
									 else 0
								end) [CAParentRights]
						  , sum(case when CAVisitation > 0 then 1
									 else 0
								end) [CAVisitation]
						  , sum(case when CAOther > 0 then 1
									 else 0
								end) [CAOther]
						  , sum(case when CA1 > 0 then 1
									 else 0
								end) [CA1]
						  , sum(case when CA2 > 0 then 1
									 else 0
								end) [CA2]
						  , sum([Total]) [Total]
				  from		(select	a.HVCaseFK
								  , case when @showWorkerDetail = 'N' then 0
										 else a.FSWFK
									end [FSWFK]
								  , case when @showPC1IDDetail = 'N' then ''
										 else cp.PC1ID
									end [PC1ID]
								  , avg(a.VisitLengthHour * 60 + a.VisitLengthMinute) [AvgMinuteForCompletedVisit]
								  , sum(case when (SUBSTRING(a.VisitType, 1, 1) = '1' 
											   OR SUBSTRING(a.VisitType, 2, 1) = '1'
											   OR SUBSTRING(a.VisitType, 3, 1) = '1')
											   AND SUBSTRING(a.VisitType, 5, 1) = '0' THEN 1
											 else 0
										end) [InHome]
								  , sum(case when SUBSTRING(a.VisitType, 5, 1) = '1' 
											 AND  SUBSTRING(a.VisitType, 1, 3) = '000' THEN 1
											 else 0
										end) [OutOfHome]
								  , sum(case when (SUBSTRING(a.VisitType, 1, 1) = '1' 
											   OR SUBSTRING(a.VisitType, 2, 1) = '1'
											   OR SUBSTRING(a.VisitType, 3, 1) = '1')
											   AND SUBSTRING(a.VisitType, 5, 1) = '1' then 1
											 else 0
										end) [BothInAndOutHome]
								  , sum(case when PC1Participated = 1 then 1
											 else 0
										end) [PC1Participated]
								  , sum(case when PC2Participated = 1 then 1
											 else 0
										end) [PC2Participated]
								  , sum(case when OBPParticipated = 1 then 1
											 else 0
										end) [OBPParticipated]
								  , sum(case when FatherFigureParticipated = 1 then 1
											 else 0
										end) [FatherFigureParticipated]
								  , sum(case when FatherAdvocateParticipated = 1 then 1
											 else 0
										end) [FatherAdvocateParticipated]
								  , sum(case when TCParticipated = 1 then 1
											 else 0
										end) [TCParticipated]
								  , sum(case when GrandParentParticipated = 1 then 1
											 else 0
										end) [GrandParentParticipated]
								  , sum(case when SiblingParticipated = 1 then 1
											 else 0
										end) [SiblingParticipated]
								  , sum(case when HVSupervisorParticipated = 1 then 1
											 else 0
										end) [HVSupervisorParticipated]
								  , sum(case when SupervisorObservation = 1 then 1
											 else 0
										end) [SupervisorObservation]
								  , sum(case when OtherParticipated = 1 then 1
											 else 0
										end) [OtherParticipated]
-- child development
								  , sum(case when CDChildDevelopment = 1  then 1
											 else 0
										end) [CDChildDevelopment]
								  , sum(case when CDToys = 1  then 1
											 else 0
										end) [CDToys]
								  , sum(case when CDParentConcerned = 1  then 1
											 else 0
										end) [CDParentConcerned]
								  , sum(case when CDSocialEmotionalDevelopment = 1  then 1
											 else 0
										end) [CDSocialEmotionalDevelopment]
								  , sum(case when CDFollowUpEIServices = 1  then 1
											 else 0
										end) [CDFollowUpEIServices]
								  , sum(case when CDOther = 1  then 1
											 else 0
										end) [CDOther]
								  , sum(case when CDChildDevelopment = 1 
												  or CDToys = 1 
												  OR CDParentConcerned = 1
												  OR CDSocialEmotionalDevelopment = 1
												  OR CDFollowUpEIServices = 1
												  or CDOther = 1  then 1
											 else 0
										end) [CD1]
								  , sum(case when CDChildDevelopment = 1 
												  or CDToys = 1
												  OR CDParentConcerned = 1 
												  OR CDSocialEmotionalDevelopment = 1
												  OR CDFollowUpEIServices = 1
												  or CDOther = 1  then 1
											 else 0
										end) [CD2]
-- parent child interaction
								  , sum(case when PCChildInteraction = 1  then 1
											 else 0
										end) [PCChildInteraction]
								  , sum(case when PCChildManagement = 1  then 1
											 else 0
										end) [PCChildManagement]
								  , sum(case when PCFeelings = 1  then 1
											 else 0
										end) [PCFeelings]
								  , sum(case when PCStress = 1  then 1
											 else 0
										end) [PCStress]
								  , sum(case when PCBasicNeeds = 1  then 1
											 else 0
										end) [PCBasicNeeds]
								  , sum(case when PCShakenBaby = 1  then 1
											 else 0
										end) [PCShakenBaby]
								  , sum(case when PCShakenBabyVideo = 1  then 1
											 else 0
										end) [PCShakenBabyVideo]
								  , sum(case when PCTechnologyEffects = 1  then 1
											 else 0
										end) [PCTechnologyEffects]
								  , sum(case when PCOther = 1  then 1
											 else 0
										end) [PCOther]
								  , sum(case when PCChildInteraction = 1 
												  or  PCChildManagement = 1 
												  or  PCFeelings = 1 
												  or  PCStress = 1 
												  or  PCBasicNeeds = 1 
												  or  PCShakenBaby = 1 
												  or  PCShakenBabyVideo = 1 
												  OR  PCTechnologyEffects = 1 
												  or  PCOther = 1  then 1
											 else 0
										end) [PC1]
								  , sum(case when PCChildInteraction = 1 
												  or  PCChildManagement = 1 
												  or  PCFeelings = 1 
												  or  PCStress = 1 
												  or  PCBasicNeeds = 1 
												  or  PCShakenBaby = 1 
												  or  PCShakenBabyVideo = 1
												  OR  PCTechnologyEffects = 1  
												  or  PCOther = 1  then 1
											 else 0
										end) [PC2]
-- health care
								  , sum(case when  HCGeneral = 1   then 1
											 else 0
										end) [HCGeneral]
								  , sum(case when  HCChild = 1   then 1
											 else 0
										end) [HCChild]
								  , sum(case when  HCDental = 1   then 1
											 else 0
										end) [HCDental]
								  , sum(case when  HCFeeding = 1   then 1
											 else 0
										end) [HCFeeding]
								  , sum(case when  HCBreastFeeding = 1   then 1
											 else 0
										end) [HCBreastFeeding]
								  , sum(case when  HCNutrition = 1   then 1
											 else 0
										end) [HCNutrition]
								  , sum(case when  HCFamilyPlanning = 1   then 1
											 else 0
										end) [HCFamilyPlanning]
								  , sum(case when  HCProviders = 1   then 1
											 else 0
										end) [HCProviders]
								  , sum(case when  HCFASD = 1   then 1
											 else 0
										end) [HCFASD]
								  , sum(case when  HCSexEducation = 1   then 1
											 else 0
										end) [HCSexEducation]
								  , sum(case when  HCPrenatalCare = 1   then 1
											 else 0
										end) [HCPrenatalCare]
								  , sum(case when  HCMedicalAdvocacy = 1   then 1
											 else 0
										end) [HCMedicalAdvocacy]
								  , sum(case when  HCSafety = 1   then 1
											 else 0
										end) [HCSafety]
								  , sum(case when  HCSmoking = 1   then 1
											 else 0
										end) [HCSmoking]
								  , sum(case when  HCSIDS = 1   then 1
											 else 0
										end) [HCSIDS]
								  , sum(case when  HCOther = 1   then 1
											 else 0
										end) [HCOther]
								  , sum(case when  HCGeneral = 1  
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
										end) [HC1]
								  , sum(case when  HCGeneral = 1  
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
										end) [HC2]
-- family funvtioning
								  , sum(case when FFDomesticViolence = 1   then 1
											 else 0
										end) [FFDomesticViolence]
								  , sum(case when FFFamilyRelations = 1   then 1
											 else 0
										end) [FFFamilyRelations]
								  , sum(case when FFSubstanceAbuse = 1   then 1
											 else 0
										end) [FFSubstanceAbuse]
								  , sum(case when FFMentalHealth = 1   then 1
											 else 0
										end) [FFMentalHealth]
								  , sum(case when FFCommunication = 1   then 1
											 else 0
										end) [FFCommunication]
								  , sum(case when FFOther = 1   then 1
											 else 0
										end) [FFOther]
								  , sum(case when FFDomesticViolence = 1  
												  or FFFamilyRelations = 1  
												  or FFSubstanceAbuse = 1  
												  or FFMentalHealth = 1  
												  or FFCommunication = 1  
												  or FFOther = 1   then 1
											 else 0
										end) [FF1]
								  , sum(case when FFDomesticViolence = 1  
												  or FFFamilyRelations = 1  
												  or FFSubstanceAbuse = 1  
												  or FFMentalHealth = 1  
												  or FFCommunication = 1  
												  or FFOther = 1   then 1
											 else 0
										end) [FF2]
-- self sufficiency
								  , sum(case when SSCalendar = 1  then 1
											 else 0
										end) [SSCalendar]
								  , sum(case when SSHousekeeping = 1  then 1
											 else 0
										end) [SSHousekeeping]
								  , sum(case when SSTransportation = 1  then 1
											 else 0
										end) [SSTransportation]
								  , sum(case when SSEmployment = 1  then 1
											 else 0
										end) [SSEmployment]
								  , sum(case when SSMoneyManagement = 1  then 1
											 else 0
										end) [SSMoneyManagement]
								  , sum(case when SSChildCare = 1  then 1
											 else 0
										end) [SSChildCare]
								  , sum(case when SSProblemSolving = 1  then 1
											 else 0
										end) [SSProblemSolving]
								  , sum(case when SSEducation = 1  then 1
											 else 0
										end) [SSEducation]
								  , sum(case when SSJob = 1  then 1
											 else 0
										end) [SSJob]
								  , sum(case when SSOther = 1  then 1
											 else 0
										end) [SSOther]
								  , sum(case when SSCalendar = 1 
												  or SSHousekeeping = 1 
												  or SSTransportation = 1 
												  or SSEmployment = 1 
												  or SSMoneyManagement = 1 
												  or SSChildCare = 1 
												  or SSProblemSolving = 1 
												  or SSEducation = 1 
												  or SSJob = 1 
												  or SSOther = 1  then 1
											 else 0
										end) [SS1]
								  , sum(case when SSCalendar = 1 
												  or SSHousekeeping = 1 
												  or SSTransportation = 1 
												  or SSEmployment = 1 
												  or SSMoneyManagement = 1 
												  or SSChildCare = 1 
												  or SSProblemSolving = 1 
												  or SSEducation = 1 
												  or SSJob = 1 
												  or SSOther = 1  then 1
											 else 0
										end) [SS2]
-- crisis intervention
								  , sum(case when CIProblems = 1  then 1
											 else 0
										end) [CIProblems]
								  , sum(case when CIOther = 1  then 1
											 else 0
										end) [CIOther]
								  , sum(case when CIProblems = 1 
												  or CIOther = 1  then 1
											 else 0
										end) [CI1]
								  , sum(case when CIProblems = 1 
												  or CIOther = 1  then 1
											 else 0
										end) [CI2]
-- program activities
								  , sum(case when PAForms = 1  then 1
											 else 0
										end) [PAForms]
								  , sum(case when PAVideo = 1  then 1
											 else 0
										end) [PAVideo]
								  , sum(case when PAGroups = 1  then 1
											 else 0
										end) [PAGroups]
								  , sum(case when PAIFSP = 1  then 1
											 else 0
										end) [PAIFSP]
								  , sum(case when PARecreation = 1  then 1
											 else 0
										end) [PARecreation]
								  , sum(case when PAOther = 1  then 1
											 else 0
										end) [PAOther]
								  , sum(case when PAForms = 1 
												  or PAVideo = 1 
												  or PAGroups = 1 
												  or PAIFSP = 1 
												  or PARecreation = 1 
												  or PAOther = 1  then 1
											 else 0
										end) [PA1]
								  , sum(case when PAForms = 1 
												  or PAVideo = 1 
												  or PAGroups = 1 
												  or PAIFSP = 1 
												  or PARecreation = 1 
												  or PAOther = 1  then 1
											 else 0
										end) [PA2]
-- concrete activities
								  , sum(case when CATransportation = 1  then 1
											 else 0
										end) [CATransportation]
								  , sum(case when CAGoods = 1  then 1
											 else 0
										end) [CAGoods]
								  , sum(case when CALegal = 1  then 1
											 else 0
										end) [CALegal]
								  , sum(case when CAHousing = 1  then 1
											 else 0
										end) [CAHousing]
								  , sum(case when CAAdvocacy = 1  then 1
											 else 0
										end) [CAAdvocacy]
								  , sum(case when CATranslation = 1  then 1
											 else 0
										end) [CATranslation]
								  , sum(case when CALaborSupport = 1  then 1
											 else 0
										end) [CALaborSupport]
								  , sum(case when CAChildSupport = 1  then 1
											 else 0
										end) [CAChildSupport]
								  , sum(case when CAParentRights = 1  then 1
											 else 0
										end) [CAParentRights]
								  , sum(case when CAVisitation = 1  then 1
											 else 0
										end) [CAVisitation]
								  , sum(case when CAOther = 1  then 1
											 else 0
										end) [CAOther]
								  , sum(case when CATransportation = 1 
												  or CAGoods = 1 
												  or CALegal = 1 
												  or CALegal = 1 
												  or CAHousing = 1 
												  or CAAdvocacy = 1 
												  or CATranslation = 1 
												  or CALaborSupport = 1 
												  or CAChildSupport = 1 
												  or CAVisitation = 1 
												  or CAOther = 1  then 1
											 else 0
										end) [CA1]
								  , sum(case when CATransportation = 1 
												  or CAGoods = 1 
												  or CALegal = 1 
												  or CALegal = 1 
												  or CAHousing = 1 
												  or CAAdvocacy = 1 
												  or CATranslation = 1 
												  or CALaborSupport = 1 
												  or CAChildSupport = 1 
												  or CAVisitation = 1 
												  or CAOther = 1  then 1
											 else 0
										end) [CA2]
								  , count(*) [Total]
							 from	HVLog as a
							 inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK and cp.ProgramFK = @programfk
							 inner join Worker fsw on a.FSWFK = fsw.workerpk
							 inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = cp.ProgramFK
							 inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
							 where	substring(a.VisitType, 4, 1) <> '1'
									and cast(a.VisitStartTime as date) between @StartDt and @EndDt
									and a.FSWFK = isnull(@workerfk, a.FSWFK)
									and cp.PC1ID = case	when @pc1id = '' then cp.PC1ID
														else @pc1id
												   end
									and case when @SiteFK = 0 then 1
											 when wp.SiteFK = @SiteFK then 1
											 else 0
										end = 1
							 group by a.HVCaseFK
								  , case when @showWorkerDetail = 'N' then 0
										 else a.FSWFK
									end
								  , case when @showPC1IDDetail = 'N' then ''
										 else cp.PC1ID
									end
							) as x
				  group by	FSWFK
						  , PC1ID
				 )
		select	a.*
			  , d.AttemptedFamily
			  , d.Attempted
			  , [AvgMinuteForCompletedVisit]
			  , [InHome]
			  , [OutOfHome]
			  , [BothInAndOutHome]
			  , [PC1Participated]
			  , [PC2Participated]
			  , [OBPParticipated]
			  , [FatherFigureParticipated]
			  , [FatherAdvocateParticipated]
			  , [TCParticipated]
			  , [GrandParentParticipated]
			  , [SiblingParticipated]
			  , [HVSupervisorParticipated]
			  , [SupervisorObservation]
			  , [OtherParticipated]
			  ,

-- child development
				[CDChildDevelopment] [CDChildDevelopment]
			  , [CDToys] [CDToys]
			  , [CDParentConcerned] [CDParentConcerned]
			  , [CDSocialEmotionalDevelopment] [CDSocialEmotionalDevelopment] 
			  , [CDFollowUpEIServices] [CDFollowUpEIServices]
			  , [CDOther] [CDOther]
			  , [CD1] [CD1]
			  , [CD2] [CD2]
			  ,

-- parent/child interaction
				[PCChildInteraction] [PCChildInteraction]
			  , [PCChildManagement] [PCChildManagement]
			  , [PCFeelings] [PCFeelings]
			  , [PCStress] [PCStress]
			  , [PCBasicNeeds] [PCBasicNeeds]
			  , [PCShakenBaby] [PCShakenBaby]
			  , [PCShakenBabyVideo] [PCShakenBabyVideo]
			  , [PCTechnologyEffects] [PCTechnologyEffects]
			  , [PCOther] [PCOther]
			  , [PC1] [PC1]
			  , [PC2] [PC2]
			  ,

-- Health care
				[HCGeneral] [HCGeneral]
			  , [HCChild] [HCChild]
			  , [HCDental] [HCDental]
			  , [HCFeeding] [HCFeeding]
			  , [HCBreastFeeding] [HCBreastFeeding]
			  , [HCNutrition] [HCNutrition]
			  , [HCFamilyPlanning] [HCFamilyPlanning]
			  , [HCProviders] [HCProviders]
			  , [HCFASD] [HCFASD]
			  , [HCSexEducation] [HCSexEducation]
			  , [HCPrenatalCare] [HCPrenatalCare]
			  , [HCMedicalAdvocacy] [HCMedicalAdvocacy]
			  , [HCSafety] [HCSafety]
			  , [HCSmoking] [HCSmoking]
			  , [HCSIDS] [HCSIDS]
			  , [HCOther] [HCOther]
			  , [HCOther] [HCOther]
			  , [HC1] [HC1]
			  , [HC2] [HC2]
			  ,

-- family functioning
				[FFDomesticViolence] [FFDomesticViolence]
			  , [FFFamilyRelations] [FFFamilyRelations]
			  , [FFSubstanceAbuse] [FFSubstanceAbuse]
			  , [FFMentalHealth] [FFMentalHealth]
			  , [FFCommunication] [FFCommunication]
			  , [FFOther] [FFOther]
			  , [FF1] [FF1]
			  , [FF2] [FF2]
			  ,

-- self sufficiency
				[SSCalendar] [SSCalendar]
			  , [SSHousekeeping] [SSHousekeeping]
			  , [SSTransportation] [SSTransportation]
			  , [SSEmployment] [SSEmployment]
			  , [SSMoneyManagement] [SSMoneyManagement]
			  , [SSChildCare] [SSChildCare]
			  , [SSProblemSolving] [SSProblemSolving]
			  , [SSEducation] [SSEducation]
			  , [SSJob] [SSJob]
			  , [SSOther] [SSOther]
			  , [SS1] [SS1]
			  , [SS2] [SS2]
			  ,

-- crisis intervention
				[CIProblems] [CIProblems]
			  , [CIOther] [CIOther]
			  , [CI1] [CI1]
			  , [CI2] [CI2]
			  ,

-- program activities
				[PAForms] [PAForms]
			  , [PAVideo] [PAVideo]
			  , [PAGroups] [PAGroups]
			  , [PAIFSP] [PAIFSP]
			  , [PARecreation] [PARecreation]
			  , [PAOther] [PAOther]
			  , [PA1] [PA1]
			  , [PA2] [PA2]
			  ,

-- concrete activities
				[CATransportation] [CATransportation]
			  , [CAGoods] [CAGoods]
			  , [CALegal] [CALegal]
			  , [CAHousing] [CAHousing]
			  , [CAAdvocacy] [CAAdvocacy]
			  , [CATranslation] [CATranslation]
			  , [CALaborSupport] [CALaborSupport]
			  , [CAChildSupport] [CAChildSupport]
			  , [CAParentRights] [CAParentRights]
			  , [CAVisitation] [CAVisitation]
			  , [CAOther] [CAOther]
			  , [CA1] [CA1]
			  , [CA2] [CA2]
			  , [Total]
			  , case when c.WorkerPK is null then 'All Workers'
					 else rtrim(c.LastName) + ', ' + rtrim(c.FirstName)
				end WorkerName
		from	base11 as a
		full outer join base2 as b on a.FSWFK = b.FSWFK
									  and a.PC1ID = b.PC1ID
		full outer join base0 as d on a.FSWFK = d.FSWFK
									  and a.PC1ID = d.PC1ID
		left outer join Worker as c on case	when (@showWorkerDetail = 'N'
												  and @workerfk is not null
												 ) then @workerfk
											else a.FSWFK
									   end = c.WorkerPK
		order by WorkerName
			  , a.PC1ID
GO
