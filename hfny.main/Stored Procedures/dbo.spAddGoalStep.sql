SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalStep](@GoalStepCreator varchar(max)=NULL,
@StepAchieved bit=NULL,
@StepAnticipatedAchievementDate datetime=NULL,
@StepDescription varchar(max)=NULL,
@StepNum int=NULL,
@GoalPlanFK int=NULL)
AS
INSERT INTO GoalStep(
GoalStepCreator,
StepAchieved,
StepAnticipatedAchievementDate,
StepDescription,
StepNum,
GoalPlanFK
)
VALUES(
@GoalStepCreator,
@StepAchieved,
@StepAnticipatedAchievementDate,
@StepDescription,
@StepNum,
@GoalPlanFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
