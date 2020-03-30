SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalPlan](@GoalPlanPK int)

AS


DELETE 
FROM GoalPlan
WHERE GoalPlanPK = @GoalPlanPK
GO
