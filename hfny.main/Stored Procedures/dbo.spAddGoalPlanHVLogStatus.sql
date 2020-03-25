SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlanHVLogStatus](@Challenges varchar(max)=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@FollowUpAndSupport varchar(max)=NULL,
@GoalPlanHVLogStatusCreator varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
INSERT INTO GoalPlanHVLogStatus(
Challenges,
DevelopmentSinceLastVisit,
FollowUpAndSupport,
GoalPlanHVLogStatusCreator,
GoalPlanFK,
HVLogFK
)
VALUES(
@Challenges,
@DevelopmentSinceLastVisit,
@FollowUpAndSupport,
@GoalPlanHVLogStatusCreator,
@GoalPlanFK,
@HVLogFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
