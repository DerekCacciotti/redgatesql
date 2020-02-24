SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalStepDeleted](@GoalStepDeletedPK int=NULL,
@GoalStepPK int=NULL,
@Deleted bit=NULL,
@GoalStepDeleteDate datetime=NULL,
@GoalStepDeleter varchar(max)=NULL,
@GoalStepEditor varchar(max)=NULL,
@StepAchieved bit=NULL,
@StepAnticipatedAchievementDate datetime=NULL,
@StepDescription varchar(max)=NULL,
@GoalPlanFK int=NULL,
@StepNum int=NULL)
AS
UPDATE GoalStepDeleted
SET 
GoalStepPK = @GoalStepPK, 
Deleted = @Deleted, 
GoalStepDeleteDate = @GoalStepDeleteDate, 
GoalStepDeleter = @GoalStepDeleter, 
GoalStepEditor = @GoalStepEditor, 
StepAchieved = @StepAchieved, 
StepAnticipatedAchievementDate = @StepAnticipatedAchievementDate, 
StepDescription = @StepDescription, 
GoalPlanFK = @GoalPlanFK, 
StepNum = @StepNum
WHERE GoalStepDeletedPK = @GoalStepDeletedPK
GO
