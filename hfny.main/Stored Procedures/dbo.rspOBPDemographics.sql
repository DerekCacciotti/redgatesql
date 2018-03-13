SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 3/13/18
-- Description:	This report stored procedure is used to populate the OBP Demographics Report
-- =============================================
CREATE PROCEDURE [dbo].[rspOBPDemographics]
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
		HVCasePK INT,
		CommonAttributesPK INT,
		FormDate DATETIME,
		IntakeDate DATETIME,
		OBPInHomeIntake BIT,
		DischargeDate DATETIME,
		OBPInvolvement CHAR(2)
	)

	DECLARE @tblInvolvedOBPs TABLE (
		HVCasePK INT
	)

	DECLARE @tblNotInvolvedOBPs TABLE (
		HVCasePK INT
	)

	DECLARE @tblDadInfo TABLE (
		HVCasePK INT,
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
		HVCasePK INT,
		TCDOB DATETIME,
		EDC DATETIME
	)

	DECLARE @tblOBPInfo TABLE (
		HVCasePK INT,
		OBPPK INT,
		OBPDOB DATETIME,
		OBPInHome CHAR(1),
		OBPInHomeIntake BIT,
		Race CHAR(2),
		MaritalStatus CHAR(2),
		HighestGrade CHAR(2),
		EducationalEnrollment CHAR(1),
		IsCurrentlyEmployed CHAR(1),
		DomesticViolence CHAR(1),
		DadScore CHAR(3),
		TCDOB DATETIME,
		EDC DATETIME,
		OBPAgeAtTCBirth INT
	)

	DECLARE @tblInvolvedOBPInfo TABLE (
		HVCasePK INT,
		OBPPK INT,
		OBPDOB DATETIME,
		OBPInHome CHAR(1),
		OBPInHomeIntake BIT,
		Race CHAR(2),
		MaritalStatus CHAR(2),
		HighestGrade CHAR(2),
		EducationalEnrollment CHAR(1),
		IsCurrentlyEmployed CHAR(1),
		DomesticViolence CHAR(1),
		DadScore CHAR(3),
		TCDOB DATETIME,
		EDC DATETIME,
		OBPAgeAtTCBirth INT
	)

	DECLARE @tblNotInvolvedOBPInfo TABLE (
		HVCasePK INT,
		OBPPK INT,
		OBPDOB DATETIME,
		OBPInHome CHAR(1),
		OBPInHomeIntake BIT,
		Race CHAR(2),
		MaritalStatus CHAR(2),
		HighestGrade CHAR(2),
		EducationalEnrollment CHAR(1),
		IsCurrentlyEmployed CHAR(1),
		DomesticViolence CHAR(1),
		DadScore CHAR(3),
		TCDOB DATETIME,
		EDC DATETIME,
		OBPAgeAtTCBirth INT
	)

	--Get the main cohort
	INSERT INTO @tblMainCohort
		SELECT h.HVCasePK, MAX(cp.CaseProgramPK)
		FROM dbo.HVCase h 
		INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
		WHERE h.IntakeDate BETWEEN @StartDate AND @EndDate
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
		SELECT di.HVCasePK, ca.CommonAttributesPK, ca.FormDate, di.IntakeDate, di.OBPInHomeIntake, cp.DischargeDate, ca.OBPInvolvement
		FROM @tblDadInfo di
		INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = di.HVCasePK			
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
		LEFT JOIN dbo.CommonAttributes ca ON  ca.CommonAttributesPK = 
												(SELECT TOP 1 CommonAttributesPK 
												FROM dbo.CommonAttributes ca2 			
												INNER JOIN dbo.SplitString(@ProgramFK, ',') ON ca2.ProgramFK = ListItem
												WHERE ca2.HVCaseFK = di.HVCasePK AND (ca2.FormType = 'FU' OR ca2.FormType = 'IN')
												ORDER BY ca2.FormDate DESC)
		WHERE OBPGender = '02' AND OBPRelationToTC = '01'

	--Get all the cases with resident OBPs at intake
	INSERT INTO @tblInvolvedOBPs
		SELECT sc.HVCasePK
			FROM @tblSecondaryCohort sc
			WHERE sc.OBPInvolvement IN ('01', '02', '03')
	
	--Get all the cases with non-resident OBPs at intake
	INSERT INTO @tblNotInvolvedOBPs
		SELECT sc.HVCasePK
			FROM @tblSecondaryCohort sc
			WHERE sc.OBPInvolvement IN ('04', '05', '06', '') OR sc.OBPInvolvement IS NULL

	--Case and Kempe info for second cohort
	INSERT INTO @tblHVCaseInfo
		SELECT sc.HVCasePK, hc.TCDOB, hc.EDC
		FROM @tblSecondaryCohort sc
		INNER JOIN dbo.HVCase hc ON hc.HVCasePK = sc.HVCasePK

	--All OBP info
	INSERT INTO @tblOBPInfo
	SELECT c.HVCasePK, obp.PCPK, obp.PCDOB, ca.OBPInHome, c.OBPinHomeIntake, obp.Race, ca.MaritalStatus, ca.HighestGrade,
		ca.EducationalEnrollment, ca.IsCurrentlyEmployed, i.DomesticViolence, k.DadScore, c.TCDOB, c.EDC,
		(CONVERT(INT,CONVERT(CHAR(8),ISNULL(TCDOB, EDC),112))-CONVERT(char(8),obp.PCDOB,112))/10000 AS OBPAgeAtTCBirth
		FROM @tblSecondaryCohort sc
		INNER JOIN dbo.HVCase c ON c.HVCasePK = sc.HVCasePK
		INNER JOIN dbo.Kempe k ON k.HVCaseFK = c.HVCasePK
		INNER JOIN dbo.PC obp ON obp.PCPK = c.OBPFK
		LEFT JOIN dbo.PC1Issues i ON i.HVCaseFK = c.HVCasePK
		LEFT JOIN dbo.CommonAttributes ca ON  ca.CommonAttributesPK = 
												(SELECT TOP 1 CommonAttributesPK 
												FROM dbo.CommonAttributes ca2 			
												INNER JOIN dbo.SplitString(@ProgramFK, ',') ON ca2.ProgramFK = ListItem
												WHERE ca2.HVCaseFK = c.HVCasePK AND (ca2.FormType = 'FU-OBP')
												ORDER BY ca2.FormDate DESC)

	INSERT INTO @tblInvolvedOBPInfo
	SELECT obp.HVCasePK, obp.OBPPK, obp.OBPDOB, obp.OBPInHome, obp.OBPInHomeIntake,
           obp.Race, obp.MaritalStatus, obp.HighestGrade, obp.EducationalEnrollment,
           obp.IsCurrentlyEmployed, obp.DomesticViolence, obp.DadScore, obp.TCDOB, obp.EDC, obp.OBPAgeAtTCBirth
		   FROM @tblOBPInfo obp 
		   INNER JOIN @tblInvolvedOBPs i ON i.HVCasePK = obp.HVCasePK

	INSERT INTO @tblNotInvolvedOBPInfo
	SELECT obp.HVCasePK, obp.OBPPK, obp.OBPDOB, obp.OBPInHome, obp.OBPInHomeIntake,
           obp.Race, obp.MaritalStatus, obp.HighestGrade, obp.EducationalEnrollment,
           obp.IsCurrentlyEmployed, obp.DomesticViolence, obp.DadScore, obp.TCDOB, obp.EDC, obp.OBPAgeAtTCBirth
		   FROM @tblOBPInfo obp 
		   INNER JOIN @tblNotInvolvedOBPs ni ON ni.HVCasePK = obp.HVCasePK

	--Get cases and number of postnatal home visits from the second cohort home visit table where the OBP participated
	;WITH cteMoreThan10PostnatalHVLogs AS (
		--Will be filtered by number of postnatal home visits (NumVisits >= 10)
		SELECT hc.HVCasePK, COUNT(DISTINCT hl.HVLogPK) NumVisits
			FROM @tblHVCaseInfo hc
			INNER JOIN HVLog hl ON hl.HVCaseFK = hc.HVCasePK
			--May need to join on programFK (TBD)
			WHERE hl.VisitStartTime > CASE WHEN hc.TCDOB IS NULL THEN hc.EDC ELSE hc.TCDOB END
			AND hl.OBPParticipated = 1
			GROUP BY hc.HVCasePK
	)

	--Get the results from the tables and CTEs
	 ,cteResults AS (
	 SELECT
		--ACTIVE IN PERIOD SECTION
		COUNT(c.HVCasePK) AS TotalActiveCases
		, SUM(CASE WHEN d.PC1Gender = '02' AND d.PC1RelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsPC1
		, SUM(CASE WHEN d.OBPGender = '02' AND d.OBPRelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsOBP
		, SUM(CASE WHEN d.OBPGender = '02' AND d.OBPRelationToTC IS NULL THEN 1 ELSE 0 END) AS NumDadsOther
		--DADS AS OBPS, ACTIVE IN PERIOD: INVOLVEMENT AS OF INTAKE/LAST FU SECTION
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '01') AS NumFinanciallyInvolved
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '02') AS NumEmotionallyInvolved
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '03') AS NumFinanciallyAndEmotionallyInvolved
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '04') AS NumNotInvolved
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '05') AS NumDoesNotKnow
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '06' OR sc.OBPInvolvement IS NULL) AS NumOtherMissing
		, (SELECT COUNT(sc.HVCasePK) FROM @tblSecondaryCohort sc WHERE sc.OBPInvolvement = '07') AS NumDeceased
		--DADS AS OBPS, ACTIVE IN PERIOD, NOT DECEASED: ANSWERS AS OF INTAKE/LAST FU SECTION
		, (SELECT COUNT(io.HVCasePK) FROM @tblInvolvedOBPs io) AS NumTotalInvolved
		, (SELECT COUNT(nio.HVCasePK) FROM @tblNotInvolvedOBPs nio) AS NumTotalNotInvolved
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) = 1) AS NumInvolvedResident
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) = 1) AS NumNotInvolvedResident
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) = 0) AS NumInvolvedNotResident
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) = 0) AS NumNotInvolvedNotResident
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) IS NULL) AS NumInvolvedUnknown
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE ISNULL(CONVERT(BIT, obp.OBPInHome), obp.OBPInHomeIntake) IS NULL) AS NumNotInvolvedUnknown
		--Involved OBPs age at TC's birth
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth < 19) AS NumInvolvedUnder19
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 19 AND obp.OBPAgeAtTCBirth < 21) AS NumInvolved19To21
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 21 AND obp.OBPAgeAtTCBirth < 25) AS NumInvolved21To25
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 25 AND obp.OBPAgeAtTCBirth < 30) AS NumInvolved25To30
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 30 AND obp.OBPAgeAtTCBirth < 35) AS NumInvolved30To35
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 35 AND obp.OBPAgeAtTCBirth < 40) AS NumInvolved35To40
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 40) AS NumInvolvedOver40
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.OBPDOB IS NULL) AS NumInvolvedAgeUnknown
		--Not Involved OBPs age at TC's birth
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth < 19) AS NumNotInvolvedUnder19
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 19 AND obp.OBPAgeAtTCBirth < 21) AS NumNotInvolved19To21
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 21 AND obp.OBPAgeAtTCBirth < 25) AS NumNotInvolved21To25
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 25 AND obp.OBPAgeAtTCBirth < 30) AS NumNotInvolved25To30
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 30 AND obp.OBPAgeAtTCBirth < 35) AS NumNotInvolved30To35
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 35 AND obp.OBPAgeAtTCBirth < 40) AS NumNotInvolved35To40
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPAgeAtTCBirth >= 40) AS NumNotInvolvedOver40
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.OBPDOB IS NULL) AS NumNotInvolvedAgeUnknown
		--Involved OBPs race
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '01') AS NumInvolvedWhite
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '02') AS NumInvolvedBlack
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '03') AS NumInvolvedHispanic
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '04') AS NumInvolvedAsian
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '05') AS NumInvolvedNativeAmerican
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '06') AS NumInvolvedMultiracial
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race = '07') AS NumInvolvedOtherRace
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.Race IS NULL) AS NumInvolvedUnknownRace
		--Not Involved OBPs race
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '01') AS NumNotInvolvedWhite
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '02') AS NumNotInvolvedBlack
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '03') AS NumNotInvolvedHispanic
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '04') AS NumNotInvolvedAsian
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '05') AS NumNotInvolvedNativeAmerican
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '06') AS NumNotInvolvedMultiracial
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race = '07') AS NumNotInvolvedOtherRace
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.Race IS NULL) AS NumNotInvolvedUnknownRace
		--Involved OBPs marital status
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.MaritalStatus = '01') AS NumInvolvedMarried
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.MaritalStatus = '02') AS NumInvolvedNotMarried
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.MaritalStatus IN ('03', '04', '05')) AS NumInvolvedSeperated
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.MaritalStatus IS NULL) AS NumInvolvedUnknownMaritalStatus
		--Not Involved OBPs marital status
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.MaritalStatus = '01') AS NumNotInvolvedMarried
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.MaritalStatus = '02') AS NumNotInvolvedNotMarried
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.MaritalStatus IN ('03', '04', '05')) AS NumNotInvolvedSeperated
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.MaritalStatus IS NULL) AS NumNotInvolvedUnknownMaritalStatus
		--Involved OBPs education
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade IN('01', '02')) AS NumInvolvedLessThanHighSchool
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade IN('03', '04')) AS NumInvolvedGED
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade = '05') AS NumInvolvedVocational
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade IN('06', '07')) AS NumInvolvedAssociates
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade = '08') AS NumInvolvedBachelors
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.HighestGrade IS NULL) AS NumInvolvedUnknownEducation
		--Not Involved OBPs education
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade IN('01', '02')) AS NumNotInvolvedLessThanHighSchool
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade IN('03', '04')) AS NumNotInvolvedGED
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade = '05') AS NumNotInvolvedVocational
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade IN('06', '07')) AS NumNotInvolvedAssociates
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade = '08') AS NumNotInvolvedBachelors
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.HighestGrade IS NULL) AS NumNotInvolvedUnknownEducation
		--Involved OBPs Enrolled In Education
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.EducationalEnrollment = '1') AS NumInvolvedEnrolledEducation
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.EducationalEnrollment = '0') AS NumInvolvedNotEnrolledEducation
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.EducationalEnrollment IS NULL) AS NumInvolvedUnknownEnrolledEducation
		--Not Involved OBPs Enrolled In Education
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.EducationalEnrollment = '1') AS NumNotInvolvedEnrolledEducation
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.EducationalEnrollment = '0') AS NumNotInvolvedNotEnrolledEducation
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.EducationalEnrollment IS NULL) AS NumNotInvolvedUnknownEnrolledEducation
		--Involved OBPs Employed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed = '1') AS NumInvolvedEmployed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed = '0') AS NumInvolvedNotEmployed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed IS NULL) AS NumInvolvedUnknownEmployed
		--Not Involved OBPs Employed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed = '1') AS NumNotInvolvedEmployed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed = '0') AS NumNotInvolvedNotEmployed
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.IsCurrentlyEmployed IS NULL) AS NumNotInvolvedUnknownEmployed
		--Involved OBPs Domestic Violence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.DomesticViolence = '1') AS NumInvolvedDomesticViolence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.DomesticViolence = '0') AS NumInvolvedNoDomesticViolence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE obp.DomesticViolence IS NULL) AS NumInvolvedUnknownDomesticViolence
		--Involved OBPs Domestic Violence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.DomesticViolence = '1') AS NumNotInvolvedDomesticViolence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.DomesticViolence = '0') AS NumNotInvolvedNoDomesticViolence
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE obp.DomesticViolence IS NULL) AS NumNotInvolvedUnknownDomesticViolence
		--Involved OBPs Kempe Score
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) >= 25) AS NumInvolvedPositiveOBPKempe
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) < 25) AS NumInvolvedNegativeOBPKempe
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) IS NULL) AS NumInvolvedUnknownOBPKempe
		--Not Involved OBPs Kempe Score
		--Kempe cutoff is currently 25 (as of 3/6/18)
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) >= 25) AS NumNotInvolvedPositiveOBPKempe
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) < 25) AS NumNotInvolvedNegativeOBPKempe
		, (SELECT COUNT(DISTINCT obp.HVCasePK) FROM @tblNotInvolvedOBPInfo obp WHERE CONVERT(INT, obp.DadScore) IS NULL) AS NumNotInvolvedUnknownOBPKempe
		--Present at 10+ postnatal HVs
		, (SELECT COUNT(io.HVCasePK) FROM cteMoreThan10PostnatalHVLogs tphl INNER JOIN @tblInvolvedOBPs io ON io.HVCasePK = tphl.HVCasePK WHERE tphl.NumVisits >= 10) AS NumResident10PostnatalVisits
		, (SELECT COUNT(nio.HVCasePK) FROM cteMoreThan10PostnatalHVLogs tphl INNER JOIN @tblNotInvolvedOBPs nio ON nio.HVCasePK = tphl.HVCasePK WHERE tphl.NumVisits >= 10) AS NumNonResident10PostnatalVisits
		FROM @tblMainCohort c
		LEFT JOIN @tblDadInfo d ON d.HVCasePK = c.HVCasePK
	)

	SELECT * FROM cteResults
END
GO
