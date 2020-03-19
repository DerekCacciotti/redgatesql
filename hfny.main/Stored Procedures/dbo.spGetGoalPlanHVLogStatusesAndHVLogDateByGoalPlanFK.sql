SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/18/18
-- Description: This stored procedure returns the GoalPlanHVLogStatus rows 
-- and corresponding HVLog dates that relate to the supplied Goal Plan FK
-- =============================================
CREATE PROC [dbo].[spGetGoalPlanHVLogStatusesAndHVLogDateByGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT gphls.GoalPlanHVLogStatusPK, gphls.DevelopmentSinceLastVisit, gphls.Challenges, 
		gphls.GoalPlanHVLogStatusCreateDate, gphls.GoalPlanHVLogStatusCreator, gphls.GoalPlanHVLogStatusEditDate,
		gphls.GoalPlanHVLogStatusEditor, gphls.FollowUpAndSupport, gphls.GoalPlanFK, gphls.HVLogFK, hl.VisitStartTime
	FROM dbo.GoalPlanHVLogStatus gphls 
	INNER JOIN dbo.GoalPlan gp ON gp.GoalPlanPK = gphls.GoalPlanFK
	INNER JOIN dbo.HVLog hl ON hl.HVLogPK = gphls.HVLogFK
	WHERE gphls.GoalPlanFK = @GoalPlanFK
	ORDER BY hl.VisitStartTime DESC
	
END
GO
