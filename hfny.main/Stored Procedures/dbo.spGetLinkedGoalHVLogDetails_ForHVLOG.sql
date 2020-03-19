SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Chris Papas
-- Create date: 10/25/2018
-- Modified:    
-- Description: Get records from lnkHVLogGoalPlan where hvlogfk and goalfk matches - mostly for NOT DISCUSSED value
-- =============================================
CREATE PROCEDURE [dbo].[spGetLinkedGoalHVLogDetails_ForHVLOG]
	@GoalPlanFK INT,
    @HVLogFK INT
AS
SET NOCOUNT ON;

SELECT lnkHVLogGoalPlanPK, HVLogFK, GoalPlanFK, NotDiscussed 
FROM lnkHVLogGoalPlan
WHERE GoalPlanFK = @GoalPlanFK 
AND HVLogFK = @HVLogFK








GO
