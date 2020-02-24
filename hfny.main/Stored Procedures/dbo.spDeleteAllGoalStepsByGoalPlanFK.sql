SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/13/18
-- Description: This stored procedure deletes all the GoalStep rows that relate
-- to the supplied GoalPlanFK
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteAllGoalStepsByGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT,
	@User varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 DECLARE @tblRowsToBeDeleted AS TABLE (
		goalStepPK INT
	)
	
	--Get the rows to be deleted
	INSERT INTO @tblRowsToBeDeleted
		SELECT GoalStepPK FROM GoalStep
		WHERE GoalPlanFK = @GoalPlanFK

	--Delete all the GoalStep rows for a specific GoalPlan
	DELETE 
	FROM GoalStep 
	WHERE GoalPlanFK = @GoalPlanFK
	
	--Update the deleted rows
	UPDATE GoalStepDeleted 
	SET GoalStepDeleter = @User
	WHERE GoalStepPK IN (SELECT goalStepPK FROM @tblRowsToBeDeleted)
END
GO
