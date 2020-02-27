SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlan](@GoalPlanPK int=NULL,
@AnticipatedAchievementDate datetime=NULL,
@GoalArea char(2)=NULL,
@GoalCreationDiscussion varchar(max)=NULL,
@GoalName varchar(100)=NULL,
@GoalPertainsTo char(2)=NULL,
@GoalPertainsToSpecify varchar(100)=NULL,
@GoalPlanActive bit=NULL,
@GoalPlanEditor varchar(max)=NULL,
@GoalProblemSolvingAndPlan varchar(max)=NULL,
@GoalStatement varchar(500)=NULL,
@GoalStatus char(2)=NULL,
@GoalStatusDate datetime=NULL,
@NextStep varchar(max)=NULL,
@ProtectiveFactors char(5)=NULL,
@StartDate datetime=NULL,
@HVCaseFK int=NULL)
AS
UPDATE GoalPlan
SET 
AnticipatedAchievementDate = @AnticipatedAchievementDate, 
GoalArea = @GoalArea, 
GoalCreationDiscussion = @GoalCreationDiscussion, 
GoalName = @GoalName, 
GoalPertainsTo = @GoalPertainsTo, 
GoalPertainsToSpecify = @GoalPertainsToSpecify, 
GoalPlanActive = @GoalPlanActive, 
GoalPlanEditor = @GoalPlanEditor, 
GoalProblemSolvingAndPlan = @GoalProblemSolvingAndPlan, 
GoalStatement = @GoalStatement, 
GoalStatus = @GoalStatus, 
GoalStatusDate = @GoalStatusDate, 
NextStep = @NextStep, 
ProtectiveFactors = @ProtectiveFactors, 
StartDate = @StartDate, 
HVCaseFK = @HVCaseFK
WHERE GoalPlanPK = @GoalPlanPK
GO
