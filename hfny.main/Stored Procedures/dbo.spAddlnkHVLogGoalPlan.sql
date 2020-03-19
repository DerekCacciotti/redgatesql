SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlnkHVLogGoalPlan](@HVLogFK int=NULL,
@GoalPlanFK int=NULL,
@NotDiscussed int=NULL)
AS
INSERT INTO lnkHVLogGoalPlan(
HVLogFK,
GoalPlanFK,
NotDiscussed
)
VALUES(
@HVLogFK,
@GoalPlanFK,
@NotDiscussed
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
