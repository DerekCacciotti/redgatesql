SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- =============================================
-- Author:		Chris Papas
-- Create date: 10/25/2018
-- Modified:    
-- Description: Get records from lnkHVLogGoalPlan where hvlogfk matches
-- =============================================

CREATE PROCEDURE [dbo].[spGetLinkedLogsAndGoals]
@HVLogPK INT = null

AS

SET NOCOUNT ON;

	SELECT lnkHVLogGoalPlanPK, HVLOGFK, GoalPlanFK, NOTDiscussed
	FROM lnkHVLogGoalPlan
	WHERE hvlogfk = @HVLogPK








GO
