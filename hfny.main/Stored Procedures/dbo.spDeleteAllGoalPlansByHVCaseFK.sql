SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/13/18
-- Description: This stored procedure deletes all the GoalPlan rows that relate
-- to the supplied HVCaseFK
-- =============================================
CREATE PROC [dbo].[spDeleteAllGoalPlansByHVCaseFK]
	-- Add the parameters for the stored procedure here
	@HVCaseFK INT,
	@User varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    DECLARE @tblRowsToBeDeleted AS TABLE (
		currentPK INT
	)

	DECLARE @tblGoalPlansToBeDeleted AS TABLE (
		goalPlanPK INT
	)

	--Get the goal plans to be deleted
	INSERT INTO @tblGoalPlansToBeDeleted 
		SELECT gp.GoalPlanPK FROM dbo.GoalPlan gp WHERE gp.HVCaseFK = @HVCaseFK

	--=====================================================================--
	-- GoalStep deletion
	--=====================================================================--

	--Get the rows to be deleted
	INSERT INTO @tblRowsToBeDeleted
		SELECT GoalStepPK
		FROM GoalStep
		WHERE GoalPlanFK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)

	--Delete all the GoalStep rows
	DELETE
	FROM dbo.GoalStep
	WHERE GoalPlanFK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)

	--Update the deleted rows
	UPDATE GoalStepDeleted 
	SET GoalStepDeleter = @User
	WHERE GoalStepPK IN (SELECT currentPK FROM @tblRowsToBeDeleted)

	DELETE FROM @tblRowsToBeDeleted
	
	--=====================================================================--
	-- GoalPlanHVLogStatus deletion
	--=====================================================================--

	--Get the rows to be deleted
	INSERT INTO @tblRowsToBeDeleted
		SELECT GoalPlanHVLogStatusPK
		FROM GoalPlanHVLogStatus 
		WHERE GoalPlanFK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)

	--Delete all the GoalPlanHVLogStatus rows
	DELETE
	FROM GoalPlanHVLogStatus
	WHERE GoalPlanFK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)
	
	--Update the deleted rows
	UPDATE GoalPlanHVLogStatusDeleted 
	SET GoalPlanHVLogStatusDeleter = @User
	WHERE GoalPlanHVLogStatusPK IN (SELECT currentPK FROM @tblRowsToBeDeleted)
	
	--=====================================================================--
	-- lnkHVLogGoalPlan deletion
	--=====================================================================--

	--Delete all the lnkHVLogGoalPlan rows
	DELETE
	FROM dbo.lnkHVLogGoalPlan
	WHERE GoalPlanFK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)

	--=====================================================================--
	-- GoalPlan deletion
	--=====================================================================--
	
	--Get the rows to be deleted
	INSERT INTO @tblRowsToBeDeleted
		SELECT GoalPlanPK
		FROM GoalPlan
		WHERE GoalPlanPK IN (SELECT goalPlanPK FROM @tblGoalPlansToBeDeleted)

	--Delete all the GoalPlan rows for a specific HVCase
	DELETE 
	FROM GoalPlan 
	WHERE HVCaseFK = @HVCaseFK

	--Update the deleted rows
	UPDATE GoalPlanDeleted 
	SET GoalPlanDeleter = @User
	WHERE GoalPlanPK IN (SELECT currentPK FROM @tblRowsToBeDeleted)
END
GO
