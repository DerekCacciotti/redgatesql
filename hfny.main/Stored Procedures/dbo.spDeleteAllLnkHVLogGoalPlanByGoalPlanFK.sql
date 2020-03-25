SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 02/27/2020
-- Description: This stored procedure deletes all the lnkHVLogGoalPlan rows
-- related to the goal plan
-- =============================================
CREATE PROC [dbo].[spDeleteAllLnkHVLogGoalPlanByGoalPlanFK]
	@GoalPlanFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Delete all the rows
	DELETE 
	FROM dbo.lnkHVLogGoalPlan 
	WHERE GoalPlanFK = @GoalPlanFK
END
GO
