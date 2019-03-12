SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVCase](@CaseProgress numeric(3, 1)=NULL,
@Confidentiality bit=NULL,
@CPFK int=NULL,
@DateOBPAdded datetime=NULL,
@EDC datetime=NULL,
@FFFK int=NULL,
@FirstChildDOB datetime=NULL,
@FirstPrenatalCareVisit datetime=NULL,
@FirstPrenatalCareVisitUnknown bit=NULL,
@HVCaseCreator varchar(max)=NULL,
@InitialZip char(10)=NULL,
@IntakeDate datetime=NULL,
@IntakeLevel char(1)=NULL,
@IntakeWorkerFK int=NULL,
@KempeDate datetime=NULL,
@OBPInformationAvailable bit=NULL,
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
@TCNumber int=NULL,
@KempeDate2 datetime=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVCasePK
FROM HVCase lastRow
WHERE 
@CaseProgress = lastRow.CaseProgress AND
@Confidentiality = lastRow.Confidentiality AND
@CPFK = lastRow.CPFK AND
@DateOBPAdded = lastRow.DateOBPAdded AND
@EDC = lastRow.EDC AND
@FFFK = lastRow.FFFK AND
@FirstChildDOB = lastRow.FirstChildDOB AND
@FirstPrenatalCareVisit = lastRow.FirstPrenatalCareVisit AND
@FirstPrenatalCareVisitUnknown = lastRow.FirstPrenatalCareVisitUnknown AND
@HVCaseCreator = lastRow.HVCaseCreator AND
@InitialZip = lastRow.InitialZip AND
@IntakeDate = lastRow.IntakeDate AND
@IntakeLevel = lastRow.IntakeLevel AND
@IntakeWorkerFK = lastRow.IntakeWorkerFK AND
@KempeDate = lastRow.KempeDate AND
@OBPInformationAvailable = lastRow.OBPInformationAvailable AND
@OBPFK = lastRow.OBPFK AND
@OBPinHomeIntake = lastRow.OBPinHomeIntake AND
@OBPRelation2TC = lastRow.OBPRelation2TC AND
@PC1FK = lastRow.PC1FK AND
@PC1Relation2TC = lastRow.PC1Relation2TC AND
@PC1Relation2TCSpecify = lastRow.PC1Relation2TCSpecify AND
@PC2FK = lastRow.PC2FK AND
@PC2inHomeIntake = lastRow.PC2inHomeIntake AND
@PC2Relation2TC = lastRow.PC2Relation2TC AND
@PC2Relation2TCSpecify = lastRow.PC2Relation2TCSpecify AND
@PrenatalCheckupsB4 = lastRow.PrenatalCheckupsB4 AND
@ScreenDate = lastRow.ScreenDate AND
@TCDOB = lastRow.TCDOB AND
@TCDOD = lastRow.TCDOD AND
@TCNumber = lastRow.TCNumber AND
@KempeDate2 = lastRow.KempeDate2
ORDER BY HVCasePK DESC) 
BEGIN
INSERT INTO HVCase(
CaseProgress,
Confidentiality,
CPFK,
DateOBPAdded,
EDC,
FFFK,
FirstChildDOB,
FirstPrenatalCareVisit,
FirstPrenatalCareVisitUnknown,
HVCaseCreator,
InitialZip,
IntakeDate,
IntakeLevel,
IntakeWorkerFK,
KempeDate,
OBPInformationAvailable,
OBPFK,
OBPinHomeIntake,
OBPRelation2TC,
PC1FK,
PC1Relation2TC,
PC1Relation2TCSpecify,
PC2FK,
PC2inHomeIntake,
PC2Relation2TC,
PC2Relation2TCSpecify,
PrenatalCheckupsB4,
ScreenDate,
TCDOB,
TCDOD,
TCNumber,
KempeDate2
)
VALUES(
@CaseProgress,
@Confidentiality,
@CPFK,
@DateOBPAdded,
@EDC,
@FFFK,
@FirstChildDOB,
@FirstPrenatalCareVisit,
@FirstPrenatalCareVisitUnknown,
@HVCaseCreator,
@InitialZip,
@IntakeDate,
@IntakeLevel,
@IntakeWorkerFK,
@KempeDate,
@OBPInformationAvailable,
@OBPFK,
@OBPinHomeIntake,
@OBPRelation2TC,
@PC1FK,
@PC1Relation2TC,
@PC1Relation2TCSpecify,
@PC2FK,
@PC2inHomeIntake,
@PC2Relation2TC,
@PC2Relation2TCSpecify,
@PrenatalCheckupsB4,
@ScreenDate,
@TCDOB,
@TCDOD,
@TCNumber,
@KempeDate2
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
