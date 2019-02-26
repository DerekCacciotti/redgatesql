SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCheersCheckIn](@AverageCuesScore numeric(5, 2)=NULL,
@AverageEmpathyScore numeric(5, 2)=NULL,
@AverageExpressionScore numeric(5, 2)=NULL,
@AverageHoldingScore numeric(5, 2)=NULL,
@AverageRhythmScore numeric(5, 2)=NULL,
@AverageSmilesScore numeric(5, 2)=NULL,
@CheersCheckInCreator varchar(10)=NULL,
@Cues1Score int=NULL,
@Cues2Score int=NULL,
@Empathy1Score int=NULL,
@Empathy2Score int=NULL,
@Empathy3Score int=NULL,
@Expression1Score int=NULL,
@Expression2Score int=NULL,
@Expression3Score int=NULL,
@FSWFK int=NULL,
@Holding1Score int=NULL,
@Holding2Score int=NULL,
@Holding3Score int=NULL,
@HVCaseFK int=NULL,
@ObservationDate datetime=NULL,
@ProgramFK int=NULL,
@Rhythm1Score int=NULL,
@Rhythm2Score int=NULL,
@Smiles1Score int=NULL,
@Smiles2Score int=NULL,
@Smiles3Score int=NULL,
@TotalScore numeric(5, 2)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CheersCheckInPK
FROM CheersCheckIn lastRow
WHERE 
@AverageCuesScore = lastRow.AverageCuesScore AND
@AverageEmpathyScore = lastRow.AverageEmpathyScore AND
@AverageExpressionScore = lastRow.AverageExpressionScore AND
@AverageHoldingScore = lastRow.AverageHoldingScore AND
@AverageRhythmScore = lastRow.AverageRhythmScore AND
@AverageSmilesScore = lastRow.AverageSmilesScore AND
@CheersCheckInCreator = lastRow.CheersCheckInCreator AND
@Cues1Score = lastRow.Cues1Score AND
@Cues2Score = lastRow.Cues2Score AND
@Empathy1Score = lastRow.Empathy1Score AND
@Empathy2Score = lastRow.Empathy2Score AND
@Empathy3Score = lastRow.Empathy3Score AND
@Expression1Score = lastRow.Expression1Score AND
@Expression2Score = lastRow.Expression2Score AND
@Expression3Score = lastRow.Expression3Score AND
@FSWFK = lastRow.FSWFK AND
@Holding1Score = lastRow.Holding1Score AND
@Holding2Score = lastRow.Holding2Score AND
@Holding3Score = lastRow.Holding3Score AND
@HVCaseFK = lastRow.HVCaseFK AND
@ObservationDate = lastRow.ObservationDate AND
@ProgramFK = lastRow.ProgramFK AND
@Rhythm1Score = lastRow.Rhythm1Score AND
@Rhythm2Score = lastRow.Rhythm2Score AND
@Smiles1Score = lastRow.Smiles1Score AND
@Smiles2Score = lastRow.Smiles2Score AND
@Smiles3Score = lastRow.Smiles3Score AND
@TotalScore = lastRow.TotalScore
ORDER BY CheersCheckInPK DESC) 
BEGIN
INSERT INTO CheersCheckIn(
AverageCuesScore,
AverageEmpathyScore,
AverageExpressionScore,
AverageHoldingScore,
AverageRhythmScore,
AverageSmilesScore,
CheersCheckInCreator,
Cues1Score,
Cues2Score,
Empathy1Score,
Empathy2Score,
Empathy3Score,
Expression1Score,
Expression2Score,
Expression3Score,
FSWFK,
Holding1Score,
Holding2Score,
Holding3Score,
HVCaseFK,
ObservationDate,
ProgramFK,
Rhythm1Score,
Rhythm2Score,
Smiles1Score,
Smiles2Score,
Smiles3Score,
TotalScore
)
VALUES(
@AverageCuesScore,
@AverageEmpathyScore,
@AverageExpressionScore,
@AverageHoldingScore,
@AverageRhythmScore,
@AverageSmilesScore,
@CheersCheckInCreator,
@Cues1Score,
@Cues2Score,
@Empathy1Score,
@Empathy2Score,
@Empathy3Score,
@Expression1Score,
@Expression2Score,
@Expression3Score,
@FSWFK,
@Holding1Score,
@Holding2Score,
@Holding3Score,
@HVCaseFK,
@ObservationDate,
@ProgramFK,
@Rhythm1Score,
@Rhythm2Score,
@Smiles1Score,
@Smiles2Score,
@Smiles3Score,
@TotalScore
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
