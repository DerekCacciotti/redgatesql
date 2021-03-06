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
@PCCreator varchar(max)=NULL,
@PCDOB datetime=NULL,
@PCDOD datetime=NULL,
@PCEmail varchar(50)=NULL,
@PCEmergencyPhone varchar(12)=NULL,
@PCFirstName varchar(200)=NULL,
@PCLastName varchar(200)=NULL,
@PCMiddleInitial varchar(200)=NULL,
@PCNoPhone bit=NULL,
@PCOldName varchar(400)=NULL,
@PCSuffix varchar(50)=NULL,
@PCOldName2 varchar(400)=NULL,
@PCPhone char(12)=NULL,
@PCPK_old int=NULL,
@PCState char(2)=NULL,
@PCStreet varchar(200)=NULL,
@PCZip varchar(200)=NULL,
@Race char(2)=NULL,
@RaceSpecify varchar(500)=NULL,
@TimesMoved int=NULL,
@YearsInUSA numeric(4, 0)=NULL,
@PrefersTextMessages bit=NULL,
@Race_AmericanIndian bit=NULL,
@Race_Asian bit=NULL,
@Race_Black bit=NULL,
@Race_Hawaiian bit=NULL,
@Race_White bit=NULL,
@Race_Hispanic bit=NULL,
@Race_Other bit=NULL)
AS
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
PCSuffix,
PCOldName2,
PCPhone,
PCPK_old,
PCState,
PCStreet,
PCZip,
Race,
RaceSpecify,
TimesMoved,
YearsInUSA,
PrefersTextMessages,
Race_AmericanIndian,
Race_Asian,
Race_Black,
Race_Hawaiian,
Race_White,
Race_Hispanic,
Race_Other
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
@PCSuffix,
@PCOldName2,
@PCPhone,
@PCPK_old,
@PCState,
@PCStreet,
@PCZip,
@Race,
@RaceSpecify,
@TimesMoved,
@YearsInUSA,
@PrefersTextMessages,
@Race_AmericanIndian,
@Race_Asian,
@Race_Black,
@Race_Hawaiian,
@Race_White,
@Race_Hispanic,
@Race_Other
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
