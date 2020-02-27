SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddGoalPlanHVLogStatus](@DevelopmentSinceLastVisit varchar(max)=NULL,
@GoalProblemSolvingAndPlanEdit varchar(max)=NULL,
@GoalPlanHVLogStatusCreator varchar(max)=NULL,
@NextStepEdit varchar(max)=NULL,
@GoalPlanFK int=NULL,
@HVLogFK int=NULL)
AS
INSERT INTO GoalPlanHVLogStatus(
DevelopmentSinceLastVisit,
GoalProblemSolvingAndPlanEdit,
GoalPlanHVLogStatusCreator,
NextStepEdit,
GoalPlanFK,
HVLogFK
)
VALUES(
@DevelopmentSinceLastVisit,
@GoalProblemSolvingAndPlanEdit,
@GoalPlanHVLogStatusCreator,
@NextStepEdit,
@GoalPlanFK,
@HVLogFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
