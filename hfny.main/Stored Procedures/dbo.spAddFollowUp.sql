SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFollowUp](@BCAbstinence bit=NULL,
@BCCervicalCap bit=NULL,
@BCCondom bit=NULL,
@BCDiaphragm bit=NULL,
@BCEmergencyContraception bit=NULL,
@BCFemaleCondom bit=NULL,
@BCImplant bit=NULL,
@BCIUD bit=NULL,
@BCPatch bit=NULL,
@BCPill bit=NULL,
@BCShot bit=NULL,
@BCSpermicide bit=NULL,
@BCSterilization bit=NULL,
@BCVaginalRing bit=NULL,
@BCVasectomy bit=NULL,
@BCWithdrawal bit=NULL,
@BCRhythm bit=NULL,
@BirthControlUse char(1)=NULL,
@CPSACSReport bit=NULL,
@DYFSOpenCase char(1)=NULL,
@DYFSReport char(1)=NULL,
@DYFSReportBy char(2)=NULL,
@DYFSReportBySpecify varchar(100)=NULL,
@DYFSSubstantiated char(1)=NULL,
@FollowUpCreator char(10)=NULL,
@FollowUpDate datetime=NULL,
@FollowUpInterval char(2)=NULL,
@FSWFK int=NULL,
@FUPInWindow bit=NULL,
@HealthCareCoverageContinuity bit=NULL,
@HOMECompleted bit=NULL,
@HVCaseFK int=NULL,
@IFSPAdultRelationship char(1)=NULL,
@IFSPChildDevelopment char(1)=NULL,
@IFSPChildHealthSafety char(1)=NULL,
@IFSPEducation char(1)=NULL,
@IFSPEmployment char(1)=NULL,
@IFSPFamilyPlanning char(1)=NULL,
@IFSPHousing char(1)=NULL,
@IFSPNonTC char(1)=NULL,
@IFSPParentChildInteraction char(1)=NULL,
@IFSPParentHealthSafety char(1)=NULL,
@LeadAssessment char(1)=NULL,
@LiveBirths char(1)=NULL,
@MonthsBirthControlUse int=NULL,
@OtherChildrenDevelopmentDelays char(1)=NULL,
@PC1ChildrenLowStudentAchievement char(1)=NULL,
@PC1FamilyArmedForces char(1)=NULL,
@PC1InHome char(1)=NULL,
@PC1IssuesFK int=NULL,
@PC1SelfLowStudentAchievement char(1)=NULL,
@PC2InHome char(1)=NULL,
@Pregnant char(1)=NULL,
@ProgramFK int=NULL,
@SafetyPlan bit=NULL,
@SixMonthHome bit=NULL,
@TCDentalCareSource char(2)=NULL,
@TimesPregnant int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) FollowUpPK
FROM FollowUp lastRow
WHERE 
@BCAbstinence = lastRow.BCAbstinence AND
@BCCervicalCap = lastRow.BCCervicalCap AND
@BCCondom = lastRow.BCCondom AND
@BCDiaphragm = lastRow.BCDiaphragm AND
@BCEmergencyContraception = lastRow.BCEmergencyContraception AND
@BCFemaleCondom = lastRow.BCFemaleCondom AND
@BCImplant = lastRow.BCImplant AND
@BCIUD = lastRow.BCIUD AND
@BCPatch = lastRow.BCPatch AND
@BCPill = lastRow.BCPill AND
@BCShot = lastRow.BCShot AND
@BCSpermicide = lastRow.BCSpermicide AND
@BCSterilization = lastRow.BCSterilization AND
@BCVaginalRing = lastRow.BCVaginalRing AND
@BCVasectomy = lastRow.BCVasectomy AND
@BCWithdrawal = lastRow.BCWithdrawal AND
@BCRhythm = lastRow.BCRhythm AND
@BirthControlUse = lastRow.BirthControlUse AND
@CPSACSReport = lastRow.CPSACSReport AND
@DYFSOpenCase = lastRow.DYFSOpenCase AND
@DYFSReport = lastRow.DYFSReport AND
@DYFSReportBy = lastRow.DYFSReportBy AND
@DYFSReportBySpecify = lastRow.DYFSReportBySpecify AND
@DYFSSubstantiated = lastRow.DYFSSubstantiated AND
@FollowUpCreator = lastRow.FollowUpCreator AND
@FollowUpDate = lastRow.FollowUpDate AND
@FollowUpInterval = lastRow.FollowUpInterval AND
@FSWFK = lastRow.FSWFK AND
@FUPInWindow = lastRow.FUPInWindow AND
@HealthCareCoverageContinuity = lastRow.HealthCareCoverageContinuity AND
@HOMECompleted = lastRow.HOMECompleted AND
@HVCaseFK = lastRow.HVCaseFK AND
@IFSPAdultRelationship = lastRow.IFSPAdultRelationship AND
@IFSPChildDevelopment = lastRow.IFSPChildDevelopment AND
@IFSPChildHealthSafety = lastRow.IFSPChildHealthSafety AND
@IFSPEducation = lastRow.IFSPEducation AND
@IFSPEmployment = lastRow.IFSPEmployment AND
@IFSPFamilyPlanning = lastRow.IFSPFamilyPlanning AND
@IFSPHousing = lastRow.IFSPHousing AND
@IFSPNonTC = lastRow.IFSPNonTC AND
@IFSPParentChildInteraction = lastRow.IFSPParentChildInteraction AND
@IFSPParentHealthSafety = lastRow.IFSPParentHealthSafety AND
@LeadAssessment = lastRow.LeadAssessment AND
@LiveBirths = lastRow.LiveBirths AND
@MonthsBirthControlUse = lastRow.MonthsBirthControlUse AND
@OtherChildrenDevelopmentDelays = lastRow.OtherChildrenDevelopmentDelays AND
@PC1ChildrenLowStudentAchievement = lastRow.PC1ChildrenLowStudentAchievement AND
@PC1FamilyArmedForces = lastRow.PC1FamilyArmedForces AND
@PC1InHome = lastRow.PC1InHome AND
@PC1IssuesFK = lastRow.PC1IssuesFK AND
@PC1SelfLowStudentAchievement = lastRow.PC1SelfLowStudentAchievement AND
@PC2InHome = lastRow.PC2InHome AND
@Pregnant = lastRow.Pregnant AND
@ProgramFK = lastRow.ProgramFK AND
@SafetyPlan = lastRow.SafetyPlan AND
@SixMonthHome = lastRow.SixMonthHome AND
@TCDentalCareSource = lastRow.TCDentalCareSource AND
@TimesPregnant = lastRow.TimesPregnant
ORDER BY FollowUpPK DESC) 
BEGIN
INSERT INTO FollowUp(
BCAbstinence,
BCCervicalCap,
BCCondom,
BCDiaphragm,
BCEmergencyContraception,
BCFemaleCondom,
BCImplant,
BCIUD,
BCPatch,
BCPill,
BCShot,
BCSpermicide,
BCSterilization,
BCVaginalRing,
BCVasectomy,
BCWithdrawal,
BCRhythm,
BirthControlUse,
CPSACSReport,
DYFSOpenCase,
DYFSReport,
DYFSReportBy,
DYFSReportBySpecify,
DYFSSubstantiated,
FollowUpCreator,
FollowUpDate,
FollowUpInterval,
FSWFK,
FUPInWindow,
HealthCareCoverageContinuity,
HOMECompleted,
HVCaseFK,
IFSPAdultRelationship,
IFSPChildDevelopment,
IFSPChildHealthSafety,
IFSPEducation,
IFSPEmployment,
IFSPFamilyPlanning,
IFSPHousing,
IFSPNonTC,
IFSPParentChildInteraction,
IFSPParentHealthSafety,
LeadAssessment,
LiveBirths,
MonthsBirthControlUse,
OtherChildrenDevelopmentDelays,
PC1ChildrenLowStudentAchievement,
PC1FamilyArmedForces,
PC1InHome,
PC1IssuesFK,
PC1SelfLowStudentAchievement,
PC2InHome,
Pregnant,
ProgramFK,
SafetyPlan,
SixMonthHome,
TCDentalCareSource,
TimesPregnant
)
VALUES(
@BCAbstinence,
@BCCervicalCap,
@BCCondom,
@BCDiaphragm,
@BCEmergencyContraception,
@BCFemaleCondom,
@BCImplant,
@BCIUD,
@BCPatch,
@BCPill,
@BCShot,
@BCSpermicide,
@BCSterilization,
@BCVaginalRing,
@BCVasectomy,
@BCWithdrawal,
@BCRhythm,
@BirthControlUse,
@CPSACSReport,
@DYFSOpenCase,
@DYFSReport,
@DYFSReportBy,
@DYFSReportBySpecify,
@DYFSSubstantiated,
@FollowUpCreator,
@FollowUpDate,
@FollowUpInterval,
@FSWFK,
@FUPInWindow,
@HealthCareCoverageContinuity,
@HOMECompleted,
@HVCaseFK,
@IFSPAdultRelationship,
@IFSPChildDevelopment,
@IFSPChildHealthSafety,
@IFSPEducation,
@IFSPEmployment,
@IFSPFamilyPlanning,
@IFSPHousing,
@IFSPNonTC,
@IFSPParentChildInteraction,
@IFSPParentHealthSafety,
@LeadAssessment,
@LiveBirths,
@MonthsBirthControlUse,
@OtherChildrenDevelopmentDelays,
@PC1ChildrenLowStudentAchievement,
@PC1FamilyArmedForces,
@PC1InHome,
@PC1IssuesFK,
@PC1SelfLowStudentAchievement,
@PC2InHome,
@Pregnant,
@ProgramFK,
@SafetyPlan,
@SixMonthHome,
@TCDentalCareSource,
@TimesPregnant
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
