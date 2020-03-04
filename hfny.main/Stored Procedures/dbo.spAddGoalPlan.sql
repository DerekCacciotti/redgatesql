SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlan](@AnticipatedAchievementDate datetime=NULL,
@GoalArea char(2)=NULL,
@GoalCreationDiscussion varchar(max)=NULL,
@GoalName varchar(100)=NULL,
@GoalPertainsTo char(2)=NULL,
@GoalPertainsToSpecify varchar(100)=NULL,
@GoalPlanActive bit=NULL,
@GoalPlanCreator varchar(max)=NULL,
@GoalPotentialBarriers varchar(max)=NULL,
@GoalStatement varchar(500)=NULL,
@GoalStatus char(2)=NULL,
@GoalStatusDate datetime=NULL,
@IsConsentSigned bit=NULL,
@IsTransitionPlan bit=NULL,
@ProtectiveFactors char(5)=NULL,
@ServicePartners varchar(max)=NULL,
@StartDate datetime=NULL,
@Strengths varchar(max)=NULL,
@HVCaseFK int=NULL)
AS
INSERT INTO GoalPlan(
AnticipatedAchievementDate,
GoalArea,
GoalCreationDiscussion,
GoalName,
GoalPertainsTo,
GoalPertainsToSpecify,
GoalPlanActive,
GoalPlanCreator,
GoalPotentialBarriers,
GoalStatement,
GoalStatus,
GoalStatusDate,
IsConsentSigned,
IsTransitionPlan,
ProtectiveFactors,
ServicePartners,
StartDate,
Strengths,
HVCaseFK
)
VALUES(
@AnticipatedAchievementDate,
@GoalArea,
@GoalCreationDiscussion,
@GoalName,
@GoalPertainsTo,
@GoalPertainsToSpecify,
@GoalPlanActive,
@GoalPlanCreator,
@GoalPotentialBarriers,
@GoalStatement,
@GoalStatus,
@GoalStatusDate,
@IsConsentSigned,
@IsTransitionPlan,
@ProtectiveFactors,
@ServicePartners,
@StartDate,
@Strengths,
@HVCaseFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
