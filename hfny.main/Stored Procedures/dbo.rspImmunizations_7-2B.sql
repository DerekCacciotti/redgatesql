SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ben Simmons
-- Create date: 04/17/18
-- Description:	This stored procedure will return the values to populate the immunization report
-- EDIT DATE: 07/02/18
-- EDITED BY: Benjamin Simmons
-- EDIT DESCRIPTION: Updated score calculations to meet BPS and updated cohorts to meet BPS
-- =============================================
CREATE PROC [dbo].[rspImmunizations_7-2B] 
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

	DECLARE @tblCohort TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		IntakeDate DATETIME,
		PC1ID CHAR(13),
		HomeVisitorName VARCHAR(60),
		TCIDPK INT INDEX ixTCIDPK NONCLUSTERED,
		TCDOB DATETIME,
		TCName VARCHAR(401),
		Exempt BIT
	)

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

	DECLARE @ImmunizationCount6Month TABLE (
		MedicalItemCode CHAR(2),
		NumRequired INT
    )

	DECLARE @ImmunizationCount18Month TABLE (
		MedicalItemCode CHAR(2),
		NumRequired INT
    )

	DECLARE @tblReceivedImmunizations TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		TCItemDate DATETIME,
		TCMedicalPK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		Cohort INT
	)

	DECLARE @tblReceivedImmunizations6Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		NumImmunizationsReceived INT
	)

	DECLARE @tblReceivedImmunizations18Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		TCMedicalItem CHAR(2),
		TCMedicalItemTitle CHAR(20),
		NumImmunizationsReceived INT
	)

	DECLARE @tblNumImmunizations6Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		NumImmunizationsReceived INT
	)

	DECLARE @tblNumImmunizations18Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		NumImmunizationsReceived INT
	)

	DECLARE @tblMeeting6Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		Meeting VARCHAR(MAX)
	)

	DECLARE @tblMeeting18Month TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		Meeting VARCHAR(MAX)
	)

	DECLARE @tblMeetingReason TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCIDPK INT,
		Meeting VARCHAR(MAX),
		GroupNum INT
	)

	DECLARE @tblCreativeOutreachDates TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		StartDate DATETIME,
		EndDate DATETIME,
		Cohort INT
	)

	DECLARE @tblCreativeOutreachDatesCombined TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
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
		Cohort INT, --6 for 6 month cohort 18 for 18 month cohort
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

	INSERT INTO @tblCohort
	SELECT h.HVCasePK, h.IntakeDate, cp.PC1ID, (RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName)) AS WorkerName, t.TCIDPK, t.TCDOB, (t.TCFirstName + ' ' + t.TCLastName) AS TCName, t.NoImmunization
		FROM dbo.HVCase h
		INNER JOIN dbo.TCID t ON t.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		WHERE (cp.DischargeDate IS NULL OR cp.DischargeDate > @PointInTime)
		AND h.IntakeDate < DATEADD(MONTH, 6, t.TCDOB)
		AND @PointInTime >= DATEADD(MONTH, 12, t.TCDOB)
		ORDER BY cp.PC1ID


	--Get the 6 month cohort (children between 12 months and 23 months old)
	INSERT INTO	@tblCohort6Month
		SELECT HVCasePK, IntakeDate, PC1ID, HomeVisitorName, TCIDPK, TCDOB, TCName, Exempt
		FROM @tblCohort
		WHERE @PointInTime >= DATEADD(MONTH, 12, TCDOB)
		AND @PointInTime <= DATEADD(MONTH, 23, TCDOB)
		ORDER BY PC1ID

	--Get the 18 month cohort (children older than 24 months)
	INSERT INTO	@tblCohort18Month
		SELECT HVCasePK, IntakeDate, PC1ID, HomeVisitorName, TCIDPK, TCDOB, TCName, Exempt
		FROM @tblCohort
		WHERE @PointInTime >= DATEADD(MONTH, 24, TCDOB)
		ORDER BY PC1ID

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

	INSERT INTO @ImmunizationCount6Month
        SELECT DISTINCT MedicalItemCode, NumImmunizationsRequired FROM @tblRequiredImmunizations6Month

	INSERT INTO @ImmunizationCount18Month
		SELECT DISTINCT MedicalItemCode, NumImmunizationsRequired FROM @tblRequiredImmunizations18Month

	INSERT INTO @tblReceivedImmunizations
		SELECT DISTINCT coh.HVCasePK, med.TCIDFK, med.TCItemDate, med.TCMedicalPK, med.TCMedicalItem, item.MedicalItemTitle,  6
		FROM @tblCohort6Month coh
		INNER JOIN dbo.TCMedical med ON coh.HVCasePK = med.HVCaseFK
		INNER JOIN dbo.codeMedicalItem item ON med.TCMedicalItem = item.MedicalItemCode
		WHERE med.TCMedicalItem IN (SELECT MedicalItemCode FROM @ImmunizationCount6Month)

	INSERT INTO @tblReceivedImmunizations
		SELECT DISTINCT coh.HVCasePK, med.TCIDFK, med.TCItemDate, med.TCMedicalPK, med.TCMedicalItem, item.MedicalItemTitle,  18
		FROM @tblCohort18Month coh
		INNER JOIN dbo.TCMedical med ON coh.HVCasePK = med.HVCaseFK
		INNER JOIN dbo.codeMedicalItem item ON med.TCMedicalItem = item.MedicalItemCode
		WHERE med.TCMedicalItem IN (SELECT MedicalItemCode FROM @ImmunizationCount18Month)

	INSERT INTO @tblReceivedImmunizations6Month
		SELECT HVCasePK, TCIDPK, TCMedicalItem, TCMedicalItemTitle, COUNT(TCMedicalItem) numImmunizations 
		FROM @tblReceivedImmunizations 
		WHERE Cohort = 6 
		GROUP BY HVCasePK, TCIDPK, TCMedicalItem, TCMedicalItemTitle

	INSERT INTO @tblReceivedImmunizations18Month
		SELECT HVCasePK, TCIDPK, TCMedicalItem, TCMedicalItemTitle, COUNT(TCMedicalItem) numImmunizations 
		FROM @tblReceivedImmunizations 
		WHERE Cohort = 18
		GROUP BY HVCasePK, TCIDPK, TCMedicalItem, TCMedicalItemTitle

	INSERT INTO @tblNumImmunizations6Month
		SELECT HVCasePK, TCIDPK, SUM(NumImmunizationsReceived) numImmunizationsReceived 
		FROM @tblReceivedImmunizations6Month 
		GROUP BY HVCasePK, TCIDPK

	INSERT INTO @tblNumImmunizations18Month
		SELECT HVCasePK, TCIDPK, SUM(NumImmunizationsReceived) numImmunizationsReceived 
		FROM @tblReceivedImmunizations18Month 
		GROUP BY HVCasePK, TCIDPK

	INSERT INTO @tblMeeting6Month
		SELECT req.HVCasePK, req.TCIDPK, CASE WHEN rec.NumImmunizationsReceived IS NULL OR rec.NumImmunizationsReceived < req.NumImmunizationsRequired THEN RTRIM(ScheduledEvent) + ' Missing' ELSE 'Meeting' END AS Meeting
		FROM
		@tblRequiredImmunizations6Month req
		LEFT JOIN 
		@tblReceivedImmunizations6Month rec
		ON req.HVCasePK = rec.HVCasePK AND req.TCIDPK = rec.TCIDPK AND MedicalItemCode = TCMedicalItem

	INSERT INTO @tblMeeting18Month
		SELECT req.HVCasePK, req.TCIDPK, CASE WHEN rec.NumImmunizationsReceived IS NULL OR rec.NumImmunizationsReceived < req.NumImmunizationsRequired THEN RTRIM(ScheduledEvent) + ' Missing' ELSE 'Meeting' END AS Meeting
		FROM
		@tblRequiredImmunizations18Month req
		LEFT JOIN 
		@tblReceivedImmunizations18Month rec
		ON req.HVCasePK = rec.HVCasePK AND req.TCIDPK = rec.TCIDPK AND MedicalItemCode = TCMedicalItem

	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDPK, STUFF((SELECT NULLIF(', ' + Meeting, ', Meeting') AS [text()] FROM @tblMeeting6Month mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.TCIDPK = mt2.TCIDPK FOR XML PATH('')), 1, 2, ''), 6 
		FROM @tblMeeting6Month mt2

	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDPK, STUFF((SELECT NULLIF(', ' + Meeting, ', Meeting') AS [text()] FROM @tblMeeting18Month mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.TCIDPK = mt2.TCIDPK FOR XML PATH('')), 1, 2, ''), 18
		FROM @tblMeeting18Month mt2

	/* 
	====== UNCOMMENT THESE INSERTS WHEN ON AZURE OR ANY SQL SERVER VERSION OVER 17 AND REMOVE THE SIMILAR INSERTS ABOVE ^ ======
	
	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDPK, STRING_AGG(NULLIF(mt.Meeting, 'Meeting'), ', ') AS meeting, 6
		FROM @tblMeeting6Month mt
		GROUP BY mt.HVCasePK, mt.TCIDPK

	INSERT INTO @tblMeetingReason
		SELECT HVCasePK, TCIDPK, STRING_AGG(NULLIF(mt.Meeting, 'Meeting'), ', ') AS meeting, 18
		FROM @tblMeeting18Month mt
		GROUP BY mt.HVCasePK, mt.TCIDPK
	*/

	INSERT INTO @tblCreativeOutreachDates
		SELECT coh.HVCasePK, hvl.StartLevelDate, hvl.EndLevelDate, 6
		FROM @tblCohort6Month coh
		INNER JOIN dbo.HVLevelDetail hvl ON coh.HVCasePK = hvl.HVCaseFK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on hvl.ProgramFK = listitem
		WHERE hvl.LevelFK BETWEEN 22 AND 29

	INSERT INTO @tblCreativeOutreachDates
		SELECT coh.HVCasePK, hvl.StartLevelDate, hvl.EndLevelDate, 18
		FROM @tblCohort18Month coh
		INNER JOIN dbo.HVLevelDetail hvl ON coh.HVCasePK = hvl.HVCaseFK
		INNER JOIN dbo.SplitString(@ProgramFK,',') on hvl.ProgramFK = listitem
		WHERE hvl.LevelFK BETWEEN 22 AND 29

	INSERT INTO @tblCreativeOutreachDatesCombined
		SELECT DISTINCT mt2.HVCasePK, STUFF((SELECT ' | ' + CONVERT(VARCHAR(10), mt.StartDate, 101) + ' - ' + CONVERT(VARCHAR(10), mt.EndDate, 101) AS [text()] FROM @tblCreativeOutreachDates mt WHERE mt.HVCasePK = mt2.HVCasePK AND mt.Cohort = mt2.Cohort FOR XML PATH('')), 1, 3, ''), mt2.Cohort
		FROM @tblCreativeOutreachDates mt2

	/* 
	====== UNCOMMENT THIS INSERT WHEN ON AZURE OR ANY SQL SERVER VERSION OVER 17 AND REMOVE THE SIMILAR INSERT ABOVE ^ ======

	INSERT INTO @tblCreativeOutreachDatesCombined
		SELECT DISTINCT mt.HVCasePK, STRING_AGG(CONVERT(VARCHAR(10), mt.StartDate, 101) + ' - ' + CONVERT(VARCHAR(10), mt.EndDate, 101), ' | ') AS dates, mt.Cohort
		FROM @tblCreativeOutreachDates mt
		GROUP BY mt.HVCasePK, mt.Cohort
	*/

	--Insert the 6 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, Cohort, PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB,  TCAgeMonths, TCName, NumShotsReceived, Meeting, ReasonNotMeeting, Exempt, CreativeOutreachDates)
		SELECT DISTINCT coh.HVCasePK, 6, coh.PC1ID, HomeVisitorName, IntakeDate, reason.TCIDPK, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName, ISNULL(imm.NumImmunizationsReceived, 0), CASE WHEN reason.Meeting IS NULL THEN 'Yes' ELSE 'No' END AS Meeting, reason.Meeting, coh.Exempt, levelx.Dates
		FROM @tblCohort6Month coh
		INNER JOIN @tblMeetingReason reason ON reason.HVCasePK = coh.HVCasePK AND reason.TCIDPK = coh.TCIDPK AND reason.GroupNum = 6
		LEFT JOIN @tblNumImmunizations6Month imm ON imm.HVCasePK = coh.HVCasePK AND imm.TCIDPK = coh.TCIDPK
		LEFT JOIN @tblCreativeOutreachDatesCombined levelx ON levelx.HVCasePK = coh.HVCasePK AND levelx.Cohort = 6

	--Insert the 18 month cohort into the results table
	INSERT INTO @tblResults
		(HVCasePK, Cohort, PC1ID, HomeVisitorName, IntakeDate, TCIDPK, TCDOB,  TCAgeMonths, TCName, NumShotsReceived, Meeting, ReasonNotMeeting, Exempt, CreativeOutreachDates)
		SELECT DISTINCT coh.HVCasePK, 18, coh.PC1ID, HomeVisitorName, IntakeDate, reason.TCIDPK, TCDOB, DATEDIFF(M, TCDOB, @PointInTime) TCAgeMonths, TCName, ISNULL(imm.NumImmunizationsReceived, 0), CASE WHEN reason.Meeting IS NULL THEN 'Yes' ELSE 'No' END AS Meeting, reason.Meeting, coh.Exempt, levelx.Dates
		FROM @tblCohort18Month coh
		INNER JOIN @tblMeetingReason reason ON reason.HVCasePK = coh.HVCasePK AND reason.TCIDPK = coh.TCIDPK AND reason.GroupNum = 18
		LEFT JOIN @tblNumImmunizations18Month imm ON imm.HVCasePK = coh.HVCasePK AND imm.TCIDPK = coh.TCIDPK
		LEFT JOIN @tblCreativeOutreachDatesCombined levelx ON levelx.HVCasePK = coh.HVCasePK AND levelx.Cohort = 18	

	--Record the number of exceptions for each cohort
	SET @NumExceptions6Month = (SELECT ISNULL(COUNT(HVCasePK), 0) FROM @tblCohort6Month WHERE Exempt = 1)
	SET @NumExceptions18Month = (SELECT ISNULL(COUNT(HVCasePK), 0) FROM @tblCohort18Month WHERE Exempt = 1)
	
	--Update the number of shots required
	UPDATE @tblResults SET NumShotsRequired = (SELECT SUM(NumRequired) 
		FROM @ImmunizationCount6Month) --Get the required number of immunizations for one case
		WHERE Cohort = 6
	UPDATE @tblResults SET NumShotsRequired = (SELECT SUM(NumRequired) 
		FROM @ImmunizationCount18Month) 
		WHERE Cohort = 18

	--Update exempt cases
	UPDATE @tblResults SET Meeting = 'N/A', NumShotsRequired = 0, ReasonNotMeeting = 'Exempt' WHERE Exempt = 1

	--Update the number of exceptions in the results table
	UPDATE @tblResults SET HFNumExceptions6Month = @NumExceptions6Month
	UPDATE @tblResults SET HFNumExceptions18Month = @NumExceptions18Month

	--Update the number of cases due for immunizations
	SET @NumDue6Month = (SELECT COUNT(*) FROM @tblResults WHERE Cohort = 6)
	SET @NumDue18Month = (SELECT COUNT(*) FROM @tblResults WHERE Cohort = 18)
	UPDATE @tblResults SET HFNumDueFor6Month = @NumDue6Month
	UPDATE @tblResults SET HFNumDueFor18Month = @NumDue18Month

	--Update the number of cases that received all immunizations
	UPDATE @tblResults SET HFNumReceived6Month = (SELECT COUNT(*) FROM @tblResults WHERE Meeting = 'Yes' AND Cohort = 6)
	UPDATE @tblResults SET HFNumReceived18Month = (SELECT COUNT(*) FROM @tblResults WHERE Meeting = 'Yes' AND Cohort = 18)
	
	--Update the percent of cases that meet
	UPDATE @tblResults SET HFPercentMeeting6Month = CONVERT(DECIMAL(4,2), (CONVERT(DECIMAL, HFNumReceived6Month) /  NULLIF((@NumDue6Month - @NumExceptions6Month), 0)))
	UPDATE @tblResults SET HFPercentMeeting18Month = CONVERT(DECIMAL(4,2), (CONVERT(DECIMAL, HFNumReceived18Month) / NULLIF((@NumDue18Month - @NumExceptions18Month), 0)))

	--Update the scores for the program
	UPDATE @tblResults SET HFScore6Month = CASE WHEN HFPercentMeeting6Month >= 0.90 THEN '3' 
												WHEN HFPercentMeeting6Month < 0.90 AND HFPercentMeeting6Month >= 0.80 THEN '2'
												WHEN HFPercentMeeting6Month < 0.80 THEN '1'
												ELSE 'E'
												END
	UPDATE @tblResults SET HFScore18Month = CASE WHEN HFPercentMeeting18Month >= 0.90 THEN '3' 
												WHEN HFPercentMeeting18Month < 0.90 AND HFPercentMeeting18Month >= 0.80 THEN '2'
												WHEN HFPercentMeeting18Month < 0.80 THEN '1'
												ELSE 'E'
												END

	--Get all the results
	SELECT * FROM @tblResults ORDER BY Cohort, HomeVisitorName, TCName
END
GO
