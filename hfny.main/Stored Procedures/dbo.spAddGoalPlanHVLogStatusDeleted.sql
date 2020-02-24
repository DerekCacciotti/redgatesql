SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlanHVLogStatusDeleted](@GoalPlanHVLogStatusPK int=NULL,
@Deleted bit=NULL,
@DevelopmentSinceLastVisit varchar(max)=NULL,
@GoalPlanHVLogStatusCreator varchar(max)=NULL,
@GoalPlanHVLogStatusDeleteDate datetime=NULL,
@GoalPlanHVLogStatusDeleter varchar(max)=NULL,
@GoalProblemSolvingAndPlanEdit varchar(max)=NULL,
@NextStepEdit varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
INSERT INTO GoalPlanHVLogStatusDeleted(
GoalPlanHVLogStatusPK,
Deleted,
DevelopmentSinceLastVisit,
GoalPlanHVLogStatusCreator,
GoalPlanHVLogStatusDeleteDate,
GoalPlanHVLogStatusDeleter,
GoalProblemSolvingAndPlanEdit,
NextStepEdit,
GoalPlanFK,
HVLogFK
)
VALUES(
@GoalPlanHVLogStatusPK,
@Deleted,
@DevelopmentSinceLastVisit,
@GoalPlanHVLogStatusCreator,
@GoalPlanHVLogStatusDeleteDate,
@GoalPlanHVLogStatusDeleter,
@GoalProblemSolvingAndPlanEdit,
@NextStepEdit,
@GoalPlanFK,
@HVLogFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
