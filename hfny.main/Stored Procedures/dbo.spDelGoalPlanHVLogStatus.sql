SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalPlanHVLogStatus](@GoalPlanHVLogStatusPK int)

AS


DELETE 
FROM GoalPlanHVLogStatus
WHERE GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK
GO
