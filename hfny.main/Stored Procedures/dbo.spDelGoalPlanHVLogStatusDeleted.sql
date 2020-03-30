SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalPlanHVLogStatusDeleted](@GoalPlanHVLogStatusDeletedPK int)

AS


DELETE 
FROM GoalPlanHVLogStatusDeleted
WHERE GoalPlanHVLogStatusDeletedPK = @GoalPlanHVLogStatusDeletedPK
GO
