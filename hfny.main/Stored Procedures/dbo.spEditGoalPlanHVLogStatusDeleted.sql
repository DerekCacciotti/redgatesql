SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlanHVLogStatusDeleted](@GoalPlanHVLogStatusDeletedPK int=NULL,
@GoalPlanHVLogStatusPK int=NULL,
@Challenges varchar(max)=NULL,
@Deleted bit=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@FollowUpAndSupport varchar(max)=NULL,
@GoalPlanHVLogStatusDeleteDate datetime=NULL,
@GoalPlanHVLogStatusDeleter varchar(max)=NULL,
@GoalPlanHVLogStatusEditor varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
UPDATE GoalPlanHVLogStatusDeleted
SET 
GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK, 
Challenges = @Challenges, 
Deleted = @Deleted, 
DevelopmentSinceLastVisit = @DevelopmentSinceLastVisit, 
FollowUpAndSupport = @FollowUpAndSupport, 
GoalPlanHVLogStatusDeleteDate = @GoalPlanHVLogStatusDeleteDate, 
GoalPlanHVLogStatusDeleter = @GoalPlanHVLogStatusDeleter, 
GoalPlanHVLogStatusEditor = @GoalPlanHVLogStatusEditor, 
GoalPlanFK = @GoalPlanFK, 
HVLogFK = @HVLogFK
WHERE GoalPlanHVLogStatusDeletedPK = @GoalPlanHVLogStatusDeletedPK
GO
