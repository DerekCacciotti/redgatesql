SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTCMedical](@ChildType char(2)=NULL,
@HospitalNights int=NULL,
@HVCaseFK int=NULL,
@IsDelayed bit=NULL,
@LeadLevelCode char(2)=NULL,
@MedicalReason1 char(2)=NULL,
@MedicalReason2 char(2)=NULL,
@MedicalReason3 char(2)=NULL,
@MedicalReason4 char(2)=NULL,
@MedicalReason5 char(2)=NULL,
@ProgramFK int=NULL,
@TCIDFK int=NULL,
@TCItemDate datetime=NULL,
@TCMedicalCreator char(10)=NULL,
@TCMedicalItem char(2)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TCMedicalPK
FROM TCMedical lastRow
WHERE 
@ChildType = lastRow.ChildType AND
@HospitalNights = lastRow.HospitalNights AND
@HVCaseFK = lastRow.HVCaseFK AND
@IsDelayed = lastRow.IsDelayed AND
@LeadLevelCode = lastRow.LeadLevelCode AND
@MedicalReason1 = lastRow.MedicalReason1 AND
@MedicalReason2 = lastRow.MedicalReason2 AND
@MedicalReason3 = lastRow.MedicalReason3 AND
@MedicalReason4 = lastRow.MedicalReason4 AND
@MedicalReason5 = lastRow.MedicalReason5 AND
@ProgramFK = lastRow.ProgramFK AND
@TCIDFK = lastRow.TCIDFK AND
@TCItemDate = lastRow.TCItemDate AND
@TCMedicalCreator = lastRow.TCMedicalCreator AND
@TCMedicalItem = lastRow.TCMedicalItem
ORDER BY TCMedicalPK DESC) 
BEGIN
INSERT INTO TCMedical(
ChildType,
HospitalNights,
HVCaseFK,
IsDelayed,
LeadLevelCode,
MedicalReason1,
MedicalReason2,
MedicalReason3,
MedicalReason4,
MedicalReason5,
ProgramFK,
TCIDFK,
TCItemDate,
TCMedicalCreator,
TCMedicalItem
)
VALUES(
@ChildType,
@HospitalNights,
@HVCaseFK,
@IsDelayed,
@LeadLevelCode,
@MedicalReason1,
@MedicalReason2,
@MedicalReason3,
@MedicalReason4,
@MedicalReason5,
@ProgramFK,
@TCIDFK,
@TCItemDate,
@TCMedicalCreator,
@TCMedicalItem
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
