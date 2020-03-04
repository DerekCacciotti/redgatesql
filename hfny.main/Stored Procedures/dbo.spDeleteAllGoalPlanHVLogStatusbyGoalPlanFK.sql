SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/13/18
-- Description: This stored procedure deletes all the GoalPlanHVLogStatus rows that relate
-- to the supplied GoalPlanFK
-- =============================================
CREATE PROC [dbo].[spDeleteAllGoalPlanHVLogStatusbyGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT,
	@User varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblRowsToBeDeleted AS TABLE (
		GoalPlanHVLogStatusPK INT
	)

	--Get the rows to be deleted
	INSERT INTO @tblRowsToBeDeleted
		SELECT GoalPlanHVLogStatusPK
		FROM GoalPlanHVLogStatus
		WHERE GoalPlanFK = @GoalPlanFK

	--Delete all the GoalPlanHVLogStatus rows for a specific GoalPlan
	DELETE 
	FROM GoalPlanHVLogStatus 
	WHERE GoalPlanFK = @GoalPlanFK

	--Update the deleted rows
	UPDATE dbo.GoalPlanHVLogStatusDeleted 
	SET GoalPlanHVLogStatusDeleter = @User
	WHERE GoalPlanHVLogStatusPK IN (SELECT GoalPlanHVLogStatusPK FROM @tblRowsToBeDeleted trtbd)
END
GO
