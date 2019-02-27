SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC1Medical](@HospitalNights int=NULL,
@HVCaseFK int=NULL,
@MedicalIssue varchar(500)=NULL,
@PC1ItemDate datetime=NULL,
@PC1MedicalCreator char(10)=NULL,
@PC1MedicalItem char(2)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PC1MedicalPK
FROM PC1Medical lastRow
WHERE 
@HospitalNights = lastRow.HospitalNights AND
@HVCaseFK = lastRow.HVCaseFK AND
@MedicalIssue = lastRow.MedicalIssue AND
@PC1ItemDate = lastRow.PC1ItemDate AND
@PC1MedicalCreator = lastRow.PC1MedicalCreator AND
@PC1MedicalItem = lastRow.PC1MedicalItem AND
@ProgramFK = lastRow.ProgramFK
ORDER BY PC1MedicalPK DESC) 
BEGIN
INSERT INTO PC1Medical(
HospitalNights,
HVCaseFK,
MedicalIssue,
PC1ItemDate,
PC1MedicalCreator,
PC1MedicalItem,
ProgramFK
)
VALUES(
@HospitalNights,
@HVCaseFK,
@MedicalIssue,
@PC1ItemDate,
@PC1MedicalCreator,
@PC1MedicalItem,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
