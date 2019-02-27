SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC](@BirthCountry char(30)=NULL,
@BornUSA char(1)=NULL,
@CP bit=NULL,
@Ethnicity varchar(500)=NULL,
@Gender char(2)=NULL,
@OBP bit=NULL,
@PC1 bit=NULL,
@PC2 bit=NULL,
@PCApt varchar(200)=NULL,
@PCCellPhone varchar(12)=NULL,
@PCCity varchar(200)=NULL,
@PCCreator char(10)=NULL,
@PCDOB datetime=NULL,
@PCDOD datetime=NULL,
@PCEmail varchar(50)=NULL,
@PCEmergencyPhone varchar(12)=NULL,
@PCFirstName varchar(200)=NULL,
@PCLastName varchar(200)=NULL,
@PCMiddleInitial varchar(200)=NULL,
@PCNoPhone bit=NULL,
@PCOldName varchar(400)=NULL,
@PCOldName2 varchar(400)=NULL,
@PCPhone char(12)=NULL,
@PCPK_old int=NULL,
@PCState char(2)=NULL,
@PCStreet varchar(200)=NULL,
@PCZip varchar(200)=NULL,
@Race char(2)=NULL,
@RaceSpecify varchar(500)=NULL,
@SSNo varchar(200)=NULL,
@TimesMoved int=NULL,
@YearsInUSA numeric(4, 0)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PCPK
FROM PC lastRow
WHERE 
@BirthCountry = lastRow.BirthCountry AND
@BornUSA = lastRow.BornUSA AND
@CP = lastRow.CP AND
@Ethnicity = lastRow.Ethnicity AND
@Gender = lastRow.Gender AND
@OBP = lastRow.OBP AND
@PC1 = lastRow.PC1 AND
@PC2 = lastRow.PC2 AND
@PCApt = lastRow.PCApt AND
@PCCellPhone = lastRow.PCCellPhone AND
@PCCity = lastRow.PCCity AND
@PCCreator = lastRow.PCCreator AND
@PCDOB = lastRow.PCDOB AND
@PCDOD = lastRow.PCDOD AND
@PCEmail = lastRow.PCEmail AND
@PCEmergencyPhone = lastRow.PCEmergencyPhone AND
@PCFirstName = lastRow.PCFirstName AND
@PCLastName = lastRow.PCLastName AND
@PCMiddleInitial = lastRow.PCMiddleInitial AND
@PCNoPhone = lastRow.PCNoPhone AND
@PCOldName = lastRow.PCOldName AND
@PCOldName2 = lastRow.PCOldName2 AND
@PCPhone = lastRow.PCPhone AND
@PCPK_old = lastRow.PCPK_old AND
@PCState = lastRow.PCState AND
@PCStreet = lastRow.PCStreet AND
@PCZip = lastRow.PCZip AND
@Race = lastRow.Race AND
@RaceSpecify = lastRow.RaceSpecify AND
@SSNo = lastRow.SSNo AND
@TimesMoved = lastRow.TimesMoved AND
@YearsInUSA = lastRow.YearsInUSA
ORDER BY PCPK DESC) 
BEGIN
INSERT INTO PC(
BirthCountry,
BornUSA,
CP,
Ethnicity,
Gender,
OBP,
PC1,
PC2,
PCApt,
PCCellPhone,
PCCity,
PCCreator,
PCDOB,
PCDOD,
PCEmail,
PCEmergencyPhone,
PCFirstName,
PCLastName,
PCMiddleInitial,
PCNoPhone,
PCOldName,
PCOldName2,
PCPhone,
PCPK_old,
PCState,
PCStreet,
PCZip,
Race,
RaceSpecify,
SSNo,
TimesMoved,
YearsInUSA
)
VALUES(
@BirthCountry,
@BornUSA,
@CP,
@Ethnicity,
@Gender,
@OBP,
@PC1,
@PC2,
@PCApt,
@PCCellPhone,
@PCCity,
@PCCreator,
@PCDOB,
@PCDOD,
@PCEmail,
@PCEmergencyPhone,
@PCFirstName,
@PCLastName,
@PCMiddleInitial,
@PCNoPhone,
@PCOldName,
@PCOldName2,
@PCPhone,
@PCPK_old,
@PCState,
@PCStreet,
@PCZip,
@Race,
@RaceSpecify,
@SSNo,
@TimesMoved,
@YearsInUSA
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
