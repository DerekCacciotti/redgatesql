
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary
-- =============================================
CREATE PROCEDURE [dbo].[rspHomeVisitLogActivitySummary] 
	-- Add the parameters for the stored procedure here
	(@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt DATETIME,
	@workerfk INT = NULL,
	@pc1id VARCHAR(13) = '',
	@showWorkerDetail CHAR(1) = 'N',
	@showPC1IDDetail CHAR(1) = 'N')

--DECLARE	@programfk INT = 6
--DECLARE @StartDt DATETIME = '01/01/2011'
--DECLARE @EndDt DATETIME = '01/01/2012'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = NULL
--DECLARE @showWorkerDetail CHAR(1) = 'Y'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'
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
,x = sum(CASE substring(VisitType,4,1) WHEN '1' THEN 0 ELSE 1 END) 
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
)

, base11 AS (
SELECT FSWFK, PC1ID, CASE WHEN x = 0 THEN 1 ELSE x END x FROM base1
)

, base2 AS (
SELECT 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
,CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID
--,count(DISTINCT a.HVCaseFK) [UniqueFamilies],

,count(DISTINCT (CASE WHEN substring(VisitType,4,1) != '1' THEN a.HVCaseFK ELSE NULL END)) [UniqueFamilies],
sum(CASE substring(VisitType,4,1) WHEN '1' THEN 1 ELSE 0 END) [Attempted] , 
sum(CASE substring(VisitType,4,1) WHEN '1' THEN 0 ELSE 1 END) [CompletedVisit],
sum(CASE WHEN substring(VisitType,1,3) IN ('100', '110', '010')  THEN 1 ELSE 0 END) [InHome],
sum(CASE WHEN substring(VisitType,1,3) = '001' THEN 1 ELSE 0 END) [OutOfHome],
sum(CASE WHEN substring(VisitType,1,3) IN ('101', '111', '011')  THEN 1 ELSE 0 END) [BothInAndOutHome],
sum(VisitLengthHour * 60 + VisitLengthMinute)  [AvgMinuteForCompletedVisit],

sum(CASE WHEN PC1Participated = 1 THEN 1 ELSE 0 END) * 100  [PC1Participated],
sum(CASE WHEN PC2Participated  = 1 THEN 1 ELSE 0 END) * 100  [PC2Participated],
sum(CASE WHEN OBPParticipated  = 1 THEN 1 ELSE 0 END) * 100  [OBPParticipated],
sum(CASE WHEN FatherFigureParticipated  = 1 THEN 1 ELSE 0 END) * 100  [FatherFigureParticipated], 
sum(CASE WHEN TCParticipated  = 1 THEN 1 ELSE 0 END) * 100  [TCParticipated],
sum(CASE WHEN GrandParentParticipated  = 1 THEN 1 ELSE 0 END) * 100  [GrandParentParticipated],
sum(CASE WHEN SiblingParticipated  = 1 THEN 1 ELSE 0 END) * 100  [SiblingParticipated],
sum(CASE WHEN NonPrimaryFSWParticipated  = 1 THEN 1 ELSE 0 END) * 100  [NonPrimaryFSWParticipated],
sum(CASE WHEN HVSupervisorParticipated  = 1 THEN 1 ELSE 0 END) * 100  [HVSupervisorParticipated],
sum(CASE WHEN SupervisorObservation  = 1 THEN 1 ELSE 0 END) * 100  [SupervisorObservation],
sum(CASE WHEN OtherParticipated  = 1 THEN 1 ELSE 0 END) * 100  [OtherParticipated],

-- child development
sum(CASE WHEN substring(CDChildDevelopment,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CDChildDevelopment],
sum(CASE WHEN substring(CDChildDevelopment,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CDChildDevelopmentNon],
sum(CASE WHEN substring(CDToys,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CDToys],
sum(CASE WHEN substring(CDToys,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CDToysNon],
sum(CASE WHEN substring(CDOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CDOther],
sum(CASE WHEN substring(CDOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CDOtherNon],
sum(CASE WHEN substring(CDChildDevelopment,1,1) = '1'
OR substring(CDToys,1,1) = '1'
OR substring(CDOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [CD1],
sum(CASE WHEN substring(CDChildDevelopment,2,1) = '1'
OR  substring(CDToys,2,1) = '1'
OR  substring(CDOther,2,1) = '1'
THEN 1 ELSE 0 END) * 100  [CD2],

-- parent/child interaction
sum(CASE WHEN substring(PCChildInteraction,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCChildInteraction],
sum(CASE WHEN substring(PCChildInteraction,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCChildInteractionNon],
sum(CASE WHEN substring(PCChildManagement,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCChildManagement],
sum(CASE WHEN substring(PCChildManagement,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCChildManagementNon],
sum(CASE WHEN substring(PCFeelings,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCFeelings],
sum(CASE WHEN substring(PCFeelings,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCFeelingsNon],
sum(CASE WHEN substring(PCStress,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCStress],
sum(CASE WHEN substring(PCStress,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCStressNon],
sum(CASE WHEN substring(PCBasicNeeds,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCBasicNeeds],
sum(CASE WHEN substring(PCBasicNeeds,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCBasicNeedsNon],
sum(CASE WHEN substring(PCShakenBaby,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCShakenBaby],
sum(CASE WHEN substring(PCShakenBaby,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCShakenBabyNon],
sum(CASE WHEN substring(PCShakenBabyVideo,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCShakenBabyVideo],
sum(CASE WHEN substring(PCShakenBabyVideo,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCShakenBabyVideoNon],
sum(CASE WHEN substring(PCOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PCOther],
sum(CASE WHEN substring(PCOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PCOtherNon],

sum(CASE WHEN substring(PCChildInteraction,1,1) = '1' 
OR substring(PCChildManagement,1,1) = '1'
OR substring(PCFeelings,1,1) = '1'
OR substring(PCStress,1,1) = '1'
OR substring(PCBasicNeeds,1,1) = '1'
OR substring(PCShakenBaby,1,1) = '1'
OR substring(PCShakenBabyVideo,1,1) = '1'
OR substring(PCOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [PC1],
sum(CASE WHEN substring(PCChildInteraction,2,1) = '1' 
OR substring(PCChildManagement,2,1) = '1'
OR substring(PCFeelings,2,1) = '1'
OR substring(PCStress,2,1) = '1'
OR substring(PCBasicNeeds,2,1) = '1'
OR substring(PCShakenBaby,2,1) = '1'
OR substring(PCShakenBabyVideo,2,1) = '1'
OR substring(PCOther,2,1) = '1'
THEN 1 ELSE 0 END) * 100  [PC2],

-- Health care
sum(CASE WHEN substring(HCGeneral,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCGeneral],
sum(CASE WHEN substring(HCGeneral,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCGeneralNon],
sum(CASE WHEN substring(HCChild,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCChild],
sum(CASE WHEN substring(HCChild,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCChildNon],
sum(CASE WHEN substring(HCDental,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCDental],
sum(CASE WHEN substring(HCDental,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCDentalNon],
sum(CASE WHEN substring(HCFeeding,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFeeding],
sum(CASE WHEN substring(HCFeeding,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFeedingNon],
sum(CASE WHEN substring(HCBreastFeeding,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCBreastFeeding],
sum(CASE WHEN substring(HCBreastFeeding,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCBreastFeedingNon],
sum(CASE WHEN substring(HCNutrition,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCNutrition],
sum(CASE WHEN substring(HCNutrition,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCNutritionNon],
sum(CASE WHEN substring(HCFamilyPlanning,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFamilyPlanning],
sum(CASE WHEN substring(HCFamilyPlanning,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFamilyPlanningNon],
sum(CASE WHEN substring(HCProviders,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCProviders],
sum(CASE WHEN substring(HCProviders,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCProvidersNon],
sum(CASE WHEN substring(HCFASD,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFASD],
sum(CASE WHEN substring(HCFASD,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCFASDNon],
sum(CASE WHEN substring(HCSexEducation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSexEducation],
sum(CASE WHEN substring(HCSexEducation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSexEducationNon],
sum(CASE WHEN substring(HCPrenatalCare,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCPrenatalCare],
sum(CASE WHEN substring(HCPrenatalCare,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCPrenatalCareNon],
sum(CASE WHEN substring(HCMedicalAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCMedicalAdvocacy],
sum(CASE WHEN substring(HCMedicalAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCMedicalAdvocacyNon],
sum(CASE WHEN substring(HCSafety,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSafety],
sum(CASE WHEN substring(HCSafety,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSafetyNon],
sum(CASE WHEN substring(HCSmoking,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSmoking],
sum(CASE WHEN substring(HCSmoking,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSmokingNon],
sum(CASE WHEN substring(HCSIDS,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSIDS],
sum(CASE WHEN substring(HCSIDS,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCSIDSNon],
sum(CASE WHEN substring(HCOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [HCOther],
sum(CASE WHEN substring(HCOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [HCOtherNon],

sum(CASE WHEN substring(HCGeneral,1,1) = '1' 
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
THEN 1 ELSE 0 END) * 100  [HC1],
sum(CASE WHEN substring(HCGeneral,2,1) = '1' 
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
THEN 1 ELSE 0 END) * 100  [HC2],

-- family functioning
sum(CASE WHEN substring(FFDomesticViolence,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFDomesticViolence],
sum(CASE WHEN substring(FFDomesticViolence,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFDomesticViolenceNon],
sum(CASE WHEN substring(FFFamilyRelations,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFFamilyRelations],
sum(CASE WHEN substring(FFFamilyRelations,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFFamilyRelationsNon],
sum(CASE WHEN substring(FFSubstanceAbuse,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFSubstanceAbuse],
sum(CASE WHEN substring(FFSubstanceAbuse,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFSubstanceAbuseNon],
sum(CASE WHEN substring(FFMentalHealth,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFMentalHealth],
sum(CASE WHEN substring(FFMentalHealth,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFMentalHealthNon],
sum(CASE WHEN substring(FFCommunication,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFCommunication],
sum(CASE WHEN substring(FFCommunication,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFCommunicationNon],
sum(CASE WHEN substring(FFOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [FFOther],
sum(CASE WHEN substring(FFOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [FFOtherNon],

sum(CASE WHEN substring(FFDomesticViolence,1,1) = '1' 
OR substring(FFFamilyRelations,1,1) = '1'
OR substring(FFSubstanceAbuse,1,1) = '1'
OR substring(FFMentalHealth,1,1) = '1'
OR substring(FFCommunication,1,1) = '1'
OR substring(FFOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [FF1],

sum(CASE WHEN substring(FFDomesticViolence,2,1) = '1' 
OR substring(FFFamilyRelations,2,1) = '1'
OR substring(FFSubstanceAbuse,2,1) = '1'
OR substring(FFMentalHealth,2,1) = '1'
OR substring(FFCommunication,2,1) = '1'
OR substring(FFOther,2,1) = '1'
THEN 1 ELSE 0 END) * 100  [FF2],

-- self sufficiency
sum(CASE WHEN substring(SSCalendar,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSCalendar],
sum(CASE WHEN substring(SSCalendar,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSCalendarNon],
sum(CASE WHEN substring(SSHousekeeping,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSHousekeeping],
sum(CASE WHEN substring(SSHousekeeping,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSHousekeepingNon],
sum(CASE WHEN substring(SSTransportation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSTransportation],
sum(CASE WHEN substring(SSTransportation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSTransportationNon],
sum(CASE WHEN substring(SSEmployment,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSEmployment],
sum(CASE WHEN substring(SSEmployment,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSEmploymentNon],
sum(CASE WHEN substring(SSMoneyManagement,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSMoneyManagement],
sum(CASE WHEN substring(SSMoneyManagement,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSMoneyManagementNon],
sum(CASE WHEN substring(SSChildCare,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSChildCare],
sum(CASE WHEN substring(SSChildCare,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSChildCareNon],
sum(CASE WHEN substring(SSProblemSolving,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSProblemSolving],
sum(CASE WHEN substring(SSProblemSolving,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSProblemSolvingNon],
sum(CASE WHEN substring(SSEducation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSEducation],
sum(CASE WHEN substring(SSEducation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSEducationNon],
sum(CASE WHEN substring(SSJob,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSJob],
sum(CASE WHEN substring(SSJob,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSJobNon],
sum(CASE WHEN substring(SSOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [SSOther],
sum(CASE WHEN substring(SSOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [SSOtherNon],

sum(CASE WHEN substring(SSCalendar,1,1) = '1' 
OR substring(SSHousekeeping,1,1) = '1'
OR substring(SSTransportation,1,1) = '1'
OR substring(SSEmployment,1,1) = '1'
OR substring(SSMoneyManagement,1,1) = '1'
OR substring(SSChildCare,1,1) = '1'
OR substring(SSProblemSolving,1,1) = '1'
OR substring(SSEducation,1,1) = '1'
OR substring(SSJob,1,1) = '1'
OR substring(SSOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [SS1],

sum(CASE WHEN substring(SSCalendar,2,1) = '1' 
OR substring(SSHousekeeping,2,1) = '1'
OR substring(SSTransportation,2,1) = '1'
OR substring(SSEmployment,2,1) = '1'
OR substring(SSMoneyManagement,2,1) = '1'
OR substring(SSChildCare,2,1) = '1'
OR substring(SSProblemSolving,2,1) = '1'
OR substring(SSEducation,2,1) = '1'
OR substring(SSJob,2,1) = '1'
OR substring(SSOther,2,1) = '1'
THEN 1 ELSE 0 END) * 100  [SS2],

-- crisis intervention
sum(CASE WHEN substring(CIProblems,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CIProblems],
sum(CASE WHEN substring(CIProblems,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CIProblemsNon],
sum(CASE WHEN substring(CIOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CIOther],
sum(CASE WHEN substring(CIOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CIOtherNon],

sum(CASE WHEN substring(CIProblems,1,1) = '1' 
OR substring(CIOther,1,1) = '1' 
THEN 1 ELSE 0 END) * 100  [CI1],

sum(CASE WHEN substring(CIProblems,2,1) = '1' 
OR substring(CIOther,2,1) = '1' 
THEN 1 ELSE 0 END) * 100  [CI2],

-- program activities
sum(CASE WHEN substring(PAForms,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PAForms],
sum(CASE WHEN substring(PAForms,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PAFormsNon],
sum(CASE WHEN substring(PAVideo,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PAVideo],
sum(CASE WHEN substring(PAVideo,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PAVideoNon],
sum(CASE WHEN substring(PAGroups,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PAGroups],
sum(CASE WHEN substring(PAGroups,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PAGroupsNon],
sum(CASE WHEN substring(PAIFSP,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PAIFSP],
sum(CASE WHEN substring(PAIFSP,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PAIFSPNon],
sum(CASE WHEN substring(PARecreation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PARecreation],
sum(CASE WHEN substring(PARecreation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PARecreationNon],
sum(CASE WHEN substring(PAOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [PAOther],
sum(CASE WHEN substring(PAOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [PAOtherNon],

sum(CASE WHEN substring(PAForms,1,1) = '1' 
OR substring(PAVideo,1,1) = '1'
OR substring(PAGroups,1,1) = '1'
OR substring(PAIFSP,1,1) = '1'
OR substring(PARecreation,1,1) = '1'
OR substring(PAOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [PA1],

sum(CASE WHEN substring(PAForms,2,1) = '1' 
OR substring(PAVideo,2,1) = '1'
OR substring(PAGroups,2,1) = '1'
OR substring(PAIFSP,2,1) = '1'
OR substring(PARecreation,2,1) = '1'
OR substring(PAOther,2,1) = '1'
THEN 1 ELSE 0 END) * 100  [PA2],

-- concrete activities
sum(CASE WHEN substring(CATransportation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CATransportation],
sum(CASE WHEN substring(CATransportation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CATransportationNon],
sum(CASE WHEN substring(CAGoods,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAGoods],
sum(CASE WHEN substring(CAGoods,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAGoodsNon],
sum(CASE WHEN substring(CALegal,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CALegal],
sum(CASE WHEN substring(CALegal,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CALegalNon],
sum(CASE WHEN substring(CAHousing,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAHousing],
sum(CASE WHEN substring(CAHousing,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAHousingNon],
sum(CASE WHEN substring(CAAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAAdvocacy],
sum(CASE WHEN substring(CAAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAAdvocacyNon],
sum(CASE WHEN substring(CATranslation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CATranslation],
sum(CASE WHEN substring(CATranslation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CATranslationNon],
sum(CASE WHEN substring(CALaborSupport,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CALaborSupport],
sum(CASE WHEN substring(CALaborSupport,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CALaborSupportNon],
sum(CASE WHEN substring(CAChildSupport,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAChildSupport],
sum(CASE WHEN substring(CAChildSupport,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAChildSupportNon],
sum(CASE WHEN substring(CAParentRights,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAParentRights],
sum(CASE WHEN substring(CAParentRights,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAParentRightsNon],
sum(CASE WHEN substring(CAVisitation,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAVisitation],
sum(CASE WHEN substring(CAVisitation,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAVisitationNon],
sum(CASE WHEN substring(CAOther,1,1) = '1' THEN 1 ELSE 0 END) * 100  [CAOther],
sum(CASE WHEN substring(CAOther,2,1) = '1' THEN 1 ELSE 0 END) * 100  [CAOtherNon],

sum(CASE WHEN substring(CATransportation,1,1) = '1' 
OR substring(CAGoods,1,1) = '1'
OR substring(CALegal,1,1) = '1'
OR substring(CALegal,1,1) = '1'
OR substring(CAHousing,1,1) = '1'
OR substring(CAAdvocacy,1,1) = '1'
OR substring(CATranslation,1,1) = '1'
OR substring(CALaborSupport,1,1) = '1'
OR substring(CAChildSupport,2,1) = '1'
OR substring(CAVisitation,1,1) = '1'
OR substring(CAOther,1,1) = '1'
THEN 1 ELSE 0 END) * 100  [CA1],

sum(CASE WHEN substring(CATransportation,2,1) = '1' 
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
THEN 1 ELSE 0 END) * 100  [CA2],

count(*) [Total]

FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
GROUP BY 
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END, 
CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END
)

SELECT a.*, 

[UniqueFamilies], [Attempted], [CompletedVisit], [InHome], [OutOfHome], [BothInAndOutHome], 
([AvgMinuteForCompletedVisit] / x) [AvgMinuteForCompletedVisit],

[PC1Participated] / x [PC1Participated],
[PC2Participated] / x [PC2Participated],
[OBPParticipated] / x [OBPParticipated],
[FatherFigureParticipated] / x [FatherFigureParticipated], 
[TCParticipated] / x [TCParticipated],
[GrandParentParticipated] / x [GrandParentParticipated],
[SiblingParticipated] / x [SiblingParticipated],
[NonPrimaryFSWParticipated] / x [NonPrimaryFSWParticipated],
[HVSupervisorParticipated] / x [HVSupervisorParticipated],
[SupervisorObservation] / x [SupervisorObservation],
[OtherParticipated] / x [OtherParticipated],

-- child development
[CDChildDevelopment] / x [CDChildDevelopment],
[CDChildDevelopmentNon] / x [CDChildDevelopmentNon],
[CDToys] / x [CDToys],
[CDToysNon] / x [CDToysNon],
[CDOther] / x [CDOther],
[CDOtherNon] / x [CDOtherNon],
[CD1] / x [CD1],
[CD2] / x [CD2],

-- parent/child interaction
[PCChildInteraction] / x [PCChildInteraction],
[PCChildInteractionNon] / x [PCChildInteractionNon],
[PCChildManagement] / x [PCChildManagement],
[PCChildManagementNon] / x [PCChildManagementNon],
[PCFeelings] / x [PCFeelings],
[PCFeelingsNon] / x [PCFeelingsNon],
[PCStress] / x [PCStress],
[PCStressNon] / x [PCStressNon],
[PCBasicNeeds] / x [PCBasicNeeds],
[PCBasicNeedsNon] / x [PCBasicNeedsNon],
[PCShakenBaby] / x [PCShakenBaby],
[PCShakenBabyNon] / x [PCShakenBabyNon],
[PCShakenBabyVideo] / x [PCShakenBabyVideo],
[PCShakenBabyVideoNon] / x [PCShakenBabyVideoNon],
[PCOther] / x [PCOther],
[PCOtherNon] / x [PCOtherNon],

[PC1] / x [PC1],
[PC2] / x [PC2],

-- Health care
[HCGeneral] / x [HCGeneral],
[HCGeneralNon] / x [HCGeneralNon],
[HCChild] / x [HCChild],
[HCChildNon] / x [HCChildNon],
[HCDental] / x [HCDental],
[HCDentalNon] / x [HCDentalNon],
[HCFeeding] / x [HCFeeding],
[HCFeedingNon] / x [HCFeedingNon],
[HCBreastFeeding] / x [HCBreastFeeding],
[HCBreastFeedingNon] / x [HCBreastFeedingNon],
[HCNutrition] / x [HCNutrition],
[HCNutritionNon] / x [HCNutritionNon],
[HCFamilyPlanning] / x [HCFamilyPlanning],
[HCFamilyPlanningNon] / x [HCFamilyPlanningNon],
[HCProviders] / x [HCProviders],
[HCProvidersNon] / x [HCProvidersNon],
[HCFASD] / x [HCFASD],
[HCFASDNon] / x [HCFASDNon],
[HCSexEducation] / x [HCSexEducation],
[HCSexEducationNon] / x [HCSexEducationNon],
[HCPrenatalCare] / x [HCPrenatalCare],
[HCPrenatalCareNon] / x [HCPrenatalCareNon],
[HCMedicalAdvocacy] / x [HCMedicalAdvocacy],
[HCMedicalAdvocacyNon] / x [HCMedicalAdvocacyNon],
[HCSafety] / x [HCSafety],
[HCSafetyNon] / x [HCSafetyNon],
[HCSmoking] / x [HCSmoking],
[HCSmokingNon] / x [HCSmokingNon],
[HCSIDS] / x [HCSIDS],
[HCSIDSNon] / x [HCSIDSNon],
[HCOther] / x [HCOther],
[HCOther] / x [HCOther],
[HCOtherNon] / x [HCOtherNon],

[HC1] / x [HC1],
[HC2] / x [HC2],

-- family functioning
[FFDomesticViolence] / x [FFDomesticViolence],
[FFDomesticViolenceNon] / x [FFDomesticViolenceNon],
[FFFamilyRelations] / x [FFFamilyRelations],
[FFFamilyRelationsNon] / x [FFFamilyRelationsNon],
[FFSubstanceAbuse] / x [FFSubstanceAbuse],
[FFSubstanceAbuseNon] / x [FFSubstanceAbuseNon],
[FFMentalHealth] / x [FFMentalHealth],
[FFMentalHealthNon] / x [FFMentalHealthNon],
[FFCommunication] / x [FFCommunication],
[FFCommunicationNon] / x [FFCommunicationNon],
[FFOther] / x [FFOther],
[FFOtherNon] / x [FFOtherNon],

[FF1] / x [FF1],
[FF2] / x [FF2],

-- self sufficiency
[SSCalendar] / x [SSCalendar],
[SSCalendarNon] / x [SSCalendarNon],
[SSHousekeeping] / x [SSHousekeeping],
[SSHousekeepingNon] / x [SSHousekeepingNon],
[SSTransportation] / x [SSTransportation],
[SSTransportationNon] / x [SSTransportationNon],
[SSEmployment] / x [SSEmployment],
[SSEmploymentNon] / x [SSEmploymentNon],
[SSMoneyManagement] / x [SSMoneyManagement],
[SSMoneyManagementNon] / x [SSMoneyManagementNon],
[SSChildCare] / x [SSChildCare],
[SSChildCareNon] / x [SSChildCareNon],
[SSProblemSolving] / x [SSProblemSolving],
[SSProblemSolvingNon] / x [SSProblemSolvingNon],
[SSEducation] / x [SSEducation],
[SSEducationNon] / x [SSEducationNon],
[SSJob] / x [SSJob],
[SSJobNon] / x [SSJobNon],
[SSOther] / x [SSOther],
[SSOtherNon] / x [SSOtherNon],

[SS1] / x [SS1],
[SS2] / x [SS2],

-- crisis intervention
[CIProblems] / x [CIProblems],
[CIProblemsNon] / x [CIProblemsNon],
[CIOther] / x [CIOther],
[CIOtherNon] / x [CIOtherNon],

[CI1] / x [CI1],
[CI2] / x [CI2],

-- program activities
[PAForms] / x [PAForms],
[PAFormsNon] / x [PAFormsNon],
[PAVideo] / x [PAVideo],
[PAVideoNon] / x [PAVideoNon],
[PAGroups] / x [PAGroups],
[PAGroupsNon] / x [PAGroupsNon],
[PAIFSP] / x [PAIFSP],
[PAIFSPNon] / x [PAIFSPNon],
[PARecreation] / x [PARecreation],
[PARecreationNon] / x [PARecreationNon],
[PAOther] / x [PAOther],
[PAOtherNon] / x [PAOtherNon],

[PA1] / x [PA1],
[PA2] / x [PA2],

-- concrete activities
[CATransportation] / x [CATransportation],
[CATransportationNon] / x [CATransportationNon],
[CAGoods] / x [CAGoods],
[CAGoodsNon] / x [CAGoodsNon],
[CALegal] / x [CALegal],
[CALegalNon] / x [CALegalNon],
[CAHousing] / x [CAHousing],
[CAHousingNon] / x [CAHousingNon],
[CAAdvocacy] / x [CAAdvocacy],
[CAAdvocacyNon] / x [CAAdvocacyNon],
[CATranslation] / x [CATranslation],
[CATranslationNon] / x [CATranslationNon],
[CALaborSupport] / x [CALaborSupport],
[CALaborSupportNon] / x [CALaborSupportNon],
[CAChildSupport] / x [CAChildSupport],
[CAChildSupportNon] / x [CAChildSupportNon],
[CAParentRights] / x [CAParentRights],
[CAParentRightsNon] / x [CAParentRightsNon],
[CAVisitation] / x [CAVisitation],
[CAVisitationNon] / x [CAVisitationNon],
[CAOther] / x [CAOther],
[CAOtherNon] / x [CAOtherNon],

[CA1] / x [CA1],
[CA2] / x [CA2],
[Total],

CASE WHEN c.WorkerPK IS NULL THEN 'All Workers' ELSE 
rtrim(c.LastName) + ', ' + rtrim(c.FirstName) END WorkerName

FROM base11 AS a JOIN base2 AS b ON a.FSWFK = b.FSWFK AND a.PC1ID = b.PC1ID
LEFT OUTER JOIN Worker AS c ON 
CASE WHEN (@showWorkerDetail = 'N' AND @workerfk IS NOT NULL) THEN @workerfk 
ELSE a.FSWFK END = c.WorkerPK
ORDER BY WorkerName, a.PC1ID














GO
