SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 2/27/18
-- Description:	This report stored procedure is used to populate the OBP Documentation Report
-- =============================================
CREATE PROCEDURE [dbo].[rspOBPDocumentation]
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

	DECLARE @tblCohortDadsAsOBPs TABLE (
		HVCasePK INT
	)

	DECLARE @tblDadInfo TABLE (
		HVCasePK INT,
		PC1PK INT,
		PC1Gender CHAR(2),
		PC1RelationToTC CHAR(2),
		OBPPK INT,
		OBPGender CHAR(2),
		OBPRelationToTC CHAR(2)
	)

	DECLARE @tblSceenInfo TABLE (
		HVCasePK INT,
		HVScreenPK INT,
		ScreenDate DATETIME,
		FormType CHAR(8),
		OBPInHome CHAR(1),
		RiskNotMarried CHAR(1)
	)

	DECLARE @tblAssessmentInfo TABLE (
		HVCasePK INT,
		KempePK INT,
		FormDate DATETIME,
		FormType CHAR(8),
		OBPInHome CHAR(1),
		DadScore CHAR(3)
	)

	DECLARE @tblIntakeInfo TABLE (
		HVCasePK INT,
		IntakePK INT,
		IntakeDate DATETIME,
		FormDate DATETIME,
		FormType CHAR(8),
		OBPInformationAvailable BIT,
		OBPInHome CHAR(1),
		OBPInvolvement CHAR(2)
	)

	DECLARE @tblResults TABLE (
		TotalActiveCases INT,
		NumDadsAsPC1 INT,
		NumDadsAsOBP INT,
		NumDadsOther INT,
		NumScreensInPeriod INT,
		NumOBPInHomeScreen INT,
		NumPC1MaritalStatus INT,
		NumAssessmentsInPeriod INT,
		NumOBPInHomeAssessment INT,
		NumOBPWithKScore INT,
		NumIntakesInPeriod INT,
		NumOBPInHomeIntake INT,
		NumOBPInvolvement INT,
		NumOBPInfoAvailable INT,
		NumInappropriateMissing INT
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
		SELECT h.HVCasePK, pc.PCPK, pc.Gender, h.PC1Relation2TC, obp.PCPK, obp.Gender, h.OBPRelation2TC
		FROM @tblMainCohort c 
		INNER JOIN dbo.HVCase h ON c.HVCasePK = h.HVCasePK
		INNER JOIN dbo.PC pc ON pc.PCPK = h.PC1FK
		LEFT JOIN dbo.PC obp ON obp.PCPK = h.OBPFK

	--Get the 'Dads as OBPs, active in period' cohort
	INSERT INTO @tblCohortDadsAsOBPs
		SELECT HVCasePK
		FROM @tblDadInfo di
		WHERE (di.OBPGender = '02' AND di.OBPRelationToTC = '01') OR 
		((di.OBPRelationToTC IS NULL OR di.OBPGender = '') AND di.PC1Gender <> '02') --This allows cases that have unknown relationships with OBP to be counted

	--Get information about the Screens that relate to the above cohort
	INSERT INTO @tblSceenInfo
		SELECT h.HVCasePK, hs.HVScreenPK, h.ScreenDate, ca.FormType, ca.OBPInHome, hs.RiskNotMarried
		FROM @tblCohortDadsAsOBPs c
		INNER JOIN dbo.HVCase h ON c.HVCasePK = h.HVCasePK
		INNER JOIN dbo.HVScreen hs ON hs.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CommonAttributes ca ON ca.HVCaseFK = h.HVCasePK AND ca.FormFK = hs.HVScreenPK AND ca.FormType = 'SC'
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON ca.ProgramFK = ListItem
		WHERE h.ScreenDate BETWEEN @StartDate AND @EndDate 
	
	--Get information about the Assessments that relate to the above cohort
	INSERT INTO @tblAssessmentInfo
		SELECT h.HVCasePK, k.KempePK, ca.FormDate, ca.FormType, ca.OBPInHome, k.DadScore
		FROM @tblCohortDadsAsOBPs c
		INNER JOIN dbo.HVCase h ON c.HVCasePK = h.HVCasePK
		INNER JOIN dbo.Kempe k ON k.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CommonAttributes ca ON ca.HVCaseFK = h.HVCasePK AND ca.FormFK = k.KempePK AND ca.FormType = 'KE'
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON ca.ProgramFK = ListItem
		WHERE ca.FormDate BETWEEN @StartDate AND @EndDate

	--Get information about the Intakes that relate to the above cohort
	INSERT INTO @tblIntakeInfo
		SELECT h.HVCasePK, i.IntakePK, i.IntakeDate, intake.FormDate, intake.FormType, h.OBPInformationAvailable, id.OBPInHome, intake.OBPInvolvement
		FROM @tblCohortDadsAsOBPs c
		INNER JOIN dbo.HVCase h ON c.HVCasePK = h.HVCasePK
		INNER JOIN dbo.Intake i ON i.HVCaseFK = h.HVCasePK
		INNER JOIN dbo.CommonAttributes intake ON intake.HVCaseFK = h.HVCasePK AND intake.FormType = 'IN'
		INNER JOIN dbo.CommonAttributes id ON id.HVCaseFK = h.HVCasePK AND id.FormType = 'ID'
		INNER JOIN dbo.SplitString(@ProgramFK, ',') ON intake.ProgramFK = ListItem AND id.ProgramFK = ListItem
		WHERE intake.FormDate BETWEEN @StartDate AND @EndDate
		AND id.FormDate BETWEEN @StartDate AND @EndDate

	--Get the results
	INSERT INTO @tblResults
	SELECT
	COUNT(DISTINCT c.HVCasePK) AS TotalActiveCases
	, SUM(CASE WHEN d.PC1Gender = '02' AND d.PC1RelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsPC1
	, SUM(CASE WHEN d.OBPGender = '02' AND d.OBPRelationToTC = '01' THEN 1 ELSE 0 END) AS NumDadsAsOBP
	, SUM(CASE WHEN (d.OBPRelationToTC IS NULL OR d.OBPGender = '') AND d.PC1Gender <> '02' THEN 1 ELSE 0 END) AS NumDadsOther
	, SUM(CASE WHEN s.HVScreenPK IS NOT NULL THEN 1 ELSE 0 END) AS NumScreensInPeriod
	, SUM(CASE WHEN s.OBPInHome IS NOT NULL THEN 1 ELSE 0 END) AS NumOBPInHomeScreen
	, SUM(CASE WHEN s.RiskNotMarried IN ('1', '2') THEN 1 ELSE 0 END) AS NumPC1MaritalStatus
	, SUM(CASE WHEN a.KempePK IS NOT NULL THEN 1 ELSE 0 END) AS NumAssessmentsInPeriod
	, SUM(CASE WHEN a.OBPInHome IS NOT NULL THEN 1 ELSE 0 END) AS NumOBPInHomeAssessment
	, SUM(CASE WHEN a.DadScore <> '0' THEN 1 ELSE 0 END) AS NumOBPWithKScore
	, SUM(CASE WHEN i.IntakePK IS NOT NULL THEN 1 ELSE 0 END) AS NumIntakeInPeriod
	, SUM(CASE WHEN i.OBPInHome IS NOT NULL THEN 1 ELSE 0 END) AS NumOBPInHomeIntake
	, SUM(CASE WHEN i.OBPInvolvement IS NOT NULL AND i.OBPInvolvement <> '' THEN 1 ELSE 0 END) AS NumOBPInvolvement
	, SUM(CASE WHEN i.OBPInformationAvailable = 1 THEN 1 ELSE 0 END) AS NumOBPInfoAvailable
	, SUM(CASE WHEN i.OBPInvolvement IN ('01', '02', '03') AND (i.OBPInformationAvailable IS NULL OR i.OBPInformationAvailable = 0) THEN 1 ELSE 0 END) AS NumInappropriateMissing
	FROM @tblMainCohort c
	LEFT JOIN @tblDadInfo d ON d.HVCasePK = c.HVCasePK
	LEFT JOIN @tblSceenInfo s ON s.HVCasePK = c.HVCasePK
	LEFT JOIN @tblAssessmentInfo a ON a.HVCasePK = c.HVCasePK
	LEFT JOIN @tblIntakeInfo i ON i.HVCasePK = c.HVCasePK

	SELECT * FROM @tblResults
END
GO
