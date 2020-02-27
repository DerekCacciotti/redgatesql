SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalStep](@GoalStepPK int)

AS


DELETE 
FROM GoalStep
WHERE GoalStepPK = @GoalStepPK
GO
