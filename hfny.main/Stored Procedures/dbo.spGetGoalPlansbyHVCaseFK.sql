SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/01/18
-- Description: This stored procedure returns all the goal plans for a specific case
-- =============================================
CREATE PROCEDURE [dbo].[spGetGoalPlansbyHVCaseFK]
	-- Add the parameters for the stored procedure here
	@HVCaseFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Retrieve all the GoalPlan fields and the status from the codeApp table
	SELECT *
	FROM dbo.GoalPlan gp 
	WHERE gp.HVCaseFK = @HVCaseFK
	ORDER BY gp.GoalPlanActive DESC, gp.StartDate ASC, gp.GoalName ASC
END
GO
