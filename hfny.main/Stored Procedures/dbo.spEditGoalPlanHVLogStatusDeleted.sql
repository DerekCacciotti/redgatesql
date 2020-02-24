SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlanHVLogStatusDeleted](@GoalPlanHVLogStatusDeletedPK int=NULL,
@GoalPlanHVLogStatusPK int=NULL,
@Deleted bit=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@GoalPlanHVLogStatusDeleteDate datetime=NULL,
@GoalPlanHVLogStatusDeleter varchar(max)=NULL,
@GoalPlanHVLogStatusEditor varchar(max)=NULL,
@GoalProblemSolvingAndPlanEdit varchar(max)=NULL,
@NextStepEdit varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
UPDATE GoalPlanHVLogStatusDeleted
SET 
GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK, 
Deleted = @Deleted, 
DevelopmentSinceLastVisit = @DevelopmentSinceLastVisit, 
GoalPlanHVLogStatusDeleteDate = @GoalPlanHVLogStatusDeleteDate, 
GoalPlanHVLogStatusDeleter = @GoalPlanHVLogStatusDeleter, 
GoalPlanHVLogStatusEditor = @GoalPlanHVLogStatusEditor, 
GoalProblemSolvingAndPlanEdit = @GoalProblemSolvingAndPlanEdit, 
NextStepEdit = @NextStepEdit, 
GoalPlanFK = @GoalPlanFK, 
HVLogFK = @HVLogFK
WHERE GoalPlanHVLogStatusDeletedPK = @GoalPlanHVLogStatusDeletedPK
GO
