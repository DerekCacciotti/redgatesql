SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddEmployment](@EmploymentCreator char(10)=NULL,
@EmploymentEndDate datetime=NULL,
@EmploymentMonthlyHours int=NULL,
@EmploymentStartDate datetime=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interval char(2)=NULL,
@EmploymentMonthlyWages numeric(6, 0)=NULL,
@PCType char(3)=NULL,
@ProgramFK int=NULL,
@StillWorking char(1)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) EmploymentPK
FROM Employment lastRow
WHERE 
@EmploymentCreator = lastRow.EmploymentCreator AND
@EmploymentEndDate = lastRow.EmploymentEndDate AND
@EmploymentMonthlyHours = lastRow.EmploymentMonthlyHours AND
@EmploymentStartDate = lastRow.EmploymentStartDate AND
@FormDate = lastRow.FormDate AND
@FormFK = lastRow.FormFK AND
@FormType = lastRow.FormType AND
@HVCaseFK = lastRow.HVCaseFK AND
@Interval = lastRow.Interval AND
@EmploymentMonthlyWages = lastRow.EmploymentMonthlyWages AND
@PCType = lastRow.PCType AND
@ProgramFK = lastRow.ProgramFK AND
@StillWorking = lastRow.StillWorking
ORDER BY EmploymentPK DESC) 
BEGIN
INSERT INTO Employment(
EmploymentCreator,
EmploymentEndDate,
EmploymentMonthlyHours,
EmploymentStartDate,
FormDate,
FormFK,
FormType,
HVCaseFK,
Interval,
EmploymentMonthlyWages,
PCType,
ProgramFK,
StillWorking
)
VALUES(
@EmploymentCreator,
@EmploymentEndDate,
@EmploymentMonthlyHours,
@EmploymentStartDate,
@FormDate,
@FormFK,
@FormType,
@HVCaseFK,
@Interval,
@EmploymentMonthlyWages,
@PCType,
@ProgramFK,
@StillWorking
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
