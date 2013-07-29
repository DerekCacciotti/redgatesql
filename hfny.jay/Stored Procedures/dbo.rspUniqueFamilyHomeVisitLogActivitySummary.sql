
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 04/30/2013
-- Description:	Unique Family Home Visit Log Activity Summary
-- =============================================
CREATE PROCEDURE [dbo].[rspUniqueFamilyHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt DATETIME,
	@workerfk INT = NULL,
	@pc1id VARCHAR(13) = '',
	@showWorkerDetail CHAR(1) = 'N',
	@showPC1IDDetail CHAR(1) = 'N')

AS

--DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '09/30/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'

;WITH base1 AS (
SELECT 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
,CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID
,x = count(DISTINCT a.HVCaseFK)
,CompletedVisit = count(*)
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt
AND substring(a.VisitType,4,1) <> '1'
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
)

, base11 AS (
SELECT FSWFK, PC1ID
, CompletedVisit
, x [UniqueFamilies]
, CASE WHEN x = 0 THEN 1 ELSE x END x FROM base1
)

, base0 AS (
SELECT 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
,CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID
,AttemptedFamily = count(DISTINCT a.HVCaseFK)
,Attempted = count(*)
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt
AND substring(a.VisitType,4,1) = '1'
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
)

, base2 AS (
SELECT 
FSWFK, PC1ID
,avg([AvgMinuteForCompletedVisit]) [AvgMinuteForCompletedVisit]
,sum(CASE WHEN x.[InHome] > 0 THEN 1 ELSE 0 END) [InHome]
,sum(CASE WHEN x.[OutOfHome] > 0 THEN 1 ELSE 0 END) [OutOfHome]
,sum(CASE WHEN x.[BothInAndOutHome] > 0 THEN 1 ELSE 0 END) [BothInAndOutHome]
,sum(CASE WHEN PC1Participated > 0 THEN 1 ELSE 0 END) [PC1Participated]
,sum(CASE WHEN PC2Participated  > 0 THEN 1 ELSE 0 END) [PC2Participated]
,sum(CASE WHEN OBPParticipated  > 0 THEN 1 ELSE 0 END) [OBPParticipated]
,sum(CASE WHEN FatherFigureParticipated  > 0 THEN 1 ELSE 0 END) [FatherFigureParticipated]
,sum(CASE WHEN TCParticipated  > 0 THEN 1 ELSE 0 END) [TCParticipated]
,sum(CASE WHEN GrandParentParticipated  > 0 THEN 1 ELSE 0 END) [GrandParentParticipated]
,sum(CASE WHEN SiblingParticipated  > 0 THEN 1 ELSE 0 END) [SiblingParticipated]
,sum(CASE WHEN NonPrimaryFSWParticipated  > 0 THEN 1 ELSE 0 END) [NonPrimaryFSWParticipated]
,sum(CASE WHEN HVSupervisorParticipated  > 0 THEN 1 ELSE 0 END) [HVSupervisorParticipated]
,sum(CASE WHEN SupervisorObservation  > 0 THEN 1 ELSE 0 END) [SupervisorObservation]
,sum(CASE WHEN OtherParticipated  > 0 THEN 1 ELSE 0 END) [OtherParticipated]

-- child development
,sum(CASE WHEN CDChildDevelopment > 0 THEN 1 ELSE 0 END) [CDChildDevelopment]
,sum(CASE WHEN CDChildDevelopmentNon > 0 THEN 1 ELSE 0 END) [CDChildDevelopmentNon]
,sum(CASE WHEN CDToys > 0 THEN 1 ELSE 0 END) [CDToys]
,sum(CASE WHEN CDToysNon > 0 THEN 1 ELSE 0 END) [CDToysNon]
,sum(CASE WHEN CDOther > 0 THEN 1 ELSE 0 END) [CDOther]
,sum(CASE WHEN CDOtherNon > 0 THEN 1 ELSE 0 END) [CDOtherNon]
,sum(CASE WHEN CD1 > 0 THEN 1 ELSE 0 END) [CD1]
,sum(CASE WHEN CD2 > 0 THEN 1 ELSE 0 END) [CD2]
-- parent child interaction
,sum(CASE WHEN PCChildInteraction > 0  THEN 1 ELSE 0 END) [PCChildInteraction]
,sum(CASE WHEN PCChildInteractionNon > 0  THEN 1 ELSE 0 END) [PCChildInteractionNon]
,sum(CASE WHEN PCChildManagement > 0  THEN 1 ELSE 0 END) [PCChildManagement]
,sum(CASE WHEN PCChildManagementNon > 0  THEN 1 ELSE 0 END) [PCChildManagementNon]
,sum(CASE WHEN PCFeelings > 0  THEN 1 ELSE 0 END) [PCFeelings]
,sum(CASE WHEN PCFeelingsNon > 0  THEN 1 ELSE 0 END) [PCFeelingsNon]
,sum(CASE WHEN PCStress > 0  THEN 1 ELSE 0 END) [PCStress]
,sum(CASE WHEN PCStressNon > 0  THEN 1 ELSE 0 END) [PCStressNon]
,sum(CASE WHEN PCBasicNeeds > 0  THEN 1 ELSE 0 END) [PCBasicNeeds]
,sum(CASE WHEN PCBasicNeedsNon > 0  THEN 1 ELSE 0 END) [PCBasicNeedsNon]
,sum(CASE WHEN PCShakenBaby > 0  THEN 1 ELSE 0 END) [PCShakenBaby]
,sum(CASE WHEN PCShakenBabyNon > 0  THEN 1 ELSE 0 END) [PCShakenBabyNon]
,sum(CASE WHEN PCShakenBabyVideo > 0  THEN 1 ELSE 0 END) [PCShakenBabyVideo]
,sum(CASE WHEN PCShakenBabyVideoNon > 0  THEN 1 ELSE 0 END) [PCShakenBabyVideoNon]
,sum(CASE WHEN PCOther > 0  THEN 1 ELSE 0 END) [PCOther]
,sum(CASE WHEN PCOtherNon > 0  THEN 1 ELSE 0 END) [PCOtherNon]
,sum(CASE WHEN PC1 > 0 THEN 1 ELSE 0 END) [PC1]
,sum(CASE WHEN PC2 > 0 THEN 1 ELSE 0 END) [PC2]
-- health care
,sum(CASE WHEN HCGeneral > 0 THEN 1 ELSE 0 END) [HCGeneral]
,sum(CASE WHEN HCGeneralNon > 0 THEN 1 ELSE 0 END) [HCGeneralNon]
,sum(CASE WHEN HCChild > 0 THEN 1 ELSE 0 END) [HCChild]
,sum(CASE WHEN HCChildNon > 0 THEN 1 ELSE 0 END) [HCChildNon]
,sum(CASE WHEN HCDental > 0 THEN 1 ELSE 0 END) [HCDental]
,sum(CASE WHEN HCDentalNon > 0 THEN 1 ELSE 0 END) [HCDentalNon]
,sum(CASE WHEN HCFeeding > 0 THEN 1 ELSE 0 END) [HCFeeding]
,sum(CASE WHEN HCFeedingNon > 0 THEN 1 ELSE 0 END) [HCFeedingNon]
,sum(CASE WHEN HCBreastFeeding > 0 THEN 1 ELSE 0 END) [HCBreastFeeding]
,sum(CASE WHEN HCBreastFeedingNon > 0 THEN 1 ELSE 0 END) [HCBreastFeedingNon]
,sum(CASE WHEN HCNutrition > 0 THEN 1 ELSE 0 END) [HCNutrition]
,sum(CASE WHEN HCNutritionNon > 0 THEN 1 ELSE 0 END) [HCNutritionNon]
,sum(CASE WHEN HCFamilyPlanning > 0 THEN 1 ELSE 0 END) [HCFamilyPlanning]
,sum(CASE WHEN HCFamilyPlanningNon > 0 THEN 1 ELSE 0 END) [HCFamilyPlanningNon]
,sum(CASE WHEN HCProviders > 0 THEN 1 ELSE 0 END) [HCProviders]
,sum(CASE WHEN HCProvidersNon > 0 THEN 1 ELSE 0 END) [HCProvidersNon]
,sum(CASE WHEN HCFASD > 0 THEN 1 ELSE 0 END) [HCFASD]
,sum(CASE WHEN HCFASDNon > 0 THEN 1 ELSE 0 END) [HCFASDNon]
,sum(CASE WHEN HCSexEducation > 0 THEN 1 ELSE 0 END) [HCSexEducation]
,sum(CASE WHEN HCSexEducationNon > 0 THEN 1 ELSE 0 END) [HCSexEducationNon]
,sum(CASE WHEN HCPrenatalCare > 0 THEN 1 ELSE 0 END) [HCPrenatalCare]
,sum(CASE WHEN HCPrenatalCareNon > 0 THEN 1 ELSE 0 END) [HCPrenatalCareNon]
,sum(CASE WHEN HCMedicalAdvocacy > 0 THEN 1 ELSE 0 END) [HCMedicalAdvocacy]
,sum(CASE WHEN HCMedicalAdvocacyNon > 0 THEN 1 ELSE 0 END) [HCMedicalAdvocacyNon]
,sum(CASE WHEN HCSafety > 0 THEN 1 ELSE 0 END) [HCSafety]
,sum(CASE WHEN HCSafetyNon > 0 THEN 1 ELSE 0 END) [HCSafetyNon]
,sum(CASE WHEN HCSmoking > 0 THEN 1 ELSE 0 END) [HCSmoking]
,sum(CASE WHEN HCSmokingNon > 0 THEN 1 ELSE 0 END) [HCSmokingNon]
,sum(CASE WHEN HCSIDS > 0 THEN 1 ELSE 0 END) [HCSIDS]
,sum(CASE WHEN HCSIDSNon > 0 THEN 1 ELSE 0 END) [HCSIDSNon]
,sum(CASE WHEN HCOther > 0 THEN 1 ELSE 0 END) [HCOther]
,sum(CASE WHEN HCOtherNon > 0 THEN 1 ELSE 0 END) [HCOtherNon]
,sum(CASE WHEN HC1 > 0 THEN 1 ELSE 0 END) [HC1]
,sum(CASE WHEN HC2 > 0 THEN 1 ELSE 0 END) [HC2]
-- family functioning
,sum(CASE WHEN FFDomesticViolence > 0 THEN 1 ELSE 0 END) [FFDomesticViolence]
,sum(CASE WHEN FFDomesticViolenceNon > 0 THEN 1 ELSE 0 END) [FFDomesticViolenceNon]
,sum(CASE WHEN FFFamilyRelations > 0 THEN 1 ELSE 0 END) [FFFamilyRelations]
,sum(CASE WHEN FFFamilyRelationsNon > 0 THEN 1 ELSE 0 END) [FFFamilyRelationsNon]
,sum(CASE WHEN FFSubstanceAbuse > 0 THEN 1 ELSE 0 END) [FFSubstanceAbuse]
,sum(CASE WHEN FFSubstanceAbuseNon > 0 THEN 1 ELSE 0 END) [FFSubstanceAbuseNon]
,sum(CASE WHEN FFMentalHealth > 0 THEN 1 ELSE 0 END) [FFMentalHealth]
,sum(CASE WHEN FFMentalHealthNon > 0 THEN 1 ELSE 0 END) [FFMentalHealthNon]
,sum(CASE WHEN FFCommunication > 0 THEN 1 ELSE 0 END) [FFCommunication]
,sum(CASE WHEN FFCommunicationNon > 0 THEN 1 ELSE 0 END) [FFCommunicationNon]
,sum(CASE WHEN FFOther > 0 THEN 1 ELSE 0 END) [FFOther]
,sum(CASE WHEN FFOtherNon > 0 THEN 1 ELSE 0 END) [FFOtherNon]
,sum(CASE WHEN FF1 > 0 THEN 1 ELSE 0 END) [FF1]
,sum(CASE WHEN FF2 > 0 THEN 1 ELSE 0 END) [FF2]
-- self sufficiency
,sum(CASE WHEN SSCalendar > 0 THEN 1 ELSE 0 END) [SSCalendar]
,sum(CASE WHEN SSCalendarNon > 0 THEN 1 ELSE 0 END) [SSCalendarNon]
,sum(CASE WHEN SSHousekeeping > 0 THEN 1 ELSE 0 END) [SSHousekeeping]
,sum(CASE WHEN SSHousekeepingNon > 0 THEN 1 ELSE 0 END) [SSHousekeepingNon]
,sum(CASE WHEN SSTransportation > 0 THEN 1 ELSE 0 END) [SSTransportation]
,sum(CASE WHEN SSTransportationNon > 0 THEN 1 ELSE 0 END) [SSTransportationNon]
,sum(CASE WHEN SSEmployment > 0 THEN 1 ELSE 0 END) [SSEmployment]
,sum(CASE WHEN SSEmploymentNon > 0 THEN 1 ELSE 0 END) [SSEmploymentNon]
,sum(CASE WHEN SSMoneyManagement > 0 THEN 1 ELSE 0 END) [SSMoneyManagement]
,sum(CASE WHEN SSMoneyManagementNon > 0 THEN 1 ELSE 0 END) [SSMoneyManagementNon]
,sum(CASE WHEN SSChildCare > 0 THEN 1 ELSE 0 END) [SSChildCare]
,sum(CASE WHEN SSChildCareNon > 0 THEN 1 ELSE 0 END) [SSChildCareNon]
,sum(CASE WHEN SSProblemSolving > 0 THEN 1 ELSE 0 END) [SSProblemSolving]
,sum(CASE WHEN SSProblemSolvingNon > 0 THEN 1 ELSE 0 END) [SSProblemSolvingNon]
,sum(CASE WHEN SSEducation > 0 THEN 1 ELSE 0 END) [SSEducation]
,sum(CASE WHEN SSEducationNon > 0 THEN 1 ELSE 0 END) [SSEducationNon]
,sum(CASE WHEN SSJob > 0 THEN 1 ELSE 0 END) [SSJob]
,sum(CASE WHEN SSJobNon > 0 THEN 1 ELSE 0 END) [SSJobNon]
,sum(CASE WHEN SSOther > 0 THEN 1 ELSE 0 END) [SSOther]
,sum(CASE WHEN SSOtherNon > 0 THEN 1 ELSE 0 END) [SSOtherNon]
,sum(CASE WHEN SS1 > 0 THEN 1 ELSE 0 END) [SS1]
,sum(CASE WHEN SS2 > 0 THEN 1 ELSE 0 END) [SS2]
-- crisis intervention
,sum(CASE WHEN CIProblems > 0 THEN 1 ELSE 0 END) [CIProblems]
,sum(CASE WHEN CIProblemsNon > 0 THEN 1 ELSE 0 END) [CIProblemsNon]
,sum(CASE WHEN CIOther > 0 THEN 1 ELSE 0 END) [CIOther]
,sum(CASE WHEN CIOtherNon > 0 THEN 1 ELSE 0 END) [CIOtherNon]
,sum(CASE WHEN CI1 > 0 THEN 1 ELSE 0 END) [CI1]
,sum(CASE WHEN CI2 > 0 THEN 1 ELSE 0 END) [CI2]
-- program activities
,sum(CASE WHEN PAForms > 0 THEN 1 ELSE 0 END) [PAForms]
,sum(CASE WHEN PAFormsNon > 0 THEN 1 ELSE 0 END) [PAFormsNon]
,sum(CASE WHEN PAVideo > 0 THEN 1 ELSE 0 END) [PAVideo]
,sum(CASE WHEN PAVideoNon > 0 THEN 1 ELSE 0 END) [PAVideoNon]
,sum(CASE WHEN PAGroups > 0 THEN 1 ELSE 0 END) [PAGroups]
,sum(CASE WHEN PAGroupsNon > 0 THEN 1 ELSE 0 END) [PAGroupsNon]
,sum(CASE WHEN PAIFSP > 0 THEN 1 ELSE 0 END) [PAIFSP]
,sum(CASE WHEN PAIFSPNon > 0 THEN 1 ELSE 0 END) [PAIFSPNon]
,sum(CASE WHEN PARecreation > 0 THEN 1 ELSE 0 END) [PARecreation]
,sum(CASE WHEN PARecreationNon > 0 THEN 1 ELSE 0 END) [PARecreationNon]
,sum(CASE WHEN PAOther > 0 THEN 1 ELSE 0 END) [PAOther]
,sum(CASE WHEN PAOtherNon > 0 THEN 1 ELSE 0 END) [PAOtherNon]
,sum(CASE WHEN PA1 > 0 THEN 1 ELSE 0 END) [PA1]
,sum(CASE WHEN PA2 > 0 THEN 1 ELSE 0 END) [PA2]
-- concrete activities
,sum(CASE WHEN CATransportation > 0 THEN 1 ELSE 0 END) [CATransportation]
,sum(CASE WHEN CATransportationNon > 0 THEN 1 ELSE 0 END) [CATransportationNon]
,sum(CASE WHEN CAGoods > 0 THEN 1 ELSE 0 END) [CAGoods]
,sum(CASE WHEN CAGoodsNon > 0 THEN 1 ELSE 0 END) [CAGoodsNon]
,sum(CASE WHEN CALegal > 0 THEN 1 ELSE 0 END) [CALegal]
,sum(CASE WHEN CALegalNon > 0 THEN 1 ELSE 0 END) [CALegalNon]
,sum(CASE WHEN CAHousing > 0 THEN 1 ELSE 0 END) [CAHousing]
,sum(CASE WHEN CAHousingNon > 0 THEN 1 ELSE 0 END) [CAHousingNon]
,sum(CASE WHEN CAAdvocacy > 0 THEN 1 ELSE 0 END) [CAAdvocacy]
,sum(CASE WHEN CAAdvocacyNon > 0 THEN 1 ELSE 0 END) [CAAdvocacyNon]
,sum(CASE WHEN CATranslation > 0 THEN 1 ELSE 0 END) [CATranslation]
,sum(CASE WHEN CATranslationNon > 0 THEN 1 ELSE 0 END) [CATranslationNon]
,sum(CASE WHEN CALaborSupport > 0 THEN 1 ELSE 0 END) [CALaborSupport]
,sum(CASE WHEN CALaborSupportNon > 0 THEN 1 ELSE 0 END) [CALaborSupportNon]
,sum(CASE WHEN CAChildSupport > 0 THEN 1 ELSE 0 END) [CAChildSupport]
,sum(CASE WHEN CAChildSupportNon > 0 THEN 1 ELSE 0 END) [CAChildSupportNon]
,sum(CASE WHEN CAParentRights > 0 THEN 1 ELSE 0 END) [CAParentRights]
,sum(CASE WHEN CAParentRightsNon > 0 THEN 1 ELSE 0 END) [CAParentRightsNon]
,sum(CASE WHEN CAVisitation > 0 THEN 1 ELSE 0 END) [CAVisitation]
,sum(CASE WHEN CAVisitationNon > 0 THEN 1 ELSE 0 END) [CAVisitationNon]
,sum(CASE WHEN CAOther > 0 THEN 1 ELSE 0 END) [CAOther]
,sum(CASE WHEN CAOtherNon > 0 THEN 1 ELSE 0 END) [CAOtherNon]
,sum(CASE WHEN CA1 > 0 THEN 1 ELSE 0 END) [CA1]
,sum(CASE WHEN CA2 > 0 THEN 1 ELSE 0 END) [CA2]
,sum([Total]) [Total]
FROM
(SELECT	
a.HVCaseFK
, CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END [FSWFK]
, CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END [PC1ID]
,avg(a.VisitLengthHour * 60 + a.VisitLengthMinute) [AvgMinuteForCompletedVisit]
,sum(CASE WHEN substring(a.VisitType,1,3) IN ('100', '110', '010') THEN 1 ELSE 0 END) [InHome]
,sum(CASE WHEN substring(a.VisitType,1,3) = '001' THEN 1 ELSE 0 END) [OutOfHome]
,sum(CASE WHEN substring(a.VisitType,1,3) IN ('101', '111', '011')  THEN 1 ELSE 0 END) [BothInAndOutHome]
,sum(CASE WHEN PC1Participated = 1 THEN 1 ELSE 0 END) [PC1Participated]
,sum(CASE WHEN PC2Participated  = 1 THEN 1 ELSE 0 END) [PC2Participated]
,sum(CASE WHEN OBPParticipated  = 1 THEN 1 ELSE 0 END) [OBPParticipated]
,sum(CASE WHEN FatherFigureParticipated  = 1 THEN 1 ELSE 0 END) [FatherFigureParticipated]
,sum(CASE WHEN TCParticipated  = 1 THEN 1 ELSE 0 END) [TCParticipated]
,sum(CASE WHEN GrandParentParticipated  = 1 THEN 1 ELSE 0 END) [GrandParentParticipated]
,sum(CASE WHEN SiblingParticipated  = 1 THEN 1 ELSE 0 END) [SiblingParticipated]
,sum(CASE WHEN NonPrimaryFSWParticipated  = 1 THEN 1 ELSE 0 END) [NonPrimaryFSWParticipated]
,sum(CASE WHEN HVSupervisorParticipated  = 1 THEN 1 ELSE 0 END) [HVSupervisorParticipated]
,sum(CASE WHEN SupervisorObservation  = 1 THEN 1 ELSE 0 END) [SupervisorObservation]
,sum(CASE WHEN OtherParticipated  = 1 THEN 1 ELSE 0 END) [OtherParticipated]
-- child development
,sum(CASE WHEN substring(CDChildDevelopment,1,1) = '1' THEN 1 ELSE 0 END) [CDChildDevelopment]
,sum(CASE WHEN substring(CDChildDevelopment,2,1) = '1' THEN 1 ELSE 0 END) [CDChildDevelopmentNon]
,sum(CASE WHEN substring(CDToys,1,1) = '1' THEN 1 ELSE 0 END) [CDToys]
,sum(CASE WHEN substring(CDToys,2,1) = '1' THEN 1 ELSE 0 END) [CDToysNon]
,sum(CASE WHEN substring(CDOther,1,1) = '1' THEN 1 ELSE 0 END) [CDOther]
,sum(CASE WHEN substring(CDOther,2,1) = '1' THEN 1 ELSE 0 END) [CDOtherNon]
,sum(CASE WHEN substring(CDChildDevelopment,1,1) = '1' OR substring(CDToys,1,1) = '1' 
 OR substring(CDOther,1,1) = '1' THEN 1 ELSE 0 END) [CD1]
,sum(CASE WHEN substring(CDChildDevelopment,2,1) = '1' OR substring(CDToys,2,1) = '1'
 OR  substring(CDOther,2,1) = '1' THEN 1 ELSE 0 END) [CD2]
-- parent child interaction
,sum(CASE WHEN substring(PCChildInteraction,1,1) = '1' THEN 1 ELSE 0 END) [PCChildInteraction]
,sum(CASE WHEN substring(PCChildInteraction,2,1) = '1' THEN 1 ELSE 0 END) [PCChildInteractionNon]
,sum(CASE WHEN substring(PCChildManagement,1,1) = '1' THEN 1 ELSE 0 END) [PCChildManagement]
,sum(CASE WHEN substring(PCChildManagement,2,1) = '1' THEN 1 ELSE 0 END) [PCChildManagementNon]
,sum(CASE WHEN substring(PCFeelings,1,1) = '1' THEN 1 ELSE 0 END) [PCFeelings]
,sum(CASE WHEN substring(PCFeelings,2,1) = '1' THEN 1 ELSE 0 END) [PCFeelingsNon]
,sum(CASE WHEN substring(PCStress,1,1) = '1' THEN 1 ELSE 0 END) [PCStress]
,sum(CASE WHEN substring(PCStress,2,1) = '1' THEN 1 ELSE 0 END) [PCStressNon]
,sum(CASE WHEN substring(PCBasicNeeds,1,1) = '1' THEN 1 ELSE 0 END) [PCBasicNeeds]
,sum(CASE WHEN substring(PCBasicNeeds,2,1) = '1' THEN 1 ELSE 0 END) [PCBasicNeedsNon]
,sum(CASE WHEN substring(PCShakenBaby,1,1) = '1' THEN 1 ELSE 0 END) [PCShakenBaby]
,sum(CASE WHEN substring(PCShakenBaby,2,1) = '1' THEN 1 ELSE 0 END) [PCShakenBabyNon]
,sum(CASE WHEN substring(PCShakenBabyVideo,1,1) = '1' THEN 1 ELSE 0 END) [PCShakenBabyVideo]
,sum(CASE WHEN substring(PCShakenBabyVideo,2,1) = '1' THEN 1 ELSE 0 END) [PCShakenBabyVideoNon]
,sum(CASE WHEN substring(PCOther,1,1) = '1' THEN 1 ELSE 0 END) [PCOther]
,sum(CASE WHEN substring(PCOther,2,1) = '1' THEN 1 ELSE 0 END) [PCOtherNon]
,sum(CASE WHEN substring(PCChildInteraction,1,1) = '1' 
OR substring(PCChildManagement,1,1) = '1'
OR substring(PCFeelings,1,1) = '1'
OR substring(PCStress,1,1) = '1'
OR substring(PCBasicNeeds,1,1) = '1'
OR substring(PCShakenBaby,1,1) = '1'
OR substring(PCShakenBabyVideo,1,1) = '1'
OR substring(PCOther,1,1) = '1'
THEN 1 ELSE 0 END) [PC1]
,sum(CASE WHEN substring(PCChildInteraction,2,1) = '1' 
OR substring(PCChildManagement,2,1) = '1'
OR substring(PCFeelings,2,1) = '1'
OR substring(PCStress,2,1) = '1'
OR substring(PCBasicNeeds,2,1) = '1'
OR substring(PCShakenBaby,2,1) = '1'
OR substring(PCShakenBabyVideo,2,1) = '1'
OR substring(PCOther,2,1) = '1'
THEN 1 ELSE 0 END) [PC2]
-- health care
,sum(CASE WHEN substring(HCGeneral,1,1) = '1' THEN 1 ELSE 0 END) [HCGeneral]
,sum(CASE WHEN substring(HCGeneral,2,1) = '1' THEN 1 ELSE 0 END) [HCGeneralNon]
,sum(CASE WHEN substring(HCChild,1,1) = '1' THEN 1 ELSE 0 END) [HCChild]
,sum(CASE WHEN substring(HCChild,2,1) = '1' THEN 1 ELSE 0 END) [HCChildNon]
,sum(CASE WHEN substring(HCDental,1,1) = '1' THEN 1 ELSE 0 END) [HCDental]
,sum(CASE WHEN substring(HCDental,2,1) = '1' THEN 1 ELSE 0 END) [HCDentalNon]
,sum(CASE WHEN substring(HCFeeding,1,1) = '1' THEN 1 ELSE 0 END) [HCFeeding]
,sum(CASE WHEN substring(HCFeeding,2,1) = '1' THEN 1 ELSE 0 END) [HCFeedingNon]
,sum(CASE WHEN substring(HCBreastFeeding,1,1) = '1' THEN 1 ELSE 0 END) [HCBreastFeeding]
,sum(CASE WHEN substring(HCBreastFeeding,2,1) = '1' THEN 1 ELSE 0 END) [HCBreastFeedingNon]
,sum(CASE WHEN substring(HCNutrition,1,1) = '1' THEN 1 ELSE 0 END) [HCNutrition]
,sum(CASE WHEN substring(HCNutrition,2,1) = '1' THEN 1 ELSE 0 END) [HCNutritionNon]
,sum(CASE WHEN substring(HCFamilyPlanning,1,1) = '1' THEN 1 ELSE 0 END) [HCFamilyPlanning]
,sum(CASE WHEN substring(HCFamilyPlanning,2,1) = '1' THEN 1 ELSE 0 END) [HCFamilyPlanningNon]
,sum(CASE WHEN substring(HCProviders,1,1) = '1' THEN 1 ELSE 0 END) [HCProviders]
,sum(CASE WHEN substring(HCProviders,2,1) = '1' THEN 1 ELSE 0 END) [HCProvidersNon]
,sum(CASE WHEN substring(HCFASD,1,1) = '1' THEN 1 ELSE 0 END) [HCFASD]
,sum(CASE WHEN substring(HCFASD,2,1) = '1' THEN 1 ELSE 0 END) [HCFASDNon]
,sum(CASE WHEN substring(HCSexEducation,1,1) = '1' THEN 1 ELSE 0 END) [HCSexEducation]
,sum(CASE WHEN substring(HCSexEducation,2,1) = '1' THEN 1 ELSE 0 END) [HCSexEducationNon]
,sum(CASE WHEN substring(HCPrenatalCare,1,1) = '1' THEN 1 ELSE 0 END) [HCPrenatalCare]
,sum(CASE WHEN substring(HCPrenatalCare,2,1) = '1' THEN 1 ELSE 0 END) [HCPrenatalCareNon]
,sum(CASE WHEN substring(HCMedicalAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) [HCMedicalAdvocacy]
,sum(CASE WHEN substring(HCMedicalAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) [HCMedicalAdvocacyNon]
,sum(CASE WHEN substring(HCSafety,1,1) = '1' THEN 1 ELSE 0 END) [HCSafety]
,sum(CASE WHEN substring(HCSafety,2,1) = '1' THEN 1 ELSE 0 END) [HCSafetyNon]
,sum(CASE WHEN substring(HCSmoking,1,1) = '1' THEN 1 ELSE 0 END) [HCSmoking]
,sum(CASE WHEN substring(HCSmoking,2,1) = '1' THEN 1 ELSE 0 END) [HCSmokingNon]
,sum(CASE WHEN substring(HCSIDS,1,1) = '1' THEN 1 ELSE 0 END) [HCSIDS]
,sum(CASE WHEN substring(HCSIDS,2,1) = '1' THEN 1 ELSE 0 END) [HCSIDSNon]
,sum(CASE WHEN substring(HCOther,1,1) = '1' THEN 1 ELSE 0 END) [HCOther]
,sum(CASE WHEN substring(HCOther,2,1) = '1' THEN 1 ELSE 0 END) [HCOtherNon]
,sum(CASE WHEN substring(HCGeneral,1,1) = '1' 
OR substring(HCChild,1,1) = '1'
OR substring(HCDental,1,1) = '1'
OR substring(HCFeeding,1,1) = '1'
OR substring(HCBreastFeeding,1,1) = '1'
OR substring(HCNutrition,1,1) = '1'
OR substring(HCFamilyPlanning,1,1) = '1'
OR substring(HCProviders,1,1) = '1'
OR substring(HCFASD,1,1) = '1'
OR substring(HCSexEducation,1,1) = '1'
OR substring(HCPrenatalCare,1,1) = '1'
OR substring(HCMedicalAdvocacy,1,1) = '1'
OR substring(HCSafety,1,1) = '1'
OR substring(HCSmoking,1,1) = '1'
OR substring(HCSIDS,1,1) = '1'
OR substring(HCOther,1,1) = '1'
THEN 1 ELSE 0 END) [HC1]
,sum(CASE WHEN substring(HCGeneral,2,1) = '1' 
OR substring(HCChild,2,1) = '1'
OR substring(HCDental,2,1) = '1'
OR substring(HCFeeding,2,1) = '1'
OR substring(HCBreastFeeding,2,1) = '1'
OR substring(HCNutrition,2,1) = '1'
OR substring(HCFamilyPlanning,2,1) = '1'
OR substring(HCProviders,2,1) = '1'
OR substring(HCFASD,2,1) = '1'
OR substring(HCSexEducation,2,1) = '1'
OR substring(HCPrenatalCare,2,1) = '1'
OR substring(HCMedicalAdvocacy,2,1) = '1'
OR substring(HCSafety,2,1) = '1'
OR substring(HCSmoking,2,1) = '1'
OR substring(HCSIDS,2,1) = '1'
OR substring(HCOther,2,1) = '1'
THEN 1 ELSE 0 END) [HC2]
-- family funvtioning
,sum(CASE WHEN substring(FFDomesticViolence,1,1) = '1' THEN 1 ELSE 0 END) [FFDomesticViolence]
,sum(CASE WHEN substring(FFDomesticViolence,2,1) = '1' THEN 1 ELSE 0 END) [FFDomesticViolenceNon]
,sum(CASE WHEN substring(FFFamilyRelations,1,1) = '1' THEN 1 ELSE 0 END) [FFFamilyRelations]
,sum(CASE WHEN substring(FFFamilyRelations,2,1) = '1' THEN 1 ELSE 0 END) [FFFamilyRelationsNon]
,sum(CASE WHEN substring(FFSubstanceAbuse,1,1) = '1' THEN 1 ELSE 0 END) [FFSubstanceAbuse]
,sum(CASE WHEN substring(FFSubstanceAbuse,2,1) = '1' THEN 1 ELSE 0 END) [FFSubstanceAbuseNon]
,sum(CASE WHEN substring(FFMentalHealth,1,1) = '1' THEN 1 ELSE 0 END) [FFMentalHealth]
,sum(CASE WHEN substring(FFMentalHealth,2,1) = '1' THEN 1 ELSE 0 END) [FFMentalHealthNon]
,sum(CASE WHEN substring(FFCommunication,1,1) = '1' THEN 1 ELSE 0 END) [FFCommunication]
,sum(CASE WHEN substring(FFCommunication,2,1) = '1' THEN 1 ELSE 0 END) [FFCommunicationNon]
,sum(CASE WHEN substring(FFOther,1,1) = '1' THEN 1 ELSE 0 END) [FFOther]
,sum(CASE WHEN substring(FFOther,2,1) = '1' THEN 1 ELSE 0 END) [FFOtherNon]
,sum(CASE WHEN substring(FFDomesticViolence,1,1) = '1' 
OR substring(FFFamilyRelations,1,1) = '1'
OR substring(FFSubstanceAbuse,1,1) = '1'
OR substring(FFMentalHealth,1,1) = '1'
OR substring(FFCommunication,1,1) = '1'
OR substring(FFOther,1,1) = '1' THEN 1 ELSE 0 END) [FF1]
,sum(CASE WHEN substring(FFDomesticViolence,2,1) = '1' 
OR substring(FFFamilyRelations,2,1) = '1'
OR substring(FFSubstanceAbuse,2,1) = '1'
OR substring(FFMentalHealth,2,1) = '1'
OR substring(FFCommunication,2,1) = '1'
OR substring(FFOther,2,1) = '1' THEN 1 ELSE 0 END) [FF2]
-- self sufficiency
,sum(CASE WHEN substring(SSCalendar,1,1) = '1' THEN 1 ELSE 0 END) [SSCalendar]
,sum(CASE WHEN substring(SSCalendar,2,1) = '1' THEN 1 ELSE 0 END) [SSCalendarNon]
,sum(CASE WHEN substring(SSHousekeeping,1,1) = '1' THEN 1 ELSE 0 END) [SSHousekeeping]
,sum(CASE WHEN substring(SSHousekeeping,2,1) = '1' THEN 1 ELSE 0 END) [SSHousekeepingNon]
,sum(CASE WHEN substring(SSTransportation,1,1) = '1' THEN 1 ELSE 0 END) [SSTransportation]
,sum(CASE WHEN substring(SSTransportation,2,1) = '1' THEN 1 ELSE 0 END) [SSTransportationNon]
,sum(CASE WHEN substring(SSEmployment,1,1) = '1' THEN 1 ELSE 0 END) [SSEmployment]
,sum(CASE WHEN substring(SSEmployment,2,1) = '1' THEN 1 ELSE 0 END) [SSEmploymentNon]
,sum(CASE WHEN substring(SSMoneyManagement,1,1) = '1' THEN 1 ELSE 0 END) [SSMoneyManagement]
,sum(CASE WHEN substring(SSMoneyManagement,2,1) = '1' THEN 1 ELSE 0 END) [SSMoneyManagementNon]
,sum(CASE WHEN substring(SSChildCare,1,1) = '1' THEN 1 ELSE 0 END) [SSChildCare]
,sum(CASE WHEN substring(SSChildCare,2,1) = '1' THEN 1 ELSE 0 END) [SSChildCareNon]
,sum(CASE WHEN substring(SSProblemSolving,1,1) = '1' THEN 1 ELSE 0 END) [SSProblemSolving]
,sum(CASE WHEN substring(SSProblemSolving,2,1) = '1' THEN 1 ELSE 0 END) [SSProblemSolvingNon]
,sum(CASE WHEN substring(SSEducation,1,1) = '1' THEN 1 ELSE 0 END) [SSEducation]
,sum(CASE WHEN substring(SSEducation,2,1) = '1' THEN 1 ELSE 0 END) [SSEducationNon]
,sum(CASE WHEN substring(SSJob,1,1) = '1' THEN 1 ELSE 0 END) [SSJob]
,sum(CASE WHEN substring(SSJob,2,1) = '1' THEN 1 ELSE 0 END) [SSJobNon]
,sum(CASE WHEN substring(SSOther,1,1) = '1' THEN 1 ELSE 0 END) [SSOther]
,sum(CASE WHEN substring(SSOther,2,1) = '1' THEN 1 ELSE 0 END) [SSOtherNon]
,sum(CASE WHEN substring(SSCalendar,1,1) = '1' 
OR substring(SSHousekeeping,1,1) = '1'
OR substring(SSTransportation,1,1) = '1'
OR substring(SSEmployment,1,1) = '1'
OR substring(SSMoneyManagement,1,1) = '1'
OR substring(SSChildCare,1,1) = '1'
OR substring(SSProblemSolving,1,1) = '1'
OR substring(SSEducation,1,1) = '1'
OR substring(SSJob,1,1) = '1'
OR substring(SSOther,1,1) = '1'
THEN 1 ELSE 0 END) [SS1]
,sum(CASE WHEN substring(SSCalendar,2,1) = '1' 
OR substring(SSHousekeeping,2,1) = '1'
OR substring(SSTransportation,2,1) = '1'
OR substring(SSEmployment,2,1) = '1'
OR substring(SSMoneyManagement,2,1) = '1'
OR substring(SSChildCare,2,1) = '1'
OR substring(SSProblemSolving,2,1) = '1'
OR substring(SSEducation,2,1) = '1'
OR substring(SSJob,2,1) = '1'
OR substring(SSOther,2,1) = '1'
THEN 1 ELSE 0 END) [SS2]
-- crisis intervention
,sum(CASE WHEN substring(CIProblems,1,1) = '1' THEN 1 ELSE 0 END) [CIProblems]
,sum(CASE WHEN substring(CIProblems,2,1) = '1' THEN 1 ELSE 0 END) [CIProblemsNon]
,sum(CASE WHEN substring(CIOther,1,1) = '1' THEN 1 ELSE 0 END) [CIOther]
,sum(CASE WHEN substring(CIOther,2,1) = '1' THEN 1 ELSE 0 END) [CIOtherNon]
,sum(CASE WHEN substring(CIProblems,1,1) = '1' 
OR substring(CIOther,1,1) = '1' 
THEN 1 ELSE 0 END) [CI1]
,sum(CASE WHEN substring(CIProblems,2,1) = '1' 
OR substring(CIOther,2,1) = '1' 
THEN 1 ELSE 0 END) [CI2]
-- program activities
,sum(CASE WHEN substring(PAForms,1,1) = '1' THEN 1 ELSE 0 END) [PAForms]
,sum(CASE WHEN substring(PAForms,2,1) = '1' THEN 1 ELSE 0 END) [PAFormsNon]
,sum(CASE WHEN substring(PAVideo,1,1) = '1' THEN 1 ELSE 0 END) [PAVideo]
,sum(CASE WHEN substring(PAVideo,2,1) = '1' THEN 1 ELSE 0 END) [PAVideoNon]
,sum(CASE WHEN substring(PAGroups,1,1) = '1' THEN 1 ELSE 0 END) [PAGroups]
,sum(CASE WHEN substring(PAGroups,2,1) = '1' THEN 1 ELSE 0 END) [PAGroupsNon]
,sum(CASE WHEN substring(PAIFSP,1,1) = '1' THEN 1 ELSE 0 END) [PAIFSP]
,sum(CASE WHEN substring(PAIFSP,2,1) = '1' THEN 1 ELSE 0 END) [PAIFSPNon]
,sum(CASE WHEN substring(PARecreation,1,1) = '1' THEN 1 ELSE 0 END) [PARecreation]
,sum(CASE WHEN substring(PARecreation,2,1) = '1' THEN 1 ELSE 0 END) [PARecreationNon]
,sum(CASE WHEN substring(PAOther,1,1) = '1' THEN 1 ELSE 0 END) [PAOther]
,sum(CASE WHEN substring(PAOther,2,1) = '1' THEN 1 ELSE 0 END) [PAOtherNon]
,sum(CASE WHEN substring(PAForms,1,1) = '1' 
OR substring(PAVideo,1,1) = '1'
OR substring(PAGroups,1,1) = '1'
OR substring(PAIFSP,1,1) = '1'
OR substring(PARecreation,1,1) = '1'
OR substring(PAOther,1,1) = '1'
THEN 1 ELSE 0 END) [PA1]

,sum(CASE WHEN substring(PAForms,2,1) = '1' 
OR substring(PAVideo,2,1) = '1'
OR substring(PAGroups,2,1) = '1'
OR substring(PAIFSP,2,1) = '1'
OR substring(PARecreation,2,1) = '1'
OR substring(PAOther,2,1) = '1'
THEN 1 ELSE 0 END) [PA2]
-- concrete activities
,sum(CASE WHEN substring(CATransportation,1,1) = '1' THEN 1 ELSE 0 END) [CATransportation]
,sum(CASE WHEN substring(CATransportation,2,1) = '1' THEN 1 ELSE 0 END) [CATransportationNon]
,sum(CASE WHEN substring(CAGoods,1,1) = '1' THEN 1 ELSE 0 END) [CAGoods]
,sum(CASE WHEN substring(CAGoods,2,1) = '1' THEN 1 ELSE 0 END) [CAGoodsNon]
,sum(CASE WHEN substring(CALegal,1,1) = '1' THEN 1 ELSE 0 END) [CALegal]
,sum(CASE WHEN substring(CALegal,2,1) = '1' THEN 1 ELSE 0 END) [CALegalNon]
,sum(CASE WHEN substring(CAHousing,1,1) = '1' THEN 1 ELSE 0 END) [CAHousing]
,sum(CASE WHEN substring(CAHousing,2,1) = '1' THEN 1 ELSE 0 END) [CAHousingNon]
,sum(CASE WHEN substring(CAAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) [CAAdvocacy]
,sum(CASE WHEN substring(CAAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) [CAAdvocacyNon]
,sum(CASE WHEN substring(CATranslation,1,1) = '1' THEN 1 ELSE 0 END) [CATranslation]
,sum(CASE WHEN substring(CATranslation,2,1) = '1' THEN 1 ELSE 0 END) [CATranslationNon]
,sum(CASE WHEN substring(CALaborSupport,1,1) = '1' THEN 1 ELSE 0 END) [CALaborSupport]
,sum(CASE WHEN substring(CALaborSupport,2,1) = '1' THEN 1 ELSE 0 END) [CALaborSupportNon]
,sum(CASE WHEN substring(CAChildSupport,1,1) = '1' THEN 1 ELSE 0 END) [CAChildSupport]
,sum(CASE WHEN substring(CAChildSupport,2,1) = '1' THEN 1 ELSE 0 END) [CAChildSupportNon]
,sum(CASE WHEN substring(CAParentRights,1,1) = '1' THEN 1 ELSE 0 END) [CAParentRights]
,sum(CASE WHEN substring(CAParentRights,2,1) = '1' THEN 1 ELSE 0 END) [CAParentRightsNon]
,sum(CASE WHEN substring(CAVisitation,1,1) = '1' THEN 1 ELSE 0 END) [CAVisitation]
,sum(CASE WHEN substring(CAVisitation,2,1) = '1' THEN 1 ELSE 0 END) [CAVisitationNon]
,sum(CASE WHEN substring(CAOther,1,1) = '1' THEN 1 ELSE 0 END) [CAOther]
,sum(CASE WHEN substring(CAOther,2,1) = '1' THEN 1 ELSE 0 END) [CAOtherNon]
,sum(CASE WHEN substring(CATransportation,1,1) = '1' 
OR substring(CAGoods,1,1) = '1'
OR substring(CALegal,1,1) = '1'
OR substring(CALegal,1,1) = '1'
OR substring(CAHousing,1,1) = '1'
OR substring(CAAdvocacy,1,1) = '1'
OR substring(CATranslation,1,1) = '1'
OR substring(CALaborSupport,1,1) = '1'
OR substring(CAChildSupport,1,1) = '1'
OR substring(CAVisitation,1,1) = '1'
OR substring(CAOther,1,1) = '1'
THEN 1 ELSE 0 END) [CA1]
,sum(CASE WHEN substring(CATransportation,2,1) = '1' 
OR substring(CAGoods,2,1) = '1'
OR substring(CALegal,2,1) = '1'
OR substring(CALegal,2,1) = '1'
OR substring(CAHousing,2,1) = '1'
OR substring(CAAdvocacy,2,1) = '1'
OR substring(CATranslation,2,1) = '1'
OR substring(CALaborSupport,2,1) = '1'
OR substring(CAChildSupport,2,1) = '1'
OR substring(CAVisitation,2,1) = '1'
OR substring(CAOther,2,1) = '1'
THEN 1 ELSE 0 END) [CA2],

count(*) [Total]

FROM HVLog AS a
INNER JOIN worker fsw ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp ON cp.HVCaseFK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND substring(a.VisitType,4,1) <> '1'
AND cast(a.VisitStartTime AS date) between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY a.HVCaseFK,
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
) AS x
GROUP BY FSWFK, PC1ID
)

SELECT a.*, d.AttemptedFamily, d.Attempted

,[AvgMinuteForCompletedVisit]
,[InHome]
,[OutOfHome]
,[BothInAndOutHome]
,

[PC1Participated],
[PC2Participated],
[OBPParticipated],
[FatherFigureParticipated], 
[TCParticipated],
[GrandParentParticipated],
[SiblingParticipated],
[NonPrimaryFSWParticipated],
[HVSupervisorParticipated],
[SupervisorObservation],
[OtherParticipated],

-- child development
[CDChildDevelopment] [CDChildDevelopment],
[CDChildDevelopmentNon] [CDChildDevelopmentNon],
[CDToys] [CDToys],
[CDToysNon] [CDToysNon],
[CDOther] [CDOther],
[CDOtherNon] [CDOtherNon],
[CD1] [CD1],
[CD2] [CD2],

-- parent/child interaction
[PCChildInteraction] [PCChildInteraction],
[PCChildInteractionNon] [PCChildInteractionNon],
[PCChildManagement] [PCChildManagement],
[PCChildManagementNon] [PCChildManagementNon],
[PCFeelings] [PCFeelings],
[PCFeelingsNon] [PCFeelingsNon],
[PCStress] [PCStress],
[PCStressNon] [PCStressNon],
[PCBasicNeeds] [PCBasicNeeds],
[PCBasicNeedsNon] [PCBasicNeedsNon],
[PCShakenBaby] [PCShakenBaby],
[PCShakenBabyNon] [PCShakenBabyNon],
[PCShakenBabyVideo] [PCShakenBabyVideo],
[PCShakenBabyVideoNon] [PCShakenBabyVideoNon],
[PCOther] [PCOther],
[PCOtherNon] [PCOtherNon],

[PC1] [PC1],
[PC2] [PC2],

-- Health care
[HCGeneral] [HCGeneral],
[HCGeneralNon] [HCGeneralNon],
[HCChild] [HCChild],
[HCChildNon] [HCChildNon],
[HCDental] [HCDental],
[HCDentalNon] [HCDentalNon],
[HCFeeding] [HCFeeding],
[HCFeedingNon] [HCFeedingNon],
[HCBreastFeeding] [HCBreastFeeding],
[HCBreastFeedingNon] [HCBreastFeedingNon],
[HCNutrition] [HCNutrition],
[HCNutritionNon] [HCNutritionNon],
[HCFamilyPlanning] [HCFamilyPlanning],
[HCFamilyPlanningNon] [HCFamilyPlanningNon],
[HCProviders] [HCProviders],
[HCProvidersNon] [HCProvidersNon],
[HCFASD] [HCFASD],
[HCFASDNon] [HCFASDNon],
[HCSexEducation] [HCSexEducation],
[HCSexEducationNon] [HCSexEducationNon],
[HCPrenatalCare] [HCPrenatalCare],
[HCPrenatalCareNon] [HCPrenatalCareNon],
[HCMedicalAdvocacy] [HCMedicalAdvocacy],
[HCMedicalAdvocacyNon] [HCMedicalAdvocacyNon],
[HCSafety] [HCSafety],
[HCSafetyNon] [HCSafetyNon],
[HCSmoking] [HCSmoking],
[HCSmokingNon] [HCSmokingNon],
[HCSIDS] [HCSIDS],
[HCSIDSNon] [HCSIDSNon],
[HCOther] [HCOther],
[HCOther] [HCOther],
[HCOtherNon] [HCOtherNon],

[HC1] [HC1],
[HC2] [HC2],

-- family functioning
[FFDomesticViolence] [FFDomesticViolence],
[FFDomesticViolenceNon] [FFDomesticViolenceNon],
[FFFamilyRelations] [FFFamilyRelations],
[FFFamilyRelationsNon] [FFFamilyRelationsNon],
[FFSubstanceAbuse] [FFSubstanceAbuse],
[FFSubstanceAbuseNon] [FFSubstanceAbuseNon],
[FFMentalHealth] [FFMentalHealth],
[FFMentalHealthNon] [FFMentalHealthNon],
[FFCommunication] [FFCommunication],
[FFCommunicationNon] [FFCommunicationNon],
[FFOther] [FFOther],
[FFOtherNon] [FFOtherNon],

[FF1] [FF1],
[FF2] [FF2],

-- self sufficiency
[SSCalendar] [SSCalendar],
[SSCalendarNon] [SSCalendarNon],
[SSHousekeeping] [SSHousekeeping],
[SSHousekeepingNon] [SSHousekeepingNon],
[SSTransportation] [SSTransportation],
[SSTransportationNon] [SSTransportationNon],
[SSEmployment] [SSEmployment],
[SSEmploymentNon] [SSEmploymentNon],
[SSMoneyManagement] [SSMoneyManagement],
[SSMoneyManagementNon] [SSMoneyManagementNon],
[SSChildCare] [SSChildCare],
[SSChildCareNon] [SSChildCareNon],
[SSProblemSolving] [SSProblemSolving],
[SSProblemSolvingNon] [SSProblemSolvingNon],
[SSEducation] [SSEducation],
[SSEducationNon] [SSEducationNon],
[SSJob] [SSJob],
[SSJobNon] [SSJobNon],
[SSOther] [SSOther],
[SSOtherNon] [SSOtherNon],

[SS1] [SS1],
[SS2] [SS2],

-- crisis intervention
[CIProblems] [CIProblems],
[CIProblemsNon] [CIProblemsNon],
[CIOther] [CIOther],
[CIOtherNon] [CIOtherNon],

[CI1] [CI1],
[CI2] [CI2],

-- program activities
[PAForms] [PAForms],
[PAFormsNon] [PAFormsNon],
[PAVideo] [PAVideo],
[PAVideoNon] [PAVideoNon],
[PAGroups] [PAGroups],
[PAGroupsNon] [PAGroupsNon],
[PAIFSP] [PAIFSP],
[PAIFSPNon] [PAIFSPNon],
[PARecreation] [PARecreation],
[PARecreationNon] [PARecreationNon],
[PAOther] [PAOther],
[PAOtherNon] [PAOtherNon],

[PA1] [PA1],
[PA2] [PA2],

-- concrete activities
[CATransportation] [CATransportation],
[CATransportationNon] [CATransportationNon],
[CAGoods] [CAGoods],
[CAGoodsNon] [CAGoodsNon],
[CALegal] [CALegal],
[CALegalNon] [CALegalNon],
[CAHousing] [CAHousing],
[CAHousingNon] [CAHousingNon],
[CAAdvocacy] [CAAdvocacy],
[CAAdvocacyNon] [CAAdvocacyNon],
[CATranslation] [CATranslation],
[CATranslationNon] [CATranslationNon],
[CALaborSupport] [CALaborSupport],
[CALaborSupportNon] [CALaborSupportNon],
[CAChildSupport] [CAChildSupport],
[CAChildSupportNon] [CAChildSupportNon],
[CAParentRights] [CAParentRights],
[CAParentRightsNon] [CAParentRightsNon],
[CAVisitation] [CAVisitation],
[CAVisitationNon] [CAVisitationNon],
[CAOther] [CAOther],
[CAOtherNon] [CAOtherNon],

[CA1] [CA1],
[CA2] [CA2],
[Total],

CASE WHEN c.WorkerPK IS NULL THEN 'All Workers' ELSE 
rtrim(c.LastName) + ', ' + rtrim(c.FirstName) END WorkerName

FROM base11 AS a 
FULL OUTER JOIN base2 AS b ON a.FSWFK = b.FSWFK AND a.PC1ID = b.PC1ID
FULL OUTER JOIN base0 AS d ON a.FSWFK = d.FSWFK AND a.PC1ID = d.PC1ID
LEFT OUTER JOIN Worker AS c ON 
CASE WHEN (@showWorkerDetail = 'N' AND @workerfk IS NOT NULL) THEN @workerfk 
ELSE a.FSWFK END = c.WorkerPK
ORDER BY WorkerName, a.PC1ID














































GO
