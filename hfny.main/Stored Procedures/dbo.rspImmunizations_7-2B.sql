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

	DECLARE @NumExceptions6Month INT = 0
	, @NumExceptions18Month INT = 0
	, @NumDue6Month INT = 0
	, @NumDue18Month INT = 0

	DECLARE @tblCohort6Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		IntakeDate DATETIME,
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCIDPK INT INDEX ixTCIDPK NONCLUSTERED,
		TCDOB DATETIME,
		TCName VARCHAR(401),
		Exempt BIT
	)

	DECLARE @tblCohort18Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		IntakeDate DATETIME,
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCIDPK INT INDEX ixTCIDPK NONCLUSTERED,
		TCDOB DATETIME,
		TCName VARCHAR(401),
		Exempt BIT
	)

	DECLARE @tblRequiredImmunizations6Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		MedicalItemCode CHAR(2),
		ScheduledEvent VARCHAR(50),
		NumImmunizationsRequired INT
	)

	DECLARE @tblRequiredImmunizations18Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		MedicalItemCode CHAR(2),
		ScheduledEvent VARCHAR(50),
		NumImmunizationsRequired INT
	)

	DECLARE @tblReceivedImmunizations TABLE (
		HVCasePK INT,
		TCIDFK INT,
		TCItemDate DATETIME,
		TCMedicalPK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		Cohort INT
	)

	DECLARE @tblReceivedImmunizations6Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		NumImmunizationsReceived INT
	)

	DECLARE @tblReceivedImmunizations18Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		NumImmunizationsReceived INT
	)

	DECLARE @tblNumImmunizations6Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		NumImmunizationsReceived INT
	)

	DECLARE @tblNumImmunizations18Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		NumImmunizationsReceived INT
	)

	DECLARE @tblMeeting6Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		Meeting VARCHAR(MAX)
	)

	DECLARE @tblMeeting18Month TABLE (
		HVCasePK INT,
		TCIDFK INT,
		Meeting VARCHAR(MAX)
	)

	DECLARE @tblMeetingReason TABLE (
		HVCasePK INT,
		TCIDFK INT,
		Meeting VARCHAR(MAX),
		GroupNum INT
	)

	DECLARE @tblCreativeOutreachDates TABLE (
		HVCasePK INT,
		StartDate DATETIME,
		EndDate DATETIME,
		Cohort INT
	)

	DECLARE @tblCreativeOutreachDatesCombined TABLE (
		HVCasePK INT,
		Dates VARCHAR(MAX),
		Cohort INT
	)

	--The results table
	DECLARE @tblResults TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		HFNumDueFor6Month INT,
		HFNumReceived6Month INT,
		HFNumExceptions6Month INT,
		HFPercentMeeting6Month DECIMAL(4,2),
		HFScore6Month CHAR(1),
		HFNumDueFor18Month INT,
		HFNumReceived18Month INT,
		HFNumExceptions18Month INT,
		HFPercentMeeting18Month DECIMAL(4,2),
		HFScore18Month CHAR(1),
		GroupBy INT, --6 for 6 month cohort 18 for 18 month cohort
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCIDPK INT,
		TCName VARCHAR(401),
		TCDOB DATETIME,
		TCAgeMonths INT,
		IntakeDate DATETIME,
		NumShotsRequired INT,
		NumShotsReceived INT,
		PercentUpToDate DECIMAL(4,2),
		CreativeOutreachDates VARCHAR(MAX),
		Meeting VARCHAR(3),
		ReasonNotMeeting VARCHAR(MAX),
		Exempt BIT
	)

	--Get the 6 month cohort (children between 6 months and 23 months old)
	INSERT INTO	@tblCohort6Month
		SELECT h.HVCasePK, h.IntakeDate, cp.PC1ID, (TRIM(w.FirstName) + ' ' + TRIM(w.LastName)) AS WorkerName, t.TCIDPK, t.TCDOB, (t.TCFirstName + ' ' + t.TCLastName) AS TCName, t.NoImmunization
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
		SELECT h.HVCasePK, h.IntakeDate, cp.PC1ID, (TRIM(w.FirstName) + ' ' + TRIM(w.LastName)) AS WorkerName, t.TCIDPK, t.TCDOB, (t.TCFirstName + ' ' + t.TCLastName) AS TCName, t.NoImmunization
		FROM dbo.HVCase h
		INNER JOIN dbo.TCID t ON t.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		WHERE (cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime)
		AND h.IntakeDate < DATEADD(MONTH, 6, t.TCDOB)
		AND @PointInTime >= DATEADD(MONTH, 18, t.TCDOB)
		ORDER BY cp.PC1ID

	--Remove(?) exceptions from the cohort after recording the number of exceptions
	SET @NumExceptions6Month = (SELECT ISNULL(COUNT(HVCasePK), 0) FROM @tblCohort6Month WHERE Exempt = 1)
	SET @NumExceptions18Month = (SELECT ISNULL(COUNT(HVCasePK), 0) FROM @tblCohort18Month WHERE Exempt = 1)
	--DELETE FROM @tblCohort6Month WHERE Exempt = 1
	--DELETE FROM @tblCohort18Month WHERE Exempt = 1


	--Get the required immunizations for both cohorts
	INSERT INTO @tblRequiredImmunizations6Month
		SELECT DISTINCT HVCasePK, TCIDPK, item.MedicalItemCode, due.ScheduledEvent, MAX(due.frequency) numRequired
		FROM @tblCohort6Month, dbo.codeDueByDates due 
		INNER JOIN dbo.codeMedicalItem item ON due.ScheduledEvent = item.MedicalItemTitle
		WHERE due.ScheduledEvent IN ('DTaP', 'HEP-B', 'HIB', 'PCV', 'Polio', 'Roto', 'Flu', 'MMR', 'HEP-A', 'VZ')
		AND CONVERT(INT, due.Interval) <= 6
		GROUP BY HVCasePK, TCIDPK, MedicalItemCode, ScheduledEvent

		--Get the required immunizations for both cohorts
	INSERT INTO @tblRequiredImmunizations18Month
		SELECT DISTINCT HVCasePK, TCIDPK, item.MedicalItemCode, due.ScheduledEvent, MAX(due.frequency) numRequired
		FROM @tblCohort18Month, dbo.codeDueByDates due 
		INNER JOIN dbo.codeMedicalItem item ON due.ScheduledEvent = item.MedicalItemTitle
		WHERE due.ScheduledEvent IN ('DTaP', 'HEP-B', 'HIB', 'PCV', 'Polio', 'Roto', 'Flu', 'MMR', 'HEP-A', 'VZ')
		AND CONVERT(INT, due.Interval) <= 18
		GROUP BY HVCasePK, TCIDPK, MedicalItemCode, ScheduledEvent

	INSERT INTO @tblReceivedImmunizations
		SELECT DISTINCT coh.HVCasePK, med.TCIDFK, med.TCItemDate, med.TCMedicalPK, med.TCMedicalItem, item.MedicalItemTitle,  6
		FROM @tblCohort6Month coh
		INNER JOIN dbo.TCMedical med ON coh.HVCasePK = med.HVCaseFK
		INNER JOIN dbo.codeMedicalItem item ON med.TCMedicalItem = item.MedicalItemCode
		WHERE med.TCMedicalItem IN (SELECT MedicalItemCode FROM @tblRequiredImmunizations6Month)

	INSERT INTO @tblReceivedImmunizations
		SELECT DISTINCT coh.HVCasePK, med.TCIDFK, med.TCItemDate, med.TCMedicalPK, med.TCMedicalItem, item.MedicalItemTitle,  18
		FROM @tblCohort18Month coh
		INNER JOIN dbo.TCMedical med ON coh.HVCasePK = med.HVCaseFK
		INNER JOIN dbo.codeMedicalItem item ON med.TCMedicalItem = item.MedicalItemCode
		WHERE med.TCMedicalItem IN (SELECT MedicalItemCode FROM @tblRequiredImmunizations18Month)

	INSERT INTO @tblReceivedImmunizations6Month
		SELECT HVCasePK, TCIDFK, TCMedicalItem, TCMedicalItemTitle, COUNT(TCMedicalItem) numImmunizations 
		FROM @tblReceivedImmunizations 
		WHERE Cohort = 6 
		GROUP BY HVCasePK, TCIDFK, TCMedicalItem, TCMedicalItemTitle

	INSERT INTO @tblReceivedImmunizations18Month
		SELECT HVCasePK, TCIDFK, TCMedicalItem, TCMedicalItemTitle, COUNT(TCMedicalItem) numImmunizations 
		FROM @tblReceivedImmunizations 
		WHERE Cohort = 18
		GROUP BY HVCasePK, TCIDFK, TCMedicalItem, TCMedicalItemTitle

	INSERT INTO @tblNumImmunizations6Month
		SELECT HVCasePK, TCIDFK, SUM(NumImmunizationsReceived) numImmunizationsReceived 
		FROM @tblReceivedImmunizations6Month 
		GROUP BY HVCasePK, TCIDFK

	INSERT INTO @tblNumImmunizations18Month
		SELECT HVCasePK, TCIDFK, SUM(NumImmunizationsReceived) numImmunizationsReceived 
		FROM @tblReceivedImmunizations18Month 
		GROUP BY HVCasePK, TCIDFK

	INSERT INTO @tblMeeting6Month
		SELECT req.HVCasePK, req.TCIDPK, CASE WHEN rec.NumImmunizationsReceived IS NULL OR rec.NumImmunizationsReceived < req.NumImmunizationsRequired THEN TRIM(ScheduledEvent) + ' Missing' ELSE 'Meeting' END AS Meeting
		FROM
		@tblRequiredImmunizations6Month req
		LEFT JOIN 
		@tblReceivedImmunizations6Month rec
		ON req.HVCasePK = rec.HVCasePK AND MedicalItemCode = TCMedicalItem

	INSERT INTO @tblMeeting18Month
		SELECT req.HVCasePK, req.TCIDPK, CASE WHEN rec.NumImmunizationsReceived IS NULL OR rec.NumImmunizationsReceived < req.NumImmunizationsRequired THEN TRIM(ScheduledEvent) + ' Missing' ELSE 'Meeting' END AS Meeting
		FROM
		@tblRequiredImmunizations18Month req
		LEFT JOIN 
		@tblReceivedImmunizations18Month rec
		ON req.HVCasePK = rec.HVCasePK AND MedicalItemCode = TCMedicalItem

	
	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDFK, STUFF((SELECT ', ' + Meeting AS [text()] FROM @tblMeeting6Month mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.Meeting <> 'Meeting' FOR XML PATH('')), 1, 2, ''), 6 
		FROM @tblMeeting6Month mt2

	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDFK, STUFF((SELECT ', ' + Meeting AS [text()] FROM @tblMeeting18Month mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.Meeting <> 'Meeting' FOR XML PATH('')), 1, 2, ''), 18
		FROM @tblMeeting18Month mt2

	INSERT INTO @tblCreativeOutreachDates
		SELECT coh.HVCasePK, hvl.StartLevelDate, hvl.EndLevelDate, 6
		FROM @tblCohort6Month coh
		INNER JOIN dbo.HVLevelDetail hvl ON coh.HVCasePK = hvl.HVCaseFK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on hvl.ProgramFK = listitem
		WHERE hvl.LevelName LIKE '%Level X%'

	INSERT INTO @tblCreativeOutreachDates
		SELECT coh.HVCasePK, hvl.StartLevelDate, hvl.EndLevelDate, 18
		FROM @tblCohort18Month coh
		INNER JOIN dbo.HVLevelDetail hvl ON coh.HVCasePK = hvl.HVCaseFK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on hvl.ProgramFK = listitem
		WHERE hvl.LevelName LIKE '%Level X%'

	INSERT INTO @tblCreativeOutreachDatesCombined
		SELECT DISTINCT mt2.HVCasePK, STUFF((SELECT ' | ' + CONVERT(VARCHAR(10), mt.StartDate, 101) + ' - ' + CONVERT(VARCHAR(10), mt.EndDate, 101) AS [text()] FROM @tblCreativeOutreachDates mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.Cohort = mt2.Cohort FOR XML PATH('')), 1, 2, ''), mt2.Cohort
		FROM @tblCreativeOutreachDates mt2

	--Insert the 6 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, GroupBy, PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB,  TCAgeMonths, TCName, NumShotsReceived, Meeting, ReasonNotMeeting, Exempt, CreativeOutreachDates)
		SELECT DISTINCT coh.HVCasePK, 6, coh.PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName, ISNULL(imm.NumImmunizationsReceived, 0), CASE WHEN reason.Meeting IS NULL THEN 'Yes' ELSE 'No' END AS Meeting, reason.Meeting, coh.Exempt, levelx.Dates
		FROM @tblCohort6Month coh
		INNER JOIN @tblNumImmunizations6Month imm ON imm.HVCasePK = coh.HVCasePK AND imm.TCIDFK = coh.TCIDPK
		INNER JOIN @tblMeetingReason reason ON reason.HVCasePK = coh.HVCasePK AND reason.TCIDFK = coh.TCIDPK AND reason.GroupNum = 6
		LEFT JOIN @tblCreativeOutreachDatesCombined levelx ON levelx.HVCasePK = coh.HVCasePK AND levelx.Cohort = 6
		

	--Insert the 18 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, GroupBy, PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB,  TCAgeMonths, TCName, NumShotsReceived, Meeting, ReasonNotMeeting, Exempt, CreativeOutreachDates)
		SELECT DISTINCT coh.HVCasePK, 18, coh.PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName, ISNULL(imm.NumImmunizationsReceived, 0), CASE WHEN reason.Meeting IS NULL THEN 'Yes' ELSE 'No' END AS Meeting, reason.Meeting, coh.Exempt, levelx.Dates
		FROM @tblCohort18Month coh
		INNER JOIN @tblNumImmunizations18Month imm ON imm.HVCasePK = coh.HVCasePK AND imm.TCIDFK = coh.TCIDPK
		INNER JOIN @tblMeetingReason reason ON reason.HVCasePK = coh.HVCasePK AND reason.TCIDFK = coh.TCIDPK AND reason.GroupNum = 18
		LEFT JOIN @tblCreativeOutreachDatesCombined levelx ON levelx.HVCasePK = coh.HVCasePK AND levelx.Cohort = 18

	--UPDATE @tblResults SET HFNumDueFor6Month = 1, HFNumReceived6Month = 1, HFPercentMeeting6Month = .75, HFScore6Month = 'A',
	--	HFNumDueFor18Month = 1, HFNumReceived18Month = 1, HFPercentMeeting18Month = .75, HFScore18Month = 'A'
	
	--Update exempt cases
	UPDATE @tblResults SET Meeting = 'N/A', ReasonNotMeeting = 'Exempt' WHERE Exempt = 1

	--Remove certain cases
	DELETE FROM @tblResults WHERE TCAgeMonths > 6 AND TCAgeMonths < 12 AND Meeting = 'No'
	DELETE FROM @tblResults WHERE TCAgeMonths > 12 AND TCAgeMonths < 24 AND Meeting = 'No'

	--Update the number of shots required
	UPDATE @tblResults SET NumShotsRequired = (SELECT SUM(NumImmunizationsRequired) 
		FROM @tblRequiredImmunizations6Month 
		WHERE HVCasePK = (SELECT TOP 1 HVCasePK FROM @tblRequiredImmunizations6Month)) --Get the required number of immunizations for one case
		WHERE GroupBy = 6
	UPDATE @tblResults SET NumShotsRequired = (SELECT SUM(NumImmunizationsRequired) 
		FROM @tblRequiredImmunizations18Month 
		WHERE HVCasePK = (SELECT TOP 1 HVCasePK FROM @tblRequiredImmunizations18Month)) 
		WHERE GroupBy = 18

	--Update the number of exceptions in the results table
	UPDATE @tblResults SET HFNumExceptions6Month = @NumExceptions6Month
	UPDATE @tblResults SET HFNumExceptions18Month = @NumExceptions18Month

	--Update the number of cases due for immunizations
	SET @NumDue6Month = (SELECT COUNT(*) FROM @tblResults WHERE GroupBy = 6)
	SET @NumDue18Month = (SELECT COUNT(*) FROM @tblResults WHERE GroupBy = 18)
	UPDATE @tblResults SET HFNumDueFor6Month = @NumDue6Month
	UPDATE @tblResults SET HFNumDueFor18Month = @NumDue18Month

	--Update the number of cases that received all immunizations
	UPDATE @tblResults SET HFNumReceived6Month = (SELECT COUNT(*) FROM @tblResults WHERE Meeting IN('Yes', 'N/A') AND GroupBy = 6)
	UPDATE @tblResults SET HFNumReceived18Month = (SELECT COUNT(*) FROM @tblResults WHERE Meeting IN('Yes', 'N/A') AND GroupBy = 18)

	--Update the percent of cases that meet
	UPDATE @tblResults SET HFPercentMeeting6Month = CONVERT(DECIMAL(4,2), (CONVERT(DECIMAL, (HFNumReceived6Month + HFNumExceptions6Month)) /  @NumDue6Month))
	UPDATE @tblResults SET HFPercentMeeting18Month = CONVERT(DECIMAL(4,2), (CONVERT(DECIMAL, (HFNumReceived18Month + HFNumExceptions18Month)) / @NumDue18Month))
	
	--Update the scores for the program
	UPDATE @tblResults SET HFScore6Month = CASE WHEN HFPercentMeeting6Month >= 0.90 THEN '3' 
												WHEN HFPercentMeeting6Month < 0.90 AND HFPercentMeeting6Month >= 0.75 THEN '2'
												WHEN HFPercentMeeting6Month < 0.75 THEN '1'
												ELSE 'E'
												END
	UPDATE @tblResults SET HFScore18Month = CASE WHEN HFPercentMeeting18Month >= 0.90 THEN '3' 
												WHEN HFPercentMeeting18Month < 0.90 AND HFPercentMeeting18Month >= 0.75 THEN '2'
												WHEN HFPercentMeeting18Month < 0.75 THEN '1'
												ELSE 'E'
												END

	--Get all the results
	SELECT * FROM @tblResults ORDER BY GroupBy, HVCasePK
END
GO
