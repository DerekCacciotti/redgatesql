SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetGoalPlanDeletedbyPK]

(@GoalPlanDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalPlanDeleted
WHERE GoalPlanDeletedPK = @GoalPlanDeletedPK
GO
