SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetGoalPlanDeletedByGoalPlanPK]

	@GoalPlanPK INT
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalPlanDeleted
WHERE GoalPlanPK = @GoalPlanPK
GO
