SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetGoalPlanHVLogStatusDeletedbyPK]

(@GoalPlanHVLogStatusDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM GoalPlanHVLogStatusDeleted
WHERE GoalPlanHVLogStatusDeletedPK = @GoalPlanHVLogStatusDeletedPK
GO
