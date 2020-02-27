SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalStepDeleted](@GoalStepPK int=NULL,
@Deleted bit=NULL,
@GoalStepCreator varchar(max)=NULL,
@GoalStepDeleteDate datetime=NULL,
@GoalStepDeleter varchar(max)=NULL,
@StepAchieved bit=NULL,
@StepAnticipatedAchievementDate datetime=NULL,
@StepDescription varchar(max)=NULL,
@GoalPlanFK int=NULL,
@StepNum int=NULL)
AS
INSERT INTO GoalStepDeleted(
GoalStepPK,
Deleted,
GoalStepCreator,
GoalStepDeleteDate,
GoalStepDeleter,
StepAchieved,
StepAnticipatedAchievementDate,
StepDescription,
GoalPlanFK,
StepNum
)
VALUES(
@GoalStepPK,
@Deleted,
@GoalStepCreator,
@GoalStepDeleteDate,
@GoalStepDeleter,
@StepAchieved,
@StepAnticipatedAchievementDate,
@StepDescription,
@GoalPlanFK,
@StepNum
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
