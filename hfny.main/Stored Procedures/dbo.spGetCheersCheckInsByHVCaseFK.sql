SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/09/18
-- Description:	Get all CheersCheckIn rows for a specific case
-- =============================================
CREATE PROCEDURE [dbo].[spGetCheersCheckInsByHVCaseFK]
	-- Add the parameters for the stored procedure here
	@HVCaseFK INT,
	@ProgramFK INT
AS
BEGIN
	SELECT	CheersCheckInPK,
			AverageCuesScore,
			AverageEmpathyScore,
			AverageExpressionScore,
			AverageHoldingScore,
			AverageRhythmScore,
			AverageSmilesScore,
			CheersCheckInCreateDate,
			CheersCheckInCreator,
			CheersCheckInEditDate,
			CheersCheckInEditor,
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
	FROM	dbo.CheersCheckIn cci
	WHERE cci.HVCaseFK = @HVCaseFK
		AND cci.ProgramFK = @ProgramFK;
END;
GO
