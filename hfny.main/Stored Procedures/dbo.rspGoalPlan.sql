SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 01/29/18
-- Description:	This stored procedure returns all the details about a goal plan and its steps
-- =============================================
CREATE PROC [dbo].[rspGoalPlan]
    @GoalPlanPK INT = NULL
AS
BEGIN

    SELECT DISTINCT
           cp.PC1ID,
           gp.GoalPlanPK,
		   gp.IsTransitionPlan,
		   gp.IsConsentSigned,
		   gp.ServicePartners,
           gp.GoalName,
           gp.StartDate,
           gp.AnticipatedAchievementDate,
           stat.AppCodeText AS GoalStatus,
           gp.GoalStatusDate,
           area.AppCodeText AS GoalArea,
           pertains.AppCodeText AS GoalPertainsTo,
           gp.GoalPertainsToSpecify,
           gp.ProtectiveFactors,
           gp.GoalStatement,
           gp.GoalCreationDiscussion,
           gp.GoalPotentialBarriers,
           gp.Strengths,
           gs.StepNum,
           gs.StepDescription,
           gs.StepAnticipatedAchievementDate,
           gs.StepAchieved
    FROM dbo.GoalPlan gp
        LEFT JOIN dbo.GoalStep gs
            ON gs.GoalPlanFK = gp.GoalPlanPK
        LEFT JOIN dbo.GoalPlanHVLogStatus gphls
            ON gphls.GoalPlanFK = gp.GoalPlanPK
        INNER JOIN dbo.CaseProgram cp
            ON cp.HVCaseFK = gp.HVCaseFK
        INNER JOIN dbo.codeApp stat
            ON gp.GoalStatus = stat.AppCode
               AND stat.AppCodeGroup = 'GoalPlanStatus'
        INNER JOIN dbo.codeApp area
            ON gp.GoalArea = area.AppCode
               AND area.AppCodeGroup = 'GoalPlanArea'
        INNER JOIN dbo.codeApp pertains
            ON gp.GoalPertainsTo = pertains.AppCode
               AND pertains.AppCodeGroup = 'GoalPlanPertains'
    WHERE gp.GoalPlanPK = @GoalPlanPK;
END;
GO
