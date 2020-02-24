SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlanDeleted](@GoalPlanPK int=NULL,
@AnticipatedAchievementDate datetime=NULL,
@Deleted bit=NULL,
@GoalArea char(2)=NULL,
@GoalCreationDiscussion varchar(max)=NULL,
@GoalName varchar(100)=NULL,
@GoalPlanActive bit=NULL,
@GoalPlanCreator varchar(max)=NULL,
@GoalPlanDeleteDate datetime=NULL,
@GoalPlanDeleter varchar(max)=NULL,
@GoalPertainsTo char(2)=NULL,
@GoalPertainsToSpecify varchar(100)=NULL,
@GoalProblemSolvingAndPlan varchar(max)=NULL,
@GoalStatement varchar(500)=NULL,
@GoalStatus char(2)=NULL,
@GoalStatusDate datetime=NULL,
@NextStep varchar(max)=NULL,
@ProtectiveFactors char(5)=NULL,
@StartDate datetime=NULL,
@HVCaseFK int=NULL)
AS
INSERT INTO GoalPlanDeleted(
GoalPlanPK,
AnticipatedAchievementDate,
Deleted,
GoalArea,
GoalCreationDiscussion,
GoalName,
GoalPlanActive,
GoalPlanCreator,
GoalPlanDeleteDate,
GoalPlanDeleter,
GoalPertainsTo,
GoalPertainsToSpecify,
GoalProblemSolvingAndPlan,
GoalStatement,
GoalStatus,
GoalStatusDate,
NextStep,
ProtectiveFactors,
StartDate,
HVCaseFK
)
VALUES(
@GoalPlanPK,
@AnticipatedAchievementDate,
@Deleted,
@GoalArea,
@GoalCreationDiscussion,
@GoalName,
@GoalPlanActive,
@GoalPlanCreator,
@GoalPlanDeleteDate,
@GoalPlanDeleter,
@GoalPertainsTo,
@GoalPertainsToSpecify,
@GoalProblemSolvingAndPlan,
@GoalStatement,
@GoalStatus,
@GoalStatusDate,
@NextStep,
@ProtectiveFactors,
@StartDate,
@HVCaseFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
