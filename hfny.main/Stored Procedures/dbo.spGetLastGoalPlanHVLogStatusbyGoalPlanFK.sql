SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/18/18
-- Description: This stored procedure returns the GoalPlanHVLogStatus row that relates
-- to the most recent HVLog and the supplied Goal Plan FK
-- =============================================
CREATE PROCEDURE [dbo].[spGetLastGoalPlanHVLogStatusbyGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT TOP(1) gphls.GoalPlanHVLogStatusPK, gphls.DevelopmentSinceLastVisit, gphls.GoalProblemSolvingAndPlanEdit, 
		gphls.GoalPlanHVLogStatusCreateDate, gphls.GoalPlanHVLogStatusCreator, gphls.GoalPlanHVLogStatusEditDate,
		gphls.GoalPlanHVLogStatusEditor, gphls.NextStepEdit, gphls.GoalPlanFK, gphls.HVLogFK
	FROM dbo.GoalPlanHVLogStatus gphls 
	INNER JOIN dbo.GoalPlan gp ON gp.GoalPlanPK = gphls.GoalPlanFK
	INNER JOIN dbo.HVLog hl ON hl.HVLogPK = gphls.HVLogFK
	WHERE gphls.GoalPlanFK = @GoalPlanFK
	ORDER BY hl.VisitStartTime DESC
	
END
GO
