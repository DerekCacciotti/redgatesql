SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 04/17/18
-- Description:	This stored procedure will return the values to populate the immunization report
-- =============================================
CREATE PROCEDURE [dbo].[rspImmunizations_7-2B] 
	-- Add the parameters for the stored procedure here
	@ProgramFK	VARCHAR(MAX) = NULL,
	@PointInTime DATETIME = NULL
AS
BEGIN
	IF @ProgramFK IS NULL
	BEGIN
		SELECT @ProgramFK = SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
											FROM HVProgram
											FOR XML PATH ('')),2,8000);
	END
	SET @ProgramFK = REPLACE(@ProgramFK,'"','')

	DECLARE @tblCohort6Month TABLE (
		HVCasePK INT,
		IntakeDate DATETIME,
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCDOB DATETIME,
		TCName VARCHAR(401)
	)

	DECLARE @tblCohort18Month TABLE (
		HVCasePK INT,
		IntakeDate DATETIME,
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCDOB DATETIME,
		TCName VARCHAR(401)
	)

	--The results table
	DECLARE @tblResults TABLE (
		HVCasePK INT,
		HFNumDueFor6Month INT,
		HFNumReceived6Month INT,
		HFNumExceptions6Month INT,
		HFPercentMeeting6Month VARCHAR(4),
		HFScore6Month CHAR(1),
		HFNumDueFor18Month INT,
		HFNumReceived18Month INT,
		HFNumExceptions18Month INT,
		HFPercentMeeting18Month VARCHAR(4),
		HFScore18Month CHAR(1),
		GroupBy INT, --6 for 6 month cohort 18 for 18 month cohort
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCName VARCHAR(401),
		TCDOB DATETIME,
		TCAgeMonths INT,
		IntakeDate DATETIME,
		NumExceptions INT,
		NumShotsRequired INT,
		NumShotsReceived INT,
		PercentUpToDate FLOAT,
		CreativeOutreachDates VARCHAR(30),
		Meeting VARCHAR(3),
		ReasonNotMeeting VARCHAR(MAX)
	)

	--Get the 6 month cohort (children between 6 months and 23 months old)
	INSERT INTO	@tblCohort6Month
		SELECT h.HVCasePK, h.IntakeDate, cp.PC1ID, (TRIM(w.FirstName) + ' ' + TRIM(w.LastName)) AS WorkerName, t.TCDOB, (t.TCFirstName + ' ' + t.TCLastName) AS TCName
		FROM dbo.HVCase h
		INNER JOIN dbo.TCID t ON t.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		WHERE (cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime)
		AND h.IntakeDate < DATEADD(MONTH, 6, t.TCDOB)
		AND @PointInTime >= DATEADD(MONTH, 6, t.TCDOB)
		AND @PointInTime <= DATEADD(MONTH, 23, t.TCDOB)
		ORDER BY cp.PC1ID

	--Get the 18 month cohort (children older than 18 months)
	INSERT INTO	@tblCohort18Month
		SELECT h.HVCasePK, h.IntakeDate, cp.PC1ID, (TRIM(w.FirstName) + ' ' + TRIM(w.LastName)) AS WorkerName, t.TCDOB, (t.TCFirstName + ' ' + t.TCLastName) AS TCName
		FROM dbo.HVCase h
		INNER JOIN dbo.TCID t ON t.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		WHERE (cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime)
		AND h.IntakeDate < DATEADD(MONTH, 6, t.TCDOB)
		AND @PointInTime >= DATEADD(MONTH, 18, t.TCDOB)
		ORDER BY cp.PC1ID

	--Insert the 6 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, GroupBy, PC1ID, HomeVisitorName, IntakeDate, TCDOB,  TCAgeMonths, TCName)
		SELECT HVCasePK, 6, PC1ID, HomeVisitorName, IntakeDate, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName FROM @tblCohort6Month

	--Insert the 18 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, GroupBy, PC1ID, HomeVisitorName, IntakeDate, TCDOB,  TCAgeMonths, TCName)
		SELECT HVCasePK, 18, PC1ID, HomeVisitorName, IntakeDate, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName FROM @tblCohort18Month

	UPDATE @tblResults SET HFNumDueFor6Month = 1, HFNumReceived6Month = 1, HFNumExceptions6Month = 1, HFPercentMeeting6Month = .75, HFScore6Month = 'A',
		HFNumDueFor18Month = 1, HFNumReceived18Month = 1, HFNumExceptions18Month = 1, HFPercentMeeting18Month = .75, HFScore18Month = 'A'
	--Get all the results
	SELECT * FROM @tblResults ORDER BY GroupBy, TCAgeMonths
END
GO
