SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlanHVLogStatus](@GoalPlanHVLogStatusPK int=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@GoalProblemSolvingAndPlanEdit varchar(max)=NULL,
@GoalPlanHVLogStatusEditor varchar(max)=NULL,
@NextStepEdit varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
UPDATE GoalPlanHVLogStatus
SET 
DevelopmentSinceLastVisit = @DevelopmentSinceLastVisit, 
GoalProblemSolvingAndPlanEdit = @GoalProblemSolvingAndPlanEdit, 
GoalPlanHVLogStatusEditor = @GoalPlanHVLogStatusEditor, 
NextStepEdit = @NextStepEdit, 
GoalPlanFK = @GoalPlanFK, 
HVLogFK = @HVLogFK
WHERE GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK
GO
