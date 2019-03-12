SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPHQ9](@Appetite char(2)=NULL,
@BadSelf char(2)=NULL,
@BetterOffDead char(2)=NULL,
@Concentration char(2)=NULL,
@DateAdministered datetime=NULL,
@DepressionReferralMade bit=NULL,
@Difficulty char(2)=NULL,
@Down char(2)=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interest char(2)=NULL,
@Invalid bit=NULL,
@ParticipantRefused bit=NULL,
@PHQ9Creator varchar(max)=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@Sleep char(2)=NULL,
@SlowOrFast char(2)=NULL,
@Tired char(2)=NULL,
@TotalScore int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PHQ9PK
FROM PHQ9 lastRow
WHERE 
@Appetite = lastRow.Appetite AND
@BadSelf = lastRow.BadSelf AND
@BetterOffDead = lastRow.BetterOffDead AND
@Concentration = lastRow.Concentration AND
@DateAdministered = lastRow.DateAdministered AND
@DepressionReferralMade = lastRow.DepressionReferralMade AND
@Difficulty = lastRow.Difficulty AND
@Down = lastRow.Down AND
@FormFK = lastRow.FormFK AND
@FormInterval = lastRow.FormInterval AND
@FormType = lastRow.FormType AND
@HVCaseFK = lastRow.HVCaseFK AND
@Interest = lastRow.Interest AND
@Invalid = lastRow.Invalid AND
@ParticipantRefused = lastRow.ParticipantRefused AND
@PHQ9Creator = lastRow.PHQ9Creator AND
@Positive = lastRow.Positive AND
@ProgramFK = lastRow.ProgramFK AND
@Sleep = lastRow.Sleep AND
@SlowOrFast = lastRow.SlowOrFast AND
@Tired = lastRow.Tired AND
@TotalScore = lastRow.TotalScore
ORDER BY PHQ9PK DESC) 
BEGIN
INSERT INTO PHQ9(
Appetite,
BadSelf,
BetterOffDead,
Concentration,
DateAdministered,
DepressionReferralMade,
Difficulty,
Down,
FormFK,
FormInterval,
FormType,
HVCaseFK,
Interest,
Invalid,
ParticipantRefused,
PHQ9Creator,
Positive,
ProgramFK,
Sleep,
SlowOrFast,
Tired,
TotalScore
)
VALUES(
@Appetite,
@BadSelf,
@BetterOffDead,
@Concentration,
@DateAdministered,
@DepressionReferralMade,
@Difficulty,
@Down,
@FormFK,
@FormInterval,
@FormType,
@HVCaseFK,
@Interest,
@Invalid,
@ParticipantRefused,
@PHQ9Creator,
@Positive,
@ProgramFK,
@Sleep,
@SlowOrFast,
@Tired,
@TotalScore
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
