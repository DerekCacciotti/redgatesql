SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/21/2018
-- Description:	Get cases that are on level CO and get the last creative outreach form 
-- for the case
-- =============================================
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
	cl.LevelName,

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


			INNER JOIN codeLevel cl ON cl.codeLevelPK = cp.CurrentLevelFK
    WHERE w.WorkerPK = ISNULL(@WorkerFK, w.WorkerPK)
		  AND cp.DischargeDate IS NULL
		  and (cp.CurrentLevelFK = 22
		  or cp.CurrentLevelFK = 24
		  or cp.CurrentLevelFK = 25
		  or cp.CurrentLevelFK = 26
		  or cp.CurrentLevelFK = 27
		  or cp.CurrentLevelFK = 28
		  or cp.CurrentLevelFK = 29
		  OR cp.CurrentLevelFK = 1056
		 OR cp.CurrentLevelFK = 1080
OR cp.CurrentLevelFK = 1081
OR cp.CurrentLevelFK =1082
OR cp.CurrentLevelFK = 1083
OR cp.CurrentLevelFK =1084
 OR cp.CurrentLevelFK =1085
OR cp.CurrentLevelFK =1086
OR cp.CurrentLevelFK = 1087
OR cp.CurrentLevelFK = 1088
OR cp.CurrentLevelFK = 1089
OR cp.CurrentLevelFK =1090
OR cp.CurrentLevelFK =1091
OR cp.CurrentLevelFK =1092
OR cp.CurrentLevelFK = 1093
OR cp.CurrentLevelFK = 1094
OR cp.CurrentLevelFK =1095
OR cp.CurrentLevelFK = 1096
OR cp.CurrentLevelFK =1097)
	GROUP BY cp.PC1ID, (RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName)), cl.LevelName, cp.CurrentLevelDate, (DATEDIFF(DAY, cp.CurrentLevelDate, GETDATE()))
END

GO
