SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlanDeleted](@GoalPlanDeletedPK int=NULL,
@GoalPlanPK int=NULL,
@AnticipatedAchievementDate datetime=NULL,
@Deleted bit=NULL,
@GoalArea char(2)=NULL,
@GoalCreationDiscussion varchar(max)=NULL,
@GoalName varchar(100)=NULL,
@GoalPlanActive bit=NULL,
@GoalPlanDeleteDate datetime=NULL,
@GoalPlanDeleter varchar(max)=NULL,
@GoalPlanEditor varchar(max)=NULL,
@GoalPertainsTo char(2)=NULL,
@GoalPertainsToSpecify varchar(100)=NULL,
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
UPDATE GoalPlanDeleted
SET 
GoalPlanPK = @GoalPlanPK, 
AnticipatedAchievementDate = @AnticipatedAchievementDate, 
Deleted = @Deleted, 
GoalArea = @GoalArea, 
GoalCreationDiscussion = @GoalCreationDiscussion, 
GoalName = @GoalName, 
GoalPlanActive = @GoalPlanActive, 
GoalPlanDeleteDate = @GoalPlanDeleteDate, 
GoalPlanDeleter = @GoalPlanDeleter, 
GoalPlanEditor = @GoalPlanEditor, 
GoalPertainsTo = @GoalPertainsTo, 
GoalPertainsToSpecify = @GoalPertainsToSpecify, 
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
WHERE GoalPlanDeletedPK = @GoalPlanDeletedPK
GO
