SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAuditC](@AuditCPK int=NULL,
@AuditCEditor char(10)=NULL,
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
UPDATE AuditC
SET 
AuditCEditor = @AuditCEditor, 
DailyDrinks = @DailyDrinks, 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
HowOften = @HowOften, 
HVCaseFK = @HVCaseFK, 
Invalid = @Invalid, 
MoreThanSix = @MoreThanSix, 
Positive = @Positive, 
ProgramFK = @ProgramFK, 
TotalScore = @TotalScore
WHERE AuditCPK = @AuditCPK
GO
