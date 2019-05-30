SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 07/31/18
-- Description:	This stored procedure returns upcoming scheduled home visits for a worker
-- that are between two days overdue and 7 days until due.
-- moved by derek c for dashboards
-- =============================================
CREATE PROC [dbo].[spGetScheduledHomeVisitsByWorker] 
	-- Add the parameters for the stored procedure here
	@WorkerFK INT,
	@ProgramFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblCohort AS TABLE (
		PC1ID VARCHAR(13),
		MostRecentHVLogDate DATETIME,
		NextExpectedVisit DATETIME,
		HVCaseFK INT
	)

	DECLARE @tblHVLogNextScheduledVisit AS TABLE (
		PC1ID VARCHAR(13),
		NextScheduledVisit DATETIME
	)

	--Get the cohort and most of the required information
	INSERT INTO @tblCohort
	(
		PC1ID,
		MostRecentHVLogDate,
		NextExpectedVisit,
		HVCaseFK
	)
	SELECT DISTINCT cp.PC1ID,  
	MAX(hl.HVLogCreateDate) AS MostRecentVisitDate,
	DATEADD(DAY, ROUND(7 / NULLIF(cl.MaximumVisit, 0), 0), MAX(hl.HVLogCreateDate)) AS NextExpectedVisit,
	cp.HVCaseFK
	FROM dbo.CaseProgram cp
		INNER JOIN dbo.codeLevel cl ON cl.codeLevelPK = cp.CurrentLevelFK
		INNER JOIN dbo.Worker w ON cp.CurrentFSWFK = w.WorkerPK
		INNER JOIN dbo.WorkerAssignment wa ON wa.WorkerFK = w.WorkerPK AND wa.ProgramFK = cp.ProgramFK
		INNER JOIN dbo.HVLog hl ON hl.HVCaseFK = cp.HVCaseFK AND hl.ProgramFK = cp.ProgramFK
	WHERE cl.MaximumVisit IS NOT NULL 
		AND cl.MaximumVisit > 0
		AND cp.ProgramFK = @ProgramFK
		AND w.WorkerPK = @WorkerFK
	GROUP BY cp.PC1ID, cp.HVCaseFK, cl.MaximumVisit
	ORDER BY cp.PC1ID

	--Get the highest scheduled visit (so that cases with 2 HVLogs on the same day do not mess the calculation up)
	INSERT INTO @tblHVLogNextScheduledVisit
	(
		PC1ID,
		NextScheduledVisit
	)
	SELECT TOP 1 tc.PC1ID, hl.NextScheduledVisit FROM 
		@tblCohort tc 
		INNER JOIN dbo.HVLog hl ON hl.HVCaseFK = tc.HVCaseFK AND hl.HVLogCreateDate = tc.MostRecentHVLogDate
		WHERE PC1ID = tc.PC1ID
		ORDER BY hl.NextScheduledVisit DESC

	--Return the required information
	SELECT tc.PC1ID,
			tc.NextExpectedVisit,
			thlnsv.NextScheduledVisit
			FROM @tblCohort tc
			LEFT JOIN @tblHVLogNextScheduledVisit thlnsv ON thlnsv.PC1ID = tc.PC1ID
			WHERE tc.NextExpectedVisit <= DATEADD(DAY, 8, GETDATE())
			ORDER BY tc.NextExpectedVisit ASC

END
GO
