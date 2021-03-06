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
GoalPotentialBarriers = @GoalPotentialBarriers, 
GoalStatement = @GoalStatement, 
GoalStatus = @GoalStatus, 
GoalStatusDate = @GoalStatusDate, 
IsConsentSigned = @IsConsentSigned, 
IsTransitionPlan = @IsTransitionPlan, 
ProtectiveFactors = @ProtectiveFactors, 
ServicePartners = @ServicePartners, 
StartDate = @StartDate, 
Strengths = @Strengths, 
HVCaseFK = @HVCaseFK
WHERE GoalPlanPK = @GoalPlanPK
GO
