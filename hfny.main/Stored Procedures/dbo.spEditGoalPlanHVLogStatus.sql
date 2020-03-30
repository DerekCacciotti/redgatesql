SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditGoalPlanHVLogStatus](@GoalPlanHVLogStatusPK int=NULL,
@Challenges varchar(max)=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@FollowUpAndSupport varchar(max)=NULL,
@GoalPlanHVLogStatusEditor varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
UPDATE GoalPlanHVLogStatus
SET 
Challenges = @Challenges, 
DevelopmentSinceLastVisit = @DevelopmentSinceLastVisit, 
FollowUpAndSupport = @FollowUpAndSupport, 
GoalPlanHVLogStatusEditor = @GoalPlanHVLogStatusEditor, 
GoalPlanFK = @GoalPlanFK, 
HVLogFK = @HVLogFK
WHERE GoalPlanHVLogStatusPK = @GoalPlanHVLogStatusPK
GO
