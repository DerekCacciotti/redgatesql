SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellnkHVLogGoalPlan](@lnkHVLogGoalPlanPK int)

AS


DELETE 
FROM lnkHVLogGoalPlan
WHERE lnkHVLogGoalPlanPK = @lnkHVLogGoalPlanPK
GO
