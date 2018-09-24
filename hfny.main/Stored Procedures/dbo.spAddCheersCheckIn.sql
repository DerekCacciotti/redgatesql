SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCheersCheckIn](@AverageCuesScore decimal(5, 2)=NULL,
@AverageEmpathyScore decimal(5, 2)=NULL,
@AverageExpressionScore decimal(5, 2)=NULL,
@AverageHoldingScore decimal(5, 2)=NULL,
@AverageRhythmScore decimal(5, 2)=NULL,
@AverageSmilesScore decimal(5, 2)=NULL,
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
@TotalScore decimal(5, 2)=NULL)
AS
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
