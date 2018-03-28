SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 3/6/18
-- Description:	This report stored procedure is used to populate the OBP Engagement Report
-- =============================================
CREATE PROCEDURE [dbo].[rspOBPEngagement]
	@ProgramFK	VARCHAR(MAX) = NULL,
	@StartDate	DATETIME = NULL,
	@EndDate	DATETIME = NULL
AS
BEGIN
		
--Set the ProgramFK
	IF @ProgramFK IS NULL
	BEGIN
		SELECT @ProgramFK = SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
											FROM HVProgram
											FOR XML PATH ('')),2,8000);
	END
	SET @ProgramFK = REPLACE(@ProgramFK,'"','')

	--Declare the necessary tables
	 DECLARE @tblMainCohort TABLE (
		HVCasePK INT,
		CaseProgramPK INT
	)

	DECLARE @tblSecondaryCohort TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		CommonAttributesPK INT,
		FormDate DATETIME,
		OBPInHome CHAR(1),
		IntakeDate DATETIME,
		OBPInHomeIntake BIT,
		DischargeDate DATETIME
	)

	DECLARE @tblResidentOBPs TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED
	)

	DECLARE @tblNonResidentOBPs TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED
	)

	DECLARE @tblDadInfo TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		OBPInHomeIntake BIT,
		IntakeDate DATETIME,
		PC1PK INT,
		PC1Gender CHAR(2),
		PC1RelationToTC CHAR(2),
		OBPPK INT,
		OBPGender CHAR(2),
		OBPRelationToTC CHAR(2)
	)

	DECLARE @tblHVCaseInfo TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		TCDOB DATETIME,
		EDC DATETIME,
		FOBPresent BIT,
		DischargeDate DATETIME
	)

	DECLARE @tblHVLog TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		HVLogPK INT,
		VisitStartTime DATETIME,
		OBPParticipated BIT
	)

	DECLARE @tblServiceReferral TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		ServiceReferralPK INT,
		FamilyCode CHAR(2),
		ServiceCode INT
	)

	DECLARE @tblResidentOBPsServiceReferral TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		ServiceReferralPK INT,
		FamilyCode CHAR(2),
		ServiceCode INT
	)

	DECLARE @tblNonResidentOBPsServiceReferral TABLE (
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		ServiceReferralPK INT,
		FamilyCode CHAR(2),
		ServiceCode INT
	)

	DECLARE @tblFirstHVLogInfo TABLE
	(
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		OBPParticipated BIT,
		VisitStartTime DATETIME,
		RowNum INT
	)

	DECLARE @tblPrenatalHVLogsInfo TABLE
	(
		HVCasePK INT INDEX ixHVCasePK CLUSTERED
	)

	DECLARE @tblPostnatalHVLogsInfo TABLE
	(
		HVCasePK INT INDEX ixHVCasePK CLUSTERED
	)

	DECLARE @tblDischargeHVLogInfo TABLE
	(
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		OBPParticipated BIT,
		VisitStartTime DATETIME,
		RowNum INT
	)

	DECLARE @tblMoreThan10PostnatalHVLogs TABLE
	(
		HVCasePK INT INDEX ixHVCasePK CLUSTERED,
		NumVisits INT
	)

	--Get the main cohort
	INSERT INTO @tblMainCohort
		SELECT h.HVCasePK, MAX(cp.CaseProgramPK)
		FROM dbo.HVCase h 
		INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
		WHERE h.IntakeDate <= @EndDate
		AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @StartDate)
		GROUP BY h.HVCasePK

	--Get the information about the PC and OBP
	INSERT INTO @tblDadInfo
		SELECT h.HVCasePK, h.OBPinHomeIntake, h.IntakeDate, pc.PCPK, pc.Gender, h.PC1Relation2TC, obp.PCPK, obp.Gender, h.OBPRelation2TC
		FROM @tblMainCohort c 
		INNER JOIN dbo.HVCase h ON c.HVCasePK = h.HVCasePK
		INNER JOIN dbo.PC pc ON pc.PCPK = h.PC1FK
		LEFT JOIN dbo.PC obp ON obp.PCPK = h.OBPFK

	--Get the 'Dads as OBPs, active in period, Residence as of Intake/Last FU' cohort
	INSERT INTO @tblSecondaryCohort
		SELECT di.HVCasePK, ca.CommonAttributesPK, ca.FormDate, ca.OBPInHome, di.IntakeDate, di.OBPInHomeIntake, cp.DischargeDate
		FROM @tblDadInfo di
		INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = di.HVCasePK			
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
		LEFT JOIN dbo.CommonAttributes ca ON  ca.CommonAttributesPK = 
												(SELECT TOP 1 CommonAttributesPK 
												FROM dbo.CommonAttributes ca2 			
												INNER JOIN dbo.SplitString(@ProgramFK, ',') ON ca2.ProgramFK = ListItem
												WHERE ca2.HVCaseFK = di.HVCasePK AND (ca2.FormType = 'FU-OBP' OR ca2.FormType = 'ID')
												ORDER BY ca2.FormDate DESC)
		WHERE (OBPGender = '02' AND OBPRelationToTC = '01') OR 
		((di.OBPRelationToTC IS NULL OR di.OBPGender = '') AND di.PC1Gender <> '02') --This allows cases that have unknown relationships with OBP to be counted

	--Get all the cases with resident OBPs at intake
	INSERT INTO @tblResidentOBPs
		SELECT sc.HVCasePK
			FROM @tblSecondaryCohort sc
			WHERE 
			CASE WHEN sc.CommonAttributesPK IS NOT NULL THEN
				sc.OBPInHome
			ELSE
				sc.OBPInHomeIntake
			END
			 =
			CASE WHEN sc.CommonAttributesPK IS NOT NULL THEN
				'1'
			ELSE
				1
			END
	
	--Get all the cases with non-resident OBPs at intake
	INSERT INTO @tblNonResidentOBPs
		SELECT sc.HVCasePK
			FROM @tblSecondaryCohort sc
			WHERE 
			CASE WHEN sc.CommonAttributesPK IS NOT NULL THEN
				ISNULL(sc.OBPInHome, '0')
			ELSE
				ISNULL(sc.OBPInHomeIntake, 0)
			END
			=
			CASE WHEN sc.CommonAttributesPK IS NOT NULL THEN
				'0'
			ELSE
				0
			END

	--HVLog info for second cohort
	INSERT INTO @tblHVLog
		SELECT sc.HVCasePK, hl.HVLogPK, hl.VisitStartTime, hl.OBPParticipated 
		FROM @tblSecondaryCohort sc
		INNER JOIN dbo.HVLog hl ON hl.HVCaseFK = sc.HVCasePK

	--Case and Kempe info for second cohort
	INSERT INTO @tblHVCaseInfo
		SELECT sc.HVCasePK, hc.TCDOB, hc.EDC, k.FOBPresent, sc.DischargeDate
		FROM @tblSecondaryCohort sc
		INNER JOIN dbo.HVCase hc ON hc.HVCasePK = sc.HVCasePK
		INNER JOIN dbo.Kempe k ON k.HVCaseFK = sc.HVCasePK

	--Service Referral info for second cohort
	INSERT INTO @tblServiceReferral
		SELECT sc.HVCasePK, sr.ServiceReferralPK, sr.FamilyCode, CONVERT(INT, ISNULL(sr.ServiceCode, 0))
		FROM @tblSecondaryCohort sc
		INNER JOIN dbo.ServiceReferral sr ON sr.HVCaseFK = sc.HVCasePK

	--Service Referral info for second cohort
	INSERT INTO @tblResidentOBPsServiceReferral
		SELECT sr.HVCasePK, sr.ServiceReferralPK, sr.FamilyCode, CONVERT(INT, ISNULL(sr.ServiceCode, 0))
		FROM @tblServiceReferral sr
		INNER JOIN @tblResidentOBPs ro ON sr.HVCasePK = ro.HVCasePK

	--Service Referral info for second cohort
	INSERT INTO @tblNonResidentOBPsServiceReferral
		SELECT sr.HVCasePK, sr.ServiceReferralPK, sr.FamilyCode, CONVERT(INT, ISNULL(sr.ServiceCode, 0))
		FROM @tblServiceReferral sr
		INNER JOIN @tblNonResidentOBPs nro ON sr.HVCasePK = nro.HVCasePK

	INSERT INTO @tblFirstHVLogInfo
	--Get the first HVLog for each case by checking if RowNum = 1
		SELECT hl.HVCasePK, hl.OBPParticipated, hl.VisitStartTime, 
			ROW_NUMBER() OVER (PARTITION BY hl.HVCasePK ORDER BY hl.VisitStartTime ASC) AS RowNum
			FROM @tblHVLog hl
	
	--Get all the cases in the second cohort with prenatal home visits where the OBP participated
	INSERT INTO @tblPrenatalHVLogsInfo
		SELECT DISTINCT hc.HVCasePK
			FROM @tblHVCaseInfo hc
			INNER JOIN @tblHVLog hl ON hl.HVCasePK = hc.HVCasePK
			WHERE hl.VisitStartTime < CASE WHEN hc.TCDOB IS NULL THEN hc.EDC ELSE hc.TCDOB END
            AND hl.OBPParticipated = 1
			AND hl.VisitStartTime < @EndDate

	--Get all the cases in the second cohort with postnatal home visits where the OBP participated
	INSERT INTO @tblPostnatalHVLogsInfo
		SELECT DISTINCT hc.HVCasePK
			FROM @tblHVCaseInfo hc
			INNER JOIN @tblHVLog hl ON hl.HVCasePK = hc.HVCasePK
			WHERE hl.VisitStartTime > CASE WHEN hc.TCDOB IS NULL THEN hc.EDC ELSE hc.TCDOB END
            AND hl.OBPParticipated = 1
			AND hl.VisitStartTime < @EndDate
			
	--Get the home visits for cases with a discharge date
	INSERT INTO @tblDischargeHVLogInfo
		--Will be filtered by only taking the newest home visit (RowNum = 1)
		SELECT hl.HVCasePK, hl.OBPParticipated, hl.VisitStartTime, 
			ROW_NUMBER() OVER (PARTITION BY hl.HVCasePK ORDER BY hl.VisitStartTime DESC) AS RowNum
			FROM @tblHVCaseInfo hc
			INNER JOIN @tblHVLog hl ON hl.HVCasePK = hc.HVCasePK
			WHERE hc.DischargeDate IS NOT NULL
			AND hl.VisitStartTime < @EndDate
			
	--Get cases and number of postnatal home visits from the second cohort home visit table where the OBP participated
	INSERT INTO @tblMoreThan10PostnatalHVLogs
		--Will be filtered by number of postnatal home visits (NumVisits >= 10)
		SELECT hc.HVCasePK, COUNT(DISTINCT hl.HVLogPK) NumVisits
			FROM @tblHVCaseInfo hc
			INNER JOIN @tblHVLog hl ON hl.HVCasePK = hc.HVCasePK
			WHERE hl.VisitStartTime > CASE WHEN hc.TCDOB IS NULL THEN hc.EDC ELSE hc.TCDOB END
			AND hl.OBPParticipated = 1
			AND hl.VisitStartTime < @EndDate
			GROUP BY hc.HVCasePK

			;with
	--Get the results from the tables and CTEs
	 cteResults AS (
	 SELECT
		--ACTIVE IN PERIOD SECTION
		COUNT(c.HVCasePK) AS TotalActiveCases
		, SUM(CASE WHEN d.PC1Gender = '02' AND d.PC1RelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsPC1
		, SUM(CASE WHEN d.OBPGender = '02' AND d.OBPRelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsOBP
		, SUM(CASE WHEN (d.OBPRelationToTC IS NULL OR d.OBPGender = '') AND d.PC1Gender <> '02' THEN 1 ELSE 0 END) AS NumDadsOther
		--DADS AS OBPS, ACTIVE IN PERIOD.... SECTION
		, (SELECT COUNT(ro.HVCasePK) FROM @tblResidentOBPs ro) AS NumResidentOBPs
		, (SELECT COUNT(nro.HVCasePK) FROM @tblNonResidentOBPs nro) AS NumNonResidentOBPs
		, (SELECT COUNT(ci.HVCasePK) AS NumPresentAssessment FROM @tblHVCaseInfo ci INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = ci.HVCasePK WHERE ci.FOBPresent = 1) AS NumResidentPresentAssessment
		, (SELECT COUNT(ci.HVCasePK) AS NumPresentAssessment FROM @tblHVCaseInfo ci INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = ci.HVCasePK WHERE ci.FOBPresent = 1) AS NumNonResidentPresentAssessment
		, (SELECT COUNT(ro.HVCasePK) FROM @tblFirstHVLogInfo fv INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = fv.HVCasePK WHERE fv.OBPParticipated = 1 AND fv.RowNum = 1) AS NumResidentPresentIntake
		, (SELECT COUNT(nro.HVCasePK) FROM @tblFirstHVLogInfo fv INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = fv.HVCasePK WHERE fv.OBPParticipated = 1 AND fv.RowNum = 1) AS NumNonResidentPresentIntake
		, (SELECT COUNT(ro.HVCasePK) FROM @tblPrenatalHVLogsInfo pv INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = pv.HVCasePK) AS NumResidentPrenatal
		, (SELECT COUNT(nro.HVCasePK) FROM @tblPrenatalHVLogsInfo pv INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = pv.HVCasePK) AS NumNonResidentPrenatal
		, (SELECT COUNT(ro.HVCasePK) FROM @tblPostnatalHVLogsInfo pv INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = pv.HVCasePK) AS NumResidentPostnatal
		, (SELECT COUNT(nro.HVCasePK) FROM @tblPostnatalHVLogsInfo pv INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = pv.HVCasePK) AS NumNonResidentPostnatal
		, (SELECT COUNT(ro.HVCasePK) FROM @tblDischargeHVLogInfo dhl INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = dhl.HVCasePK WHERE dhl.OBPParticipated = 1 AND dhl.RowNum = 1) AS NumResidentDischarge
		, (SELECT COUNT(nro.HVCasePK) FROM @tblDischargeHVLogInfo dhl INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = dhl.HVCasePK WHERE dhl.OBPParticipated = 1 AND dhl.RowNum = 1) AS NumNonResidentDischarge
		, (SELECT COUNT(ro.HVCasePK) FROM @tblMoreThan10PostnatalHVLogs tphl INNER JOIN @tblResidentOBPs ro ON ro.HVCasePK = tphl.HVCasePK WHERE tphl.NumVisits >= 10) AS NumResident10PostnatalVisits
		, (SELECT COUNT(nro.HVCasePK) FROM @tblMoreThan10PostnatalHVLogs tphl INNER JOIN @tblNonResidentOBPs nro ON nro.HVCasePK = tphl.HVCasePK WHERE tphl.NumVisits >= 10) AS NumNonResident10PostnatalVisits
		-- REFERRALS FOR OBPS SECTION
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03') AS NumResidentWithServiceReferrals
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblNonResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03') AS NumNonResidentWithServiceReferrals
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND (sr.ServiceCode >= 32 AND sr.ServiceCode <= 38)) AS NumResidentReferredParenting
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblNonResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND (sr.ServiceCode >= 32 AND sr.ServiceCode <= 38)) AS NumNonResidentReferredParenting
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND (sr.ServiceCode = 49 or sr.ServiceCode = 50)) AS NumResidentReferredMental
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblNonResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND (sr.ServiceCode = 49 or sr.ServiceCode = 50)) AS NumNonResidentReferredMental
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND sr.ServiceCode = 52) AS NumResidentReferredSubstance
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblNonResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND sr.ServiceCode = 52) AS NumNonResidentReferredSubstance
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND sr.ServiceCode IN (46,47,48)) AS NumResidentReferredEmployment
		, (SELECT COUNT(DISTINCT sr.HVCasePK) FROM @tblNonResidentOBPsServiceReferral sr WHERE sr.FamilyCode = '03' AND sr.ServiceCode IN (46,47,48)) AS NumNonResidentReferredEmployment
		FROM @tblMainCohort c
		LEFT JOIN @tblDadInfo d ON d.HVCasePK = c.HVCasePK
	)

	SELECT * FROM cteResults
END
GO
