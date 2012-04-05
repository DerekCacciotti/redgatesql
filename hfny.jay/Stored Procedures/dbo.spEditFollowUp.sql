
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditFollowUp](@FollowUpPK int=NULL,
@BCAbstinence bit=NULL,
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
@BCSterization bit=NULL,
@BCVaginalRing bit=NULL,
@BCVasectomy bit=NULL,
@BCWithdrawal bit=NULL,
@BirthControlUse char(1)=NULL,
@CPSACSReport bit=NULL,
@DYFSOpenCase char(1)=NULL,
@DYFSReport char(1)=NULL,
@DYFSReportBy char(2)=NULL,
@DYFSReportBySpecify varchar(100)=NULL,
@DYFSSubstantiated char(1)=NULL,
@FollowUpDate datetime=NULL,
@FollowUpEditor char(10)=NULL,
@FollowUpInterval char(2)=NULL,
@FSWFK int=NULL,
@FUPInWindow bit=NULL,
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
@TimesPregnant int=NULL)
AS
UPDATE FollowUp
SET 
BCAbstinence = @BCAbstinence, 
BCCervicalCap = @BCCervicalCap, 
BCCondom = @BCCondom, 
BCDiaphragm = @BCDiaphragm, 
BCEmergencyContraception = @BCEmergencyContraception, 
BCFemaleCondom = @BCFemaleCondom, 
BCImplant = @BCImplant, 
BCIUD = @BCIUD, 
BCPatch = @BCPatch, 
BCPill = @BCPill, 
BCShot = @BCShot, 
BCSpermicide = @BCSpermicide, 
BCSterization = @BCSterization, 
BCVaginalRing = @BCVaginalRing, 
BCVasectomy = @BCVasectomy, 
BCWithdrawal = @BCWithdrawal, 
BirthControlUse = @BirthControlUse, 
CPSACSReport = @CPSACSReport, 
DYFSOpenCase = @DYFSOpenCase, 
DYFSReport = @DYFSReport, 
DYFSReportBy = @DYFSReportBy, 
DYFSReportBySpecify = @DYFSReportBySpecify, 
DYFSSubstantiated = @DYFSSubstantiated, 
FollowUpDate = @FollowUpDate, 
FollowUpEditor = @FollowUpEditor, 
FollowUpInterval = @FollowUpInterval, 
FSWFK = @FSWFK, 
FUPInWindow = @FUPInWindow, 
HVCaseFK = @HVCaseFK, 
IFSPAdultRelationship = @IFSPAdultRelationship, 
IFSPChildDevelopment = @IFSPChildDevelopment, 
IFSPChildHealthSafety = @IFSPChildHealthSafety, 
IFSPEducation = @IFSPEducation, 
IFSPEmployment = @IFSPEmployment, 
IFSPFamilyPlanning = @IFSPFamilyPlanning, 
IFSPHousing = @IFSPHousing, 
IFSPNonTC = @IFSPNonTC, 
IFSPParentChildInteraction = @IFSPParentChildInteraction, 
IFSPParentHealthSafety = @IFSPParentHealthSafety, 
LeadAssessment = @LeadAssessment, 
LiveBirths = @LiveBirths, 
MonthsBirthControlUse = @MonthsBirthControlUse, 
PC1InHome = @PC1InHome, 
PC1IssuesFK = @PC1IssuesFK, 
PC2InHome = @PC2InHome, 
Pregnant = @Pregnant, 
ProgramFK = @ProgramFK, 
TimesPregnant = @TimesPregnant
WHERE FollowUpPK = @FollowUpPK
GO
