SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlnkHVLogGoalPlan](@lnkHVLogGoalPlanPK int=NULL,
@HVLogFK int=NULL,
@GoalPlanFK int=NULL,
@NotDiscussed int=NULL)
AS
UPDATE lnkHVLogGoalPlan
SET 
HVLogFK = @HVLogFK, 
GoalPlanFK = @GoalPlanFK, 
NotDiscussed = @NotDiscussed
WHERE lnkHVLogGoalPlanPK = @lnkHVLogGoalPlanPK
GO
