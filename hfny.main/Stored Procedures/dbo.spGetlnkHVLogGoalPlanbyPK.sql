SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlnkHVLogGoalPlanbyPK]

(@lnkHVLogGoalPlanPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM lnkHVLogGoalPlan
WHERE lnkHVLogGoalPlanPK = @lnkHVLogGoalPlanPK
GO
