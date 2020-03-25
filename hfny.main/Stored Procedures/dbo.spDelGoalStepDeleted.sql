SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalStepDeleted](@GoalStepDeletedPK int)

AS


DELETE 
FROM GoalStepDeleted
WHERE GoalStepDeletedPK = @GoalStepDeletedPK
GO
