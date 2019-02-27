SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddEducation](@EducationCreator char(10)=NULL,
@EducationMonthlyHours int=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interval char(2)=NULL,
@PCType char(3)=NULL,
@ProgramFK int=NULL,
@ProgramName char(50)=NULL,
@ProgramType char(2)=NULL,
@ProgramTypeSpecify varchar(100)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) EducationPK
FROM Education lastRow
WHERE 
@EducationCreator = lastRow.EducationCreator AND
@EducationMonthlyHours = lastRow.EducationMonthlyHours AND
@FormDate = lastRow.FormDate AND
@FormFK = lastRow.FormFK AND
@FormType = lastRow.FormType AND
@HVCaseFK = lastRow.HVCaseFK AND
@Interval = lastRow.Interval AND
@PCType = lastRow.PCType AND
@ProgramFK = lastRow.ProgramFK AND
@ProgramName = lastRow.ProgramName AND
@ProgramType = lastRow.ProgramType AND
@ProgramTypeSpecify = lastRow.ProgramTypeSpecify
ORDER BY EducationPK DESC) 
BEGIN
INSERT INTO Education(
EducationCreator,
EducationMonthlyHours,
FormDate,
FormFK,
FormType,
HVCaseFK,
Interval,
PCType,
ProgramFK,
ProgramName,
ProgramType,
ProgramTypeSpecify
)
VALUES(
@EducationCreator,
@EducationMonthlyHours,
@FormDate,
@FormFK,
@FormType,
@HVCaseFK,
@Interval,
@PCType,
@ProgramFK,
@ProgramName,
@ProgramType,
@ProgramTypeSpecify
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
