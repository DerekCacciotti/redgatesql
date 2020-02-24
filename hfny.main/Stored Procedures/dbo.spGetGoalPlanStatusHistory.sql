SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 07/11/18
-- Description:	This stored procedure returns a history of 
-- changes to the status of a GoalPlan
-- Edit date: 10/23/18
-- Edit reason: Duplicate top rows existed if the current status existed in the
-- deleted table
-- =============================================
CREATE PROC [dbo].[spGetGoalPlanStatusHistory] 
	-- Add the parameters for the stored procedure here
	@GoalPlanPK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblResults TABLE (
		GoalPlanPK INT,
		GoalStatus VARCHAR(200),
		GoalStatusDate DATETIME,
		CurrentStatus BIT
	)

	--Get the current status
	INSERT INTO @tblResults
	(
	    GoalPlanPK,
	    GoalStatus,
	    GoalStatusDate,
		CurrentStatus
	)
	SELECT 
	gp.GoalPlanPK,
	RTRIM(ca.AppCodeText) + ' (Current)',
	gp.GoalStatusDate,
	1
	FROM dbo.GoalPlan gp
	INNER JOIN dbo.codeApp ca ON gp.GoalStatus = ca.AppCode AND ca.AppCodeGroup = 'GoalPlanStatus'
	WHERE gp.GoalPlanPK = @GoalPlanPK
    
	--Get the status history
	INSERT INTO @tblResults
	(
	    GoalPlanPK,
	    GoalStatus,
	    GoalStatusDate,
		CurrentStatus
	)
	SELECT DISTINCT 
		gpd.GoalPlanPK, 
		RTRIM(ca.AppCodeText), 
		gpd.GoalStatusDate,
		0
	FROM dbo.GoalPlanDeleted gpd
	INNER JOIN dbo.codeApp ca ON gpd.GoalStatus = ca.AppCode AND ca.AppCodeGroup = 'GoalPlanStatus'
	LEFT JOIN dbo.GoalPlan gp ON gp.GoalPlanPK = gpd.GoalPlanPK AND gp.GoalStatus = gpd.GoalStatus AND gp.GoalStatusDate = gpd.GoalStatusDate
	WHERE ISNULL(gpd.Deleted, 0) = 0 
	AND gpd.GoalPlanPK = @GoalPlanPK
	AND gp.GoalPlanPK IS NULL --Eliminate duplicate top row

	SELECT * FROM @tblResults tr
	ORDER BY tr.GoalStatusDate DESC
END
GO
