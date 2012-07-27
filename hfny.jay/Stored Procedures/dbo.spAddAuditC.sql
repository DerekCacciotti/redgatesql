SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAuditC](@AuditCCreator char(10)=NULL,
@DailyDrinks char(2)=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@HowOften char(2)=NULL,
@HVCaseFK int=NULL,
@Invalid bit=NULL,
@MoreThanSix char(2)=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@TotalScore int=NULL)
AS
INSERT INTO AuditC(
AuditCCreator,
DailyDrinks,
FormFK,
FormInterval,
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
@HowOften,
@HVCaseFK,
@Invalid,
@MoreThanSix,
@Positive,
@ProgramFK,
@TotalScore
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
