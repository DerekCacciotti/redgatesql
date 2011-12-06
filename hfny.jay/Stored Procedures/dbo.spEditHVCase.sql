
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVCase](@HVCasePK int=NULL,
@CaseProgress numeric(3, 1)=NULL,
@Confidentiality bit=NULL,
@CPFK int=NULL,
@DateOBPAdded datetime=NULL,
@EDC datetime=NULL,
@FFFK int=NULL,
@FirstChildDOB datetime=NULL,
@FirstPrenatalCareVisit datetime=NULL,
@FirstPrenatalCareVisitUnknown bit=NULL,
@HVCaseEditor char(10)=NULL,
@InitialZip char(10)=NULL,
@IntakeDate datetime=NULL,
@IntakeLevel char(1)=NULL,
@IntakeWorkerFK int=NULL,
@KempeDate datetime=NULL,
@NoOBP bit=NULL,
@OBPFK int=NULL,
@OBPinHomeIntake bit=NULL,
@OBPRelation2TC char(2)=NULL,
@PC1FK int=NULL,
@PC1Relation2TC char(2)=NULL,
@PC1Relation2TCSpecify varchar(30)=NULL,
@PC2FK int=NULL,
@PC2inHomeIntake bit=NULL,
@PC2Relation2TC char(2)=NULL,
@PC2Relation2TCSpecify varchar(30)=NULL,
@PrenatalCheckupsB4 int=NULL,
@ScreenDate datetime=NULL,
@TCDOB datetime=NULL,
@TCDOD datetime=NULL,
@TCNumber int=NULL)
AS
UPDATE HVCase
SET 
CaseProgress = @CaseProgress, 
Confidentiality = @Confidentiality, 
CPFK = @CPFK, 
DateOBPAdded = @DateOBPAdded, 
EDC = @EDC, 
FFFK = @FFFK, 
FirstChildDOB = @FirstChildDOB, 
FirstPrenatalCareVisit = @FirstPrenatalCareVisit, 
FirstPrenatalCareVisitUnknown = @FirstPrenatalCareVisitUnknown, 
HVCaseEditor = @HVCaseEditor, 
InitialZip = @InitialZip, 
IntakeDate = @IntakeDate, 
IntakeLevel = @IntakeLevel, 
IntakeWorkerFK = @IntakeWorkerFK, 
KempeDate = @KempeDate, 
NoOBP = @NoOBP, 
OBPFK = @OBPFK, 
OBPinHomeIntake = @OBPinHomeIntake, 
OBPRelation2TC = @OBPRelation2TC, 
PC1FK = @PC1FK, 
PC1Relation2TC = @PC1Relation2TC, 
PC1Relation2TCSpecify = @PC1Relation2TCSpecify, 
PC2FK = @PC2FK, 
PC2inHomeIntake = @PC2inHomeIntake, 
PC2Relation2TC = @PC2Relation2TC, 
PC2Relation2TCSpecify = @PC2Relation2TCSpecify, 
PrenatalCheckupsB4 = @PrenatalCheckupsB4, 
ScreenDate = @ScreenDate, 
TCDOB = @TCDOB, 
TCDOD = @TCDOD, 
TCNumber = @TCNumber
WHERE HVCasePK = @HVCasePK
GO
