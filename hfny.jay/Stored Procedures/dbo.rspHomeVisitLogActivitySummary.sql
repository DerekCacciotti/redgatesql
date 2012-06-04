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
	@programfk INT = NULL, 
    @supervisorfk INT = NULL, 
    @workerfk INT = NULL,
	@StartDt datetime,
	@EndDt datetime
AS


DECLARE @x INT = 0
SELECT @x = sum(CASE substring(VisitType,4,1) WHEN '1' THEN 0 ELSE 1 END) 

FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN workerprogram wp
ON wp.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON wp.supervisorfk = supervisor.workerpk

WHERE 
a.ProgramFK = @programfk 
AND VisitStartTime between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)

IF @x = 0 
BEGIN
  SET @x = 1
END

SELECT 
count(DISTINCT HVCaseFK) [UniqueFamilies],
sum(CASE substring(VisitType,4,1) WHEN '1' THEN 1 ELSE 0 END) [Attempted] , 
sum(CASE substring(VisitType,4,1) WHEN '1' THEN 0 ELSE 1 END) [CompletedVisit],
sum(CASE WHEN substring(VisitType,1,3) IN ('100', '110', '010')  THEN 1 ELSE 0 END) [InHome],
sum(CASE WHEN substring(VisitType,1,3) = '001' THEN 1 ELSE 0 END) [OutOfHome],
sum(CASE WHEN substring(VisitType,1,3) IN ('101', '111', '011')  THEN 1 ELSE 0 END) [BothInAndOutHome],
sum(VisitLengthHour * 60 + VisitLengthMinute) / @x [AvgMinuteForCompletedVisit],

sum(CASE WHEN PC1Participated = 1 THEN 1 ELSE 0 END) * 100 / @x [PC1Participated],
sum(CASE WHEN PC2Participated  = 1 THEN 1 ELSE 0 END) * 100 / @x [PC2Participated],
sum(CASE WHEN OBPParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [OBPParticipated],
sum(CASE WHEN FatherFigureParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [FatherFigureParticipated], 
sum(CASE WHEN TCParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [TCParticipated],
sum(CASE WHEN GrandParentParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [GrandParentParticipated],
sum(CASE WHEN SiblingParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [SiblingParticipated],
sum(CASE WHEN NonPrimaryFSWParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [NonPrimaryFSWParticipated],
sum(CASE WHEN HVSupervisorParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [HVSupervisorParticipated],
sum(CASE WHEN SupervisorObservation  = 1 THEN 1 ELSE 0 END) * 100 / @x [SupervisorObservation],
sum(CASE WHEN OtherParticipated  = 1 THEN 1 ELSE 0 END) * 100 / @x [OtherParticipated],

-- child development
sum(CASE WHEN substring(CDChildDevelopment,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDChildDevelopment],
sum(CASE WHEN substring(CDChildDevelopment,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDChildDevelopmentNon],
sum(CASE WHEN substring(CDToys,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDToys],
sum(CASE WHEN substring(CDToys,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDToysNon],
sum(CASE WHEN substring(CDOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDOther],
sum(CASE WHEN substring(CDOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CDOtherNon],

-- parent/child interaction
sum(CASE WHEN substring(PCChildInteraction,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCChildInteraction],
sum(CASE WHEN substring(PCChildInteraction,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCChildInteractionNon],
sum(CASE WHEN substring(PCChildManagement,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCChildManagement],
sum(CASE WHEN substring(PCChildManagement,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCChildManagementNon],
sum(CASE WHEN substring(PCFeelings,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCFeelings],
sum(CASE WHEN substring(PCFeelings,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCFeelingsNon],
sum(CASE WHEN substring(PCStress,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCStress],
sum(CASE WHEN substring(PCStress,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCStressNon],
sum(CASE WHEN substring(PCBasicNeeds,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCBasicNeeds],
sum(CASE WHEN substring(PCBasicNeeds,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCBasicNeedsNon],
sum(CASE WHEN substring(PCShakenBaby,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCShakenBaby],
sum(CASE WHEN substring(PCShakenBaby,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCShakenBabyNon],
sum(CASE WHEN substring(PCShakenBabyVideo,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCShakenBabyVideo],
sum(CASE WHEN substring(PCShakenBabyVideo,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCShakenBabyVideoNon],
sum(CASE WHEN substring(PCOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCOther],
sum(CASE WHEN substring(PCOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PCOtherNon],

-- Health care
sum(CASE WHEN substring(HCGeneral,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCGeneral],
sum(CASE WHEN substring(HCGeneral,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCGeneralNon],
sum(CASE WHEN substring(HCChild,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCChild],
sum(CASE WHEN substring(HCChild,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCChildNon],
sum(CASE WHEN substring(HCDental,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCDental],
sum(CASE WHEN substring(HCDental,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCDentalNon],
sum(CASE WHEN substring(HCFeeding,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFeeding],
sum(CASE WHEN substring(HCFeeding,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFeedingNon],
sum(CASE WHEN substring(HCBreastFeeding,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCBreastFeeding],
sum(CASE WHEN substring(HCBreastFeeding,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCBreastFeedingNon],
sum(CASE WHEN substring(HCNutrition,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCNutrition],
sum(CASE WHEN substring(HCNutrition,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCNutritionNon],
sum(CASE WHEN substring(HCFamilyPlanning,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFamilyPlanning],
sum(CASE WHEN substring(HCFamilyPlanning,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFamilyPlanningNon],
sum(CASE WHEN substring(HCProviders,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCProviders],
sum(CASE WHEN substring(HCProviders,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCProvidersNon],
sum(CASE WHEN substring(HCFASD,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFASD],
sum(CASE WHEN substring(HCFASD,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCFASDNon],
sum(CASE WHEN substring(HCSexEducation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSexEducation],
sum(CASE WHEN substring(HCSexEducation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSexEducationNon],
sum(CASE WHEN substring(HCPrenatalCare,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCPrenatalCare],
sum(CASE WHEN substring(HCPrenatalCare,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCPrenatalCareNon],
sum(CASE WHEN substring(HCMedicalAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCMedicalAdvocacy],
sum(CASE WHEN substring(HCMedicalAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCMedicalAdvocacyNon],
sum(CASE WHEN substring(HCSafety,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSafety],
sum(CASE WHEN substring(HCSafety,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSafetyNon],
sum(CASE WHEN substring(HCSmoking,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSmoking],
sum(CASE WHEN substring(HCSmoking,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSmokingNon],
sum(CASE WHEN substring(HCSIDS,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSIDS],
sum(CASE WHEN substring(HCSIDS,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCSIDSNon],
sum(CASE WHEN substring(HCOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCOther],
sum(CASE WHEN substring(HCOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [HCOtherNon],

-- family functioning
sum(CASE WHEN substring(FFDomesticViolence,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFDomesticViolence],
sum(CASE WHEN substring(FFDomesticViolence,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFDomesticViolenceNon],
sum(CASE WHEN substring(FFFamilyRelations,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFFamilyRelations],
sum(CASE WHEN substring(FFFamilyRelations,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFFamilyRelationsNon],
sum(CASE WHEN substring(FFSubstanceAbuse,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFSubstanceAbuse],
sum(CASE WHEN substring(FFSubstanceAbuse,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFSubstanceAbuseNon],
sum(CASE WHEN substring(FFMentalHealth,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFMentalHealth],
sum(CASE WHEN substring(FFMentalHealth,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFMentalHealthNon],
sum(CASE WHEN substring(FFCommunication,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFCommunication],
sum(CASE WHEN substring(FFCommunication,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFCommunicationNon],
sum(CASE WHEN substring(FFOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFOther],
sum(CASE WHEN substring(FFOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [FFOtherNon],

-- self sufficiency
sum(CASE WHEN substring(SSCalendar,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSCalendar],
sum(CASE WHEN substring(SSCalendar,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSCalendarNon],
sum(CASE WHEN substring(SSHousekeeping,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSHousekeeping],
sum(CASE WHEN substring(SSHousekeeping,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSHousekeepingNon],
sum(CASE WHEN substring(SSTransportation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSTransportation],
sum(CASE WHEN substring(SSTransportation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSTransportationNon],
sum(CASE WHEN substring(SSEmployment,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSEmployment],
sum(CASE WHEN substring(SSEmployment,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSEmploymentNon],
sum(CASE WHEN substring(SSMoneyManagement,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSMoneyManagement],
sum(CASE WHEN substring(SSMoneyManagement,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSMoneyManagementNon],
sum(CASE WHEN substring(SSChildCare,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSChildCare],
sum(CASE WHEN substring(SSChildCare,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSChildCareNon],
sum(CASE WHEN substring(SSProblemSolving,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSProblemSolving],
sum(CASE WHEN substring(SSProblemSolving,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSProblemSolvingNon],
sum(CASE WHEN substring(SSEducation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSEducation],
sum(CASE WHEN substring(SSEducation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSEducationNon],
sum(CASE WHEN substring(SSJob,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSJob],
sum(CASE WHEN substring(SSJob,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSJobNon],
sum(CASE WHEN substring(SSOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSOther],
sum(CASE WHEN substring(SSOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [SSOtherNon],

-- crisis intervention
sum(CASE WHEN substring(CIProblems,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CIProblems],
sum(CASE WHEN substring(CIProblems,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CIProblemsNon],
sum(CASE WHEN substring(CIOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CIOther],
sum(CASE WHEN substring(CIOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CIOtherNon],

-- program activities
sum(CASE WHEN substring(PAForms,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAForms],
sum(CASE WHEN substring(PAForms,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAFormsNon],
sum(CASE WHEN substring(PAVideo,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAVideo],
sum(CASE WHEN substring(PAVideo,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAVideoNon],
sum(CASE WHEN substring(PAGroups,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAGroups],
sum(CASE WHEN substring(PAGroups,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAGroupsNon],
sum(CASE WHEN substring(PAIFSP,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAIFSP],
sum(CASE WHEN substring(PAIFSP,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAIFSPNon],
sum(CASE WHEN substring(PARecreation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PARecreation],
sum(CASE WHEN substring(PARecreation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PARecreationNon],
sum(CASE WHEN substring(PAOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAOther],
sum(CASE WHEN substring(PAOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [PAOtherNon],

-- concrete activities
sum(CASE WHEN substring(CATransportation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CATransportation],
sum(CASE WHEN substring(CATransportation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CATransportationNon],
sum(CASE WHEN substring(CAGoods,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAGoods],
sum(CASE WHEN substring(CAGoods,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAGoodsNon],
sum(CASE WHEN substring(CALegal,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CALegal],
sum(CASE WHEN substring(CALegal,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CALegalNon],
sum(CASE WHEN substring(CAHousing,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAHousing],
sum(CASE WHEN substring(CAHousing,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAHousingNon],
sum(CASE WHEN substring(CAAdvocacy,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAAdvocacy],
sum(CASE WHEN substring(CAAdvocacy,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAAdvocacyNon],
sum(CASE WHEN substring(CATranslation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CATranslation],
sum(CASE WHEN substring(CATranslation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CATranslationNon],
sum(CASE WHEN substring(CALaborSupport,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CALaborSupport],
sum(CASE WHEN substring(CALaborSupport,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CALaborSupportNon],
sum(CASE WHEN substring(CAChildSupport,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAChildSupport],
sum(CASE WHEN substring(CAChildSupport,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAChildSupportNon],
sum(CASE WHEN substring(CAParentRights,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAParentRights],
sum(CASE WHEN substring(CAParentRights,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAParentRightsNon],
sum(CASE WHEN substring(CAVisitation,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAVisitation],
sum(CASE WHEN substring(CAVisitation,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAVisitationNon],
sum(CASE WHEN substring(CAOther,1,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAOther],
sum(CASE WHEN substring(CAOther,2,1) = '1' THEN 1 ELSE 0 END) * 100 / @x [CAOtherNon],

count(*) [Total]

FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN workerprogram wp
ON wp.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON wp.supervisorfk = supervisor.workerpk

WHERE 
a.ProgramFK = @programfk 
AND VisitStartTime between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)















GO
