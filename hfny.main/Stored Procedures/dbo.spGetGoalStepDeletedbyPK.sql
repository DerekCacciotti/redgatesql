SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetGoalStepDeletedbyPK]

(@GoalStepDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalStepDeleted
WHERE GoalStepDeletedPK = @GoalStepDeletedPK
GO
