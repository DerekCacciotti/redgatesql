SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalStep](@GoalStepPK int=NULL,
@GoalStepEditor varchar(max)=NULL,
@StepAchieved bit=NULL,
@StepAnticipatedAchievementDate datetime=NULL,
@StepDescription varchar(max)=NULL,
@StepNum int=NULL,
@GoalPlanFK int=NULL)
AS
UPDATE GoalStep
SET 
GoalStepEditor = @GoalStepEditor, 
StepAchieved = @StepAchieved, 
StepAnticipatedAchievementDate = @StepAnticipatedAchievementDate, 
StepDescription = @StepDescription, 
StepNum = @StepNum, 
GoalPlanFK = @GoalPlanFK
WHERE GoalStepPK = @GoalStepPK
GO
