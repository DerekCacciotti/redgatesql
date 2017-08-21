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
@PC1InHome char(1)=NULL,
@PC1IssuesFK int=NULL,
@PC2InHome char(1)=NULL,
@Pregnant char(1)=NULL,
@ProgramFK int=NULL,
@SafetyPlan bit=NULL,
@SixMonthHome bit=NULL,
@TCDentalCareSource char(2)=NULL,
@TimesPregnant int=NULL)
AS
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
PC1InHome,
PC1IssuesFK,
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
@PC1InHome,
@PC1IssuesFK,
@PC2InHome,
@Pregnant,
@ProgramFK,
@SafetyPlan,
@SixMonthHome,
@TCDentalCareSource,
@TimesPregnant
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
