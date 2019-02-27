SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAuditC](@AuditCCreator char(10)=NULL,
@DailyDrinks int=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HowOften int=NULL,
@HVCaseFK int=NULL,
@Invalid bit=NULL,
@MoreThanSix int=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@TotalScore int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) AuditCPK
FROM AuditC lastRow
WHERE 
@AuditCCreator = lastRow.AuditCCreator AND
@DailyDrinks = lastRow.DailyDrinks AND
@FormFK = lastRow.FormFK AND
@FormInterval = lastRow.FormInterval AND
@FormType = lastRow.FormType AND
@HowOften = lastRow.HowOften AND
@HVCaseFK = lastRow.HVCaseFK AND
@Invalid = lastRow.Invalid AND
@MoreThanSix = lastRow.MoreThanSix AND
@Positive = lastRow.Positive AND
@ProgramFK = lastRow.ProgramFK AND
@TotalScore = lastRow.TotalScore
ORDER BY AuditCPK DESC) 
BEGIN
INSERT INTO AuditC(
AuditCCreator,
DailyDrinks,
FormFK,
FormInterval,
FormType,
HowOften,
HVCaseFK,
Invalid,
MoreThanSix,
Positive,
ProgramFK,
TotalScore
)
VALUES(
@AuditCCreator,
@DailyDrinks,
@FormFK,
@FormInterval,
@FormType,
@HowOften,
@HVCaseFK,
@Invalid,
@MoreThanSix,
@Positive,
@ProgramFK,
@TotalScore
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
