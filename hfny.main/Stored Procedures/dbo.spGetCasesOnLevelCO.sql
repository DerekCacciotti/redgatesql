SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetCasesOnLevelCO]
	@SupervisorFK INT = NULL,
	@WorkerFK INT = NULL,
	@ProgramFK VARCHAR(MAX) = NULL
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @ProgramFK IS NULL
	BEGIN
		SELECT	@ProgramFK = SUBSTRING(
							(
								SELECT	',' + LTRIM(RTRIM(STR(HVProgramPK)))
								FROM	HVProgram
								FOR XML PATH('')
							),
							2,
							8000
									)
	END;

	SET @ProgramFK = REPLACE(@ProgramFK, '"', '')

	SELECT
	cp.PC1ID,
	RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName) AS WorkerName,
	'Level CO' AS LevelName,
	cp.CurrentLevelDate AS LevelDate,
	DATEDIFF(DAY, cp.CurrentLevelDate, GETDATE()) AS DaysOnLevel,
	MAX(cp.CurrentLevelDate) AS LastCODate
	FROM	dbo.CaseProgram cp
		INNER JOIN dbo.SplitString(@ProgramFK, ',')
			ON cp.ProgramFK = ListItem
		INNER JOIN dbo.Worker w 
			ON w.WorkerPK = ISNULL(cp.CurrentFSWFK, cp.CurrentFAWFK)
		INNER JOIN dbo.WorkerProgram wp 
			ON wp.WorkerFK = w.WorkerPK
			AND wp.ProgramFK = cp.ProgramFK
		
    WHERE w.WorkerPK = ISNULL(@WorkerFK, w.WorkerPK)
		  AND wp.SupervisorFK = ISNULL(@SupervisorFK, wp.SupervisorFK)
		  AND cp.DischargeDate IS NULL
		  AND cp.CurrentLevelFK = 22 OR cp.CurrentLevelFK = 23 OR cp.CurrentLevelFK = 24 OR cp.CurrentLevelFK = 25 
		  OR cp.CurrentLevelFK = 26
		  OR cp.CurrentLevelFK = 27
		  OR cp.CurrentFSWFK = 28
		  OR cp.CurrentLevelFK = 29
		  OR cp.CurrentLevelFK	= 1056
	GROUP BY cp.PC1ID, (RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName)), cp.CurrentLevelDate, (DATEDIFF(DAY, cp.CurrentLevelDate, GETDATE()))
END

GO
