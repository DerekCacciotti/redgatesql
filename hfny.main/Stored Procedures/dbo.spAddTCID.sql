SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTCID](@BirthTerm char(2)=NULL,
@BirthWtLbs int=NULL,
@BirthWtOz int=NULL,
@DeliveryType char(2)=NULL,
@Ethnicity varchar(500)=NULL,
@FedBreastMilk bit=NULL,
@FSWFK int=NULL,
@GestationalAge int=NULL,
@HVCaseFK int=NULL,
@IntensiveCare char(1)=NULL,
@MultipleBirth bit=NULL,
@NoImmunization bit=NULL,
@NumberofChildren int=NULL,
@ProgramFK int=NULL,
@Race char(2)=NULL,
@RaceSpecify varchar(500)=NULL,
@SmokedPregnant char(1)=NULL,
@TCDOB datetime=NULL,
@TCDOD datetime=NULL,
@TCFirstName varchar(200)=NULL,
@TCGender char(2)=NULL,
@TCIDCreator char(10)=NULL,
@TCIDFormCompleteDate datetime=NULL,
@TCIDPK_old int=NULL,
@TCLastName varchar(200)=NULL,
@VaricellaZoster bit=NULL,
@NoImmunizationsReason char(2)=NULL,
@MIECHV_Race_AmericanIndian bit=NULL,
@MIECHV_Race_Asian bit=NULL,
@MIECHV_Race_Black bit=NULL,
@MIECHV_Race_Hawaiian bit=NULL,
@MIECHV_Race_White bit=NULL,
@MIECHV_Hispanic nvarchar(1)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TCIDPK
FROM TCID lastRow
WHERE 
@BirthTerm = lastRow.BirthTerm AND
@BirthWtLbs = lastRow.BirthWtLbs AND
@BirthWtOz = lastRow.BirthWtOz AND
@DeliveryType = lastRow.DeliveryType AND
@Ethnicity = lastRow.Ethnicity AND
@FedBreastMilk = lastRow.FedBreastMilk AND
@FSWFK = lastRow.FSWFK AND
@GestationalAge = lastRow.GestationalAge AND
@HVCaseFK = lastRow.HVCaseFK AND
@IntensiveCare = lastRow.IntensiveCare AND
@MultipleBirth = lastRow.MultipleBirth AND
@NoImmunization = lastRow.NoImmunization AND
@NumberofChildren = lastRow.NumberofChildren AND
@ProgramFK = lastRow.ProgramFK AND
@Race = lastRow.Race AND
@RaceSpecify = lastRow.RaceSpecify AND
@SmokedPregnant = lastRow.SmokedPregnant AND
@TCDOB = lastRow.TCDOB AND
@TCDOD = lastRow.TCDOD AND
@TCFirstName = lastRow.TCFirstName AND
@TCGender = lastRow.TCGender AND
@TCIDCreator = lastRow.TCIDCreator AND
@TCIDFormCompleteDate = lastRow.TCIDFormCompleteDate AND
@TCIDPK_old = lastRow.TCIDPK_old AND
@TCLastName = lastRow.TCLastName AND
@VaricellaZoster = lastRow.VaricellaZoster AND
@NoImmunizationsReason = lastRow.NoImmunizationsReason AND
@MIECHV_Race_AmericanIndian = lastRow.MIECHV_Race_AmericanIndian AND
@MIECHV_Race_Asian = lastRow.MIECHV_Race_Asian AND
@MIECHV_Race_Black = lastRow.MIECHV_Race_Black AND
@MIECHV_Race_Hawaiian = lastRow.MIECHV_Race_Hawaiian AND
@MIECHV_Race_White = lastRow.MIECHV_Race_White AND
@MIECHV_Hispanic = lastRow.MIECHV_Hispanic
ORDER BY TCIDPK DESC) 
BEGIN
INSERT INTO TCID(
BirthTerm,
BirthWtLbs,
BirthWtOz,
DeliveryType,
Ethnicity,
FedBreastMilk,
FSWFK,
GestationalAge,
HVCaseFK,
IntensiveCare,
MultipleBirth,
NoImmunization,
NumberofChildren,
ProgramFK,
Race,
RaceSpecify,
SmokedPregnant,
TCDOB,
TCDOD,
TCFirstName,
TCGender,
TCIDCreator,
TCIDFormCompleteDate,
TCIDPK_old,
TCLastName,
VaricellaZoster,
NoImmunizationsReason,
MIECHV_Race_AmericanIndian,
MIECHV_Race_Asian,
MIECHV_Race_Black,
MIECHV_Race_Hawaiian,
MIECHV_Race_White,
MIECHV_Hispanic
)
VALUES(
@BirthTerm,
@BirthWtLbs,
@BirthWtOz,
@DeliveryType,
@Ethnicity,
@FedBreastMilk,
@FSWFK,
@GestationalAge,
@HVCaseFK,
@IntensiveCare,
@MultipleBirth,
@NoImmunization,
@NumberofChildren,
@ProgramFK,
@Race,
@RaceSpecify,
@SmokedPregnant,
@TCDOB,
@TCDOD,
@TCFirstName,
@TCGender,
@TCIDCreator,
@TCIDFormCompleteDate,
@TCIDPK_old,
@TCLastName,
@VaricellaZoster,
@NoImmunizationsReason,
@MIECHV_Race_AmericanIndian,
@MIECHV_Race_Asian,
@MIECHV_Race_Black,
@MIECHV_Race_Hawaiian,
@MIECHV_Race_White,
@MIECHV_Hispanic
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
