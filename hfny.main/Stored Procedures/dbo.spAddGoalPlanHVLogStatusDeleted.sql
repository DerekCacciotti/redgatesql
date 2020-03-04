SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlanHVLogStatusDeleted](@GoalPlanHVLogStatusPK int=NULL,
@Challenges varchar(max)=NULL,
@Deleted bit=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@FollowUpAndSupport varchar(max)=NULL,
@GoalPlanHVLogStatusCreator varchar(max)=NULL,
@GoalPlanHVLogStatusDeleteDate datetime=NULL,
@GoalPlanHVLogStatusDeleter varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
INSERT INTO GoalPlanHVLogStatusDeleted(
GoalPlanHVLogStatusPK,
Challenges,
Deleted,
DevelopmentSinceLastVisit,
FollowUpAndSupport,
GoalPlanHVLogStatusCreator,
GoalPlanHVLogStatusDeleteDate,
GoalPlanHVLogStatusDeleter,
GoalPlanFK,
HVLogFK
)
VALUES(
@GoalPlanHVLogStatusPK,
@Challenges,
@Deleted,
@DevelopmentSinceLastVisit,
@FollowUpAndSupport,
@GoalPlanHVLogStatusCreator,
@GoalPlanHVLogStatusDeleteDate,
@GoalPlanHVLogStatusDeleter,
@GoalPlanFK,
@HVLogFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
