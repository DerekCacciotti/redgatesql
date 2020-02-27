SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetGoalPlanHVLogStatusbyPK]

(@GoalPlanHVLogStatusPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalPlanHVLogStatus
WHERE GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK
GO
