SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPC](@PCPK int=NULL,
@BirthCountry char(30)=NULL,
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
@PCDOB datetime=NULL,
@PCDOD datetime=NULL,
@PCEditor varchar(max)=NULL,
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
UPDATE PC
SET 
BirthCountry = @BirthCountry, 
BornUSA = @BornUSA, 
CP = @CP, 
Ethnicity = @Ethnicity, 
Gender = @Gender, 
OBP = @OBP, 
PC1 = @PC1, 
PC2 = @PC2, 
PCApt = @PCApt, 
PCCellPhone = @PCCellPhone, 
PCCity = @PCCity, 
PCDOB = @PCDOB, 
PCDOD = @PCDOD, 
PCEditor = @PCEditor, 
PCEmail = @PCEmail, 
PCEmergencyPhone = @PCEmergencyPhone, 
PCFirstName = @PCFirstName, 
PCLastName = @PCLastName, 
PCMiddleInitial = @PCMiddleInitial, 
PCNoPhone = @PCNoPhone, 
PCOldName = @PCOldName, 
PCOldName2 = @PCOldName2, 
PCPhone = @PCPhone, 
PCPK_old = @PCPK_old, 
PCState = @PCState, 
PCStreet = @PCStreet, 
PCZip = @PCZip, 
Race = @Race, 
RaceSpecify = @RaceSpecify, 
SSNo = @SSNo, 
TimesMoved = @TimesMoved, 
YearsInUSA = @YearsInUSA
WHERE PCPK = @PCPK
GO
