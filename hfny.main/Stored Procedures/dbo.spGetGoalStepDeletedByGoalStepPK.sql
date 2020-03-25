SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetGoalStepDeletedByGoalStepPK]

	@GoalStepPK INT
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalStepDeleted
WHERE GoalStepPK = @GoalStepPK
GO
