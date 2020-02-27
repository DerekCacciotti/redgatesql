SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelGoalPlanDeleted](@GoalPlanDeletedPK int)

AS


DELETE 
FROM GoalPlanDeleted
WHERE GoalPlanDeletedPK = @GoalPlanDeletedPK
GO
