SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddOtherChild](@BirthTerm char(2)=NULL,
@BirthWtLbs int=NULL,
@BirthWtOz int=NULL,
@DOB datetime=NULL,
@FirstName varchar(200)=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@GestationalWeeks int=NULL,
@HVCaseFK int=NULL,
@LastName varchar(200)=NULL,
@LivingArrangement char(2)=NULL,
@LivingArrangementSpecify char(100)=NULL,
@MultiBirth int=NULL,
@OtherChildCreator varchar(max)=NULL,
@PregnancyOutcome char(2)=NULL,
@PrenatalCare char(1)=NULL,
@ProgramFK int=NULL,
@Relation2PC1 char(2)=NULL,
@Relation2PC1Specify varchar(500)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) OtherChildPK
FROM OtherChild lastRow
WHERE 
@BirthTerm = lastRow.BirthTerm AND
@BirthWtLbs = lastRow.BirthWtLbs AND
@BirthWtOz = lastRow.BirthWtOz AND
@DOB = lastRow.DOB AND
@FirstName = lastRow.FirstName AND
@FormFK = lastRow.FormFK AND
@FormType = lastRow.FormType AND
@GestationalWeeks = lastRow.GestationalWeeks AND
@HVCaseFK = lastRow.HVCaseFK AND
@LastName = lastRow.LastName AND
@LivingArrangement = lastRow.LivingArrangement AND
@LivingArrangementSpecify = lastRow.LivingArrangementSpecify AND
@MultiBirth = lastRow.MultiBirth AND
@OtherChildCreator = lastRow.OtherChildCreator AND
@PregnancyOutcome = lastRow.PregnancyOutcome AND
@PrenatalCare = lastRow.PrenatalCare AND
@ProgramFK = lastRow.ProgramFK AND
@Relation2PC1 = lastRow.Relation2PC1 AND
@Relation2PC1Specify = lastRow.Relation2PC1Specify
ORDER BY OtherChildPK DESC) 
BEGIN
INSERT INTO OtherChild(
BirthTerm,
BirthWtLbs,
BirthWtOz,
DOB,
FirstName,
FormFK,
FormType,
GestationalWeeks,
HVCaseFK,
LastName,
LivingArrangement,
LivingArrangementSpecify,
MultiBirth,
OtherChildCreator,
PregnancyOutcome,
PrenatalCare,
ProgramFK,
Relation2PC1,
Relation2PC1Specify
)
VALUES(
@BirthTerm,
@BirthWtLbs,
@BirthWtOz,
@DOB,
@FirstName,
@FormFK,
@FormType,
@GestationalWeeks,
@HVCaseFK,
@LastName,
@LivingArrangement,
@LivingArrangementSpecify,
@MultiBirth,
@OtherChildCreator,
@PregnancyOutcome,
@PrenatalCare,
@ProgramFK,
@Relation2PC1,
@Relation2PC1Specify
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
