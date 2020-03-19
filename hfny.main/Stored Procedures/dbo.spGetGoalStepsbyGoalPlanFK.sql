SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/01/18
-- Description: This stored procedure returns all the goal steps for a specific goal plan
-- =============================================
CREATE PROCEDURE [dbo].[spGetGoalStepsbyGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM dbo.GoalStep gs WHERE gs.GoalPlanFK = @GoalPlanFK
END
GO
