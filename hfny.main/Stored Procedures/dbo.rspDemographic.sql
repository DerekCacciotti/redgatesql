SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 12/4/19
-- Description:	Complete code for Demographic Report
-- =============================================
CREATE PROC [dbo].[rspDemographic]
	@StartDate DATETIME,
	@EndDate DATETIME,
	@ProgramFK VARCHAR(MAX) = NULL,
	@NewlyEnrolled AS INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ProgramFK is null
	BEGIN
		SELECT @ProgramFK = substring((SELECT ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   FROM HVProgram
										   FOR XML PATH ('')),2,8000)
	END

	SET @ProgramFK = REPLACE(@ProgramFK,'"','')

	DECLARE @Cohort AS TABLE (
		PC1ID CHAR(13),
		HVCasePK INT,
		CaseProgress NUMERIC(3,1),
		IntakeDate DATETIME,
		CaseStartDate DATETIME,
		TCDOB DATETIME,
		CurrentLevel VARCHAR(50),
		PCFirstName VARCHAR(200),
		PCLastName VARCHAR(200),
		PCDOB DATETIME,
		PCZip VARCHAR(200),
		Gender CHAR(2),
		Race_AmericanIndian bit,
		Race_Asian bit,
		Race_Black bit,
		Race_Hawaiian bit,
		Race_White bit,
		Race_Hispanic bit,
		Race_Other bit,
		RaceSpecify VARCHAR(500),
		Ethnicity VARCHAR(500),
		DischargeDate DATETIME,
		DischargeReason CHAR(2),
		DischargeReasonSpecify VARCHAR(500)
	)
	INSERT INTO @Cohort
	(
	    PC1ID,
	    HVCasePK,
		CaseProgress,
		IntakeDate,
		CaseStartDate,
		TCDOB,
	    CurrentLevel,
	    PCFirstName,
	    PCLastName,
	    PCDOB,
		PCZip,
	    Gender,
	    Race_AmericanIndian,
		Race_Asian,
		Race_Black,
		Race_Hawaiian,
		Race_White,
		Race_Hispanic,
		Race_Other,
	    RaceSpecify,
	    Ethnicity,
	    DischargeDate,
	    DischargeReason,
	    DischargeReasonSpecify
	)
	SELECT
		cp.PC1ID,
		cp.HVCaseFK,
		hc.CaseProgress,
		hc.IntakeDate,
		cp.CaseStartDate,
		hc.TCDOB,
		cl.LevelName,
		p.PCFirstName,
		p.PCLastName,
		p.PCDOB,
		p.PCZip,
		p.Gender,
		p.Race_AmericanIndian,
		p.Race_Asian,
		p.Race_Black,
		p.Race_Hawaiian,
		p.Race_White,
		p.Race_Hispanic,
		p.Race_Other,
		p.RaceSpecify,
		p.Ethnicity,
		cp.DischargeDate,
		cp.DischargeReason,
		cp.DischargeReasonSpecify
	FROM dbo.CaseProgram cp
	INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
	INNER JOIN dbo.HVCase hc ON hc.HVCasePK = cp.HVCaseFK
	INNER JOIN dbo.codeLevel cl ON cl.codeLevelPK = cp.CurrentLevelFK
	INNER JOIN dbo.PC p ON p.PCPK = hc.PC1FK
	WHERE (cp.DischargeDate IS NULL OR cp.DischargeDate >= @StartDate)
	AND hc.CaseProgress >= 9
	AND CASE 
			WHEN @NewlyEnrolled = 1 THEN
				CASE WHEN hc.IntakeDate BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END
            ELSE 1
		END	= 1

	DECLARE	@CommonAtt AS TABLE (
		HVCaseFK INT,
		FormDate DATETIME,
		FormType CHAR(8),
		HighestGrade CHAR(2),
		IsCurrentlyEmployed CHAR(1),
		EducationalEnrollment CHAR(1),
		PrimaryLanguage CHAR(2),
		LanguageSpecify VARCHAR(100),
		MaritalStatus CHAR(2),
		NumberInHouse INT,
		Parity INT,
		Gravida CHAR(2)
	)
	INSERT INTO	@CommonAtt
	(
	    HVCaseFK,
	    FormDate,
		FormType,
	    HighestGrade,
	    IsCurrentlyEmployed,
	    EducationalEnrollment,
	    PrimaryLanguage,
	    LanguageSpecify,
	    MaritalStatus,
		NumberInHouse,
	    Parity,
	    Gravida
	)
	SELECT HVCaseFK,
		   FormDate,
		   FormType,
		   ca.HighestGrade,
		   ca.IsCurrentlyEmployed,
		   ca.EducationalEnrollment,
		   ca.PrimaryLanguage,
		   LanguageSpecify,
		   MaritalStatus,
		   NumberInHouse,
		   Parity,
		   Gravida
	FROM dbo.CommonAttributes ca
	INNER JOIN @Cohort c ON c.HVCasePK = ca.HVCaseFK
	WHERE FormDate <= @EndDate AND	
	(FormType = 'IN' OR FormType = 'IN-PC1' OR FormType = 'ID' OR FormType = 'KE' OR FormType = 'TC')

	DECLARE @OBPInHome AS TABLE (
		HVCaseFK INT,
		OBPInHome CHAR(1)
	)
	INSERT INTO @OBPInHome
	(
	    HVCaseFK,
	    OBPInHome
	)
	SELECT HVCaseFK,
	       OBPInHome
	FROM dbo.CommonAttributes ca
	INNER JOIN @Cohort c ON ca.HVCaseFK = c.HVCasePK AND ca.FormType = 'ID'

	DECLARE @Issues AS TABLE (
		HVCaseFK INT,
		AlcoholAbuse CHAR(1),
		CriminalActivity CHAR(1),
		Depression CHAR(1),
		DevelopmentalDisability CHAR(1),
		DomesticViolence CHAR(1),
		FinancialDifficulty CHAR(1),
		Homeless CHAR(1),
		InadequateBasics CHAR(1),
		MaritalProblems CHAR(1),
		MentalIllness CHAR(1),
		OtherIssue CHAR(1),
		OtherIssueSpecify VARCHAR(500),
		OtherLegalProblems CHAR(1),
		PhysicalDisability CHAR(1),
		Smoking CHAR(1),
		SocialIsolation CHAR(1),
		Stress CHAR(1),
		SubstanceAbuse CHAR(1)
	)
	INSERT INTO @Issues
	(
	    HVCaseFK,
	    AlcoholAbuse,
	    CriminalActivity,
	    Depression,
	    DevelopmentalDisability,
	    DomesticViolence,
	    FinancialDifficulty,
	    Homeless,
	    InadequateBasics,
	    MaritalProblems,
	    MentalIllness,
	    OtherIssue,
	    OtherIssueSpecify,
	    OtherLegalProblems,
	    PhysicalDisability,
	    Smoking,
	    SocialIsolation,
	    Stress,
	    SubstanceAbuse
	)
	SELECT	HVCaseFK,
			AlcoholAbuse,
			CriminalActivity,
			Depression,
			DevelopmentalDisability,
			DomesticViolence,
			FinancialDifficulty,
			Homeless,
			InadequateBasics,
			MaritalProblems,
			MentalIllness,
			OtherIssue,
			OtherIssueSpecify,
			OtherLegalProblems,
			PhysicalDisability,
			Smoking,
			SocialIsolation,
			Stress,
			SubstanceAbuse
	FROM dbo.PC1Issues pci 
	INNER JOIN @Cohort c ON c.HVCasePK = pci.HVCaseFK
	WHERE pci.Interval = '1'

	DECLARE @HighestGrade AS TABLE (
		HVCaseFK INT,
		HighestGrade CHAR(2)
	) 

	INSERT INTO @HighestGrade
	(
	    HVCaseFK,
	    HighestGrade
	)
	SELECT HVCaseFK,
		   MAX(HighestGrade)		   
     FROM @CommonAtt GROUP BY HVCaseFK


	DECLARE @IsCurrentlyEmployed AS TABLE (
		HVCaseFK INT,
		IsCurrentlyEmployed CHAR(1)
	)
	INSERT INTO @IsCurrentlyEmployed
	(
	    HVCaseFK,
	    IsCurrentlyEmployed
	)
	SELECT HVCaseFK,
		   IsCurrentlyEmployed
	FROM
	@CommonAtt ca WHERE ca.FormType = 'IN-PC1'


	DECLARE @EducationalEnrollment AS TABLE (
		HVCaseFK INT,
		EducationalEnrollment CHAR(1)
	)
	INSERT INTO	@EducationalEnrollment
	(
	    HVCaseFK,
	    EducationalEnrollment
	)
	SELECT HVCaseFK,
		   EducationalEnrollment
	FROM	
		(SELECT HVCaseFK,
				EducationalEnrollment,				
				ROW_NUMBER() OVER (PARTITION BY HVCaseFK ORDER BY FormDate DESC) AS RowNum
		FROM @CommonAtt
		WHERE EducationalEnrollment IS NOT NULL) AS sub
	WHERE sub.RowNum = 1

	DECLARE @PrimaryLanguage AS TABLE (
		HVCaseFK INT,
		PrimaryLanguage CHAR(2),
		LanguageSpecify VARCHAR(100)
	)
	INSERT INTO @PrimaryLanguage
	(
	    HVCaseFK,
	    PrimaryLanguage,
		LanguageSpecify
	)
	SELECT HVCaseFK,
		   PrimaryLanguage,
		   LanguageSpecify
	FROM	
		(SELECT	HVCaseFK, 
				PrimaryLanguage,
				LanguageSpecify,
				ROW_NUMBER() OVER (PARTITION BY HVCaseFK ORDER BY FormDate DESC) AS RowNum
		FROM @CommonAtt
		WHERE PrimaryLanguage IS NOT NULL) AS sub
	WHERE sub.RowNum = 1


	DECLARE @MaritalStatus AS TABLE (
		HVCaseFK INT,
		MaritalStatus CHAR(2)
	)
	INSERT INTO @MaritalStatus
	(
	    HVCaseFK,
	    MaritalStatus
	)
	SELECT HVCaseFK,
		   MaritalStatus
	FROM
	(SELECT	HVCaseFK, 
			MaritalStatus,
				ROW_NUMBER() OVER (PARTITION BY HVCaseFK ORDER BY FormDate DESC) AS RowNum
		FROM @CommonAtt
		WHERE MaritalStatus IS NOT NULL) AS sub
	WHERE sub.RowNum = 1
	

	DECLARE @IntakeAttributes AS TABLE (
		HVCaseFK INT,
		ReceivingPublicBenefits CHAR(1),
		PBEmergencyAssistance CHAR(1),
		PBFoodStamps CHAR(1),
		PBSSI CHAR(1),
		PBTANF CHAR(1),
		PBWIC CHAR(1),
		NumberInHouse INT
	)
	INSERT INTO @IntakeAttributes
	(
	    HVCaseFK,
	    ReceivingPublicBenefits,
		PBEmergencyAssistance,
		PBFoodStamps,
		PBSSI,
		PBTANF,
		PBWIC,
		NumberInHouse
	)
	SELECT HVCaseFK,
		   ReceivingPublicBenefits,
		   PBEmergencyAssistance,
		   PBFoodStamps,
		   PBSSI,
		   PBTANF,
		   PBWIC,
		   NumberInHouse
	FROM
	dbo.CommonAttributes ca 
	INNER JOIN @Cohort c ON ca.HVCaseFK = c.HVCasePK AND ca.FormType = 'IN'

	DECLARE @Parity AS TABLE (
	HVCaseFK INT,
	Parity INT
	)
	INSERT INTO @Parity
	(
	    HVCaseFK,
	    Parity
	)
	SELECT HVCaseFK,
		   Parity
	FROM
		(SELECT	HVCaseFK, 
			    Parity,
				ROW_NUMBER() OVER (PARTITION BY HVCaseFK ORDER BY FormDate DESC) AS RowNum
		FROM @CommonAtt
		WHERE Parity IS NOT NULL) AS sub
	WHERE sub.RowNum = 1


	DECLARE @Gravida AS TABLE (
	HVCaseFK INT,
	Gravida CHAR(2)
	)
	INSERT INTO @Gravida
	(
	    HVCaseFK,
	    Gravida
	)
	SELECT HVCaseFK,
		   Gravida
	FROM
		(SELECT	HVCaseFK, 
			    Gravida,
				ROW_NUMBER() OVER (PARTITION BY HVCaseFK ORDER BY FormDate DESC) AS RowNum
		FROM @CommonAtt
		WHERE Gravida IS NOT NULL) AS sub
	WHERE sub.RowNum = 1

	SELECT c.PC1ID,
		   c.HVCasePK,
		   c.CaseProgress,
		   LEFT(CONVERT(VARCHAR, c.CaseStartDate, 120), 10) AS CaseStartDate,
		   LEFT(CONVERT(VARCHAR, c.IntakeDate, 120), 10) AS IntakeDate,
		   LEFT(CONVERT(VARCHAR, c.DischargeDate, 120), 10) AS DischargeDate,
		   cd.DischargeReason,
           c.DischargeReasonSpecify,
		   CASE WHEN c.DischargeDate IS NOT NULL THEN 
					DATEDIFF(DAY,c.CaseStartDate, c.DischargeDate) 
				ELSE
					DATEDIFF(DAY,c.CaseStartDate, GETDATE())
		   END AS DaysInProgram,
		   CASE WHEN c.TCDOB IS NOT NULL THEN
					CASE WHEN c.TCDOB <= c.IntakeDate THEN 'No' ELSE 'Yes' END
			    ELSE 'Yes'
		   END AS PregnantAtEnrollment,
		   LEFT(CONVERT(VARCHAR, c.TCDOB, 120), 10) AS TCDOB,
           c.CurrentLevel,
           c.PCFirstName,
           c.PCLastName,
           LEFT(CONVERT(VARCHAR, c.PCDOB, 120), 10) AS PCDOB,
		   PCZip,
		   gender.AppCodeText AS Gender,
		   dbo.fnGetRaceText(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_Other, Race_White, RaceSpecify) AS Race,
           c.RaceSpecify,
           Case When Race_Hispanic = 1 Then 'Hispanic ' Else '' End + c.Ethnicity As Ethnicity,
		   edu.AppCodeText AS HighestGrade,
           CASE WHEN ice.IsCurrentlyEmployed = 1 THEN 'Yes' 
				WHEN ice.IsCurrentlyEmployed = 0 THEN 'No' 
				Else ice.IsCurrentlyEmployed 
		   END AS IsCurrentlyEmployed,
		   CASE WHEN ee.EducationalEnrollment = 1 THEN 'Yes'
			    WHEN ee.EducationalEnrollment = 0 THEN 'No' 
				ELSE ee.EducationalEnrollment 
		   END AS EducationalEnrollment,
		   lang.AppCodeText AS PrimaryLanguage,
		   pl.LanguageSpecify,
		   marital.AppCodeText AS MaritalStatus,
		   CASE WHEN ia.ReceivingPublicBenefits = 1 THEN 'Yes' 
		        WHEN ia.ReceivingPublicBenefits = 0 THEN 'No'
				ELSE ia.ReceivingPublicBenefits
		   END As RecevingPublicBenefits,
		   CASE WHEN ia.PBEmergencyAssistance = 1 THEN 'Yes' 
		        WHEN ia.PBEmergencyAssistance = 0 THEN 'No'
				ELSE ia.PBEmergencyAssistance
		   END As EmergencyAssistance,
		   CASE WHEN ia.PBFoodStamps = 1 THEN 'Yes' 
		        WHEN ia.PBFoodStamps = 0 THEN 'No'
				ELSE ia.PBFoodStamps
		   END As FoodStamps,
		   CASE WHEN ia.PBSSI = 1 THEN 'Yes' 
		        WHEN ia.PBSSI = 0 THEN 'No'
				ELSE ia.PBSSI
		   END As SSI,
		   CASE WHEN ia.PBTANF = 1 THEN 'Yes' 
		        WHEN ia.PBTANF = 0 THEN 'No'
				ELSE ia.PBTANF
		   END As TANF,
		   CASE WHEN ia.PBWIC = 1 THEN 'Yes' 
		        WHEN ia.PBWIC = 0 THEN 'No'
				ELSE ia.PBWIC
		   END As WIC,
		   ia.NumberInHouse,
		   CASE WHEN oih.OBPInHome = 1 THEN 'Yes' 
		        WHEN oih.OBPInHome = 0 THEN 'No'
				WHEN oih.OBPInHome = 9 THEN 'Unknown'
				ELSE oih.OBPInHome
		   END As OBPInHome,
		   p.Parity,
		   g.Gravida,
		   CASE WHEN i.AlcoholAbuse = 1 THEN 'Yes' 
		        WHEN i.AlcoholAbuse = 0 THEN 'No'
				WHEN i.AlcoholAbuse = 9 THEN 'Unknown'
				ELSE i.AlcoholAbuse
		   END As AlcoholAbuse,
		   CASE WHEN i.CriminalActivity = 1 THEN 'Yes' 
		        WHEN i.CriminalActivity = 0 THEN 'No'
				WHEN i.CriminalActivity = 9 THEN 'Unknown'
				ELSE i.CriminalActivity
		   END As CriminalActivity,
		   CASE WHEN i.Depression = 1 THEN 'Yes' 
		        WHEN i.Depression = 0 THEN 'No'
				WHEN i.Depression = 9 THEN 'Unknown'
				ELSE i.Depression
		   END As Depression,
		   CASE WHEN i.DevelopmentalDisability = 1 THEN 'Yes' 
		        WHEN i.DevelopmentalDisability = 0 THEN 'No'
				WHEN i.DevelopmentalDisability = 9 THEN 'Unknown'
				ELSE i.DevelopmentalDisability
		   END As DevelopmentalDisability,
		   CASE WHEN i.DomesticViolence = 1 THEN 'Yes' 
		        WHEN i.DomesticViolence = 0 THEN 'No'
				WHEN i.DomesticViolence = 9 THEN 'Unknown'
				ELSE i.DomesticViolence
		   END As DomesticViolence,
		   CASE WHEN i.FinancialDifficulty = 1 THEN 'Yes' 
		        WHEN i.FinancialDifficulty = 0 THEN 'No'
				WHEN i.FinancialDifficulty = 9 THEN 'Unknown'
				ELSE i.FinancialDifficulty
		   END As FinancialDifficulty,
		   CASE WHEN i.Homeless = 1 THEN 'Yes' 
		        WHEN i.Homeless = 0 THEN 'No'
				WHEN i.AlcoholAbuse = 9 THEN 'Unknown'
				ELSE i.Homeless
		   END As Homeless,
		   CASE WHEN i.InadequateBasics = 1 THEN 'Yes' 
		        WHEN i.InadequateBasics = 0 THEN 'No'
				WHEN i.InadequateBasics = 9 THEN 'Unknown'
				ELSE i.InadequateBasics
		   END As InadequateBasics,
		   CASE WHEN i.MaritalProblems = 1 THEN 'Yes' 
		        WHEN i.MaritalProblems = 0 THEN 'No'
				WHEN i.MaritalProblems = 9 THEN 'Unknown'
				ELSE i.MaritalProblems
		   END As MaritalProblems,
		   CASE WHEN i.MentalIllness = 1 THEN 'Yes' 
		        WHEN i.MentalIllness = 0 THEN 'No'
				WHEN i.MentalIllness = 9 THEN 'Unknown'
				ELSE i.MentalIllness
		   END As MentalIllness,
		   CASE WHEN i.OtherIssue = 1 THEN 'Yes' 
		        WHEN i.OtherIssue = 0 THEN 'No'
				WHEN i.OtherIssue = 9 THEN 'Unknown'
				ELSE i.OtherIssue
		   END As OtherIssue,
           i.OtherIssueSpecify,
		   CASE WHEN i.OtherLegalProblems = 1 THEN 'Yes' 
		        WHEN i.OtherLegalProblems = 0 THEN 'No'
				WHEN i.OtherLegalProblems = 9 THEN 'Unknown'
				ELSE i.OtherLegalProblems
		   END As OtherLegalProblems,
		   CASE WHEN i.PhysicalDisability = 1 THEN 'Yes' 
		        WHEN i.PhysicalDisability = 0 THEN 'No'
				WHEN i.PhysicalDisability = 9 THEN 'Unknown'
				ELSE i.PhysicalDisability
		   END As PhysicalDisability,
		   CASE WHEN i.Smoking = 1 THEN 'Yes' 
		        WHEN i.Smoking = 0 THEN 'No'
				WHEN i.Smoking = 9 THEN 'Unknown'
				ELSE i.Smoking
		   END As Smoking,
		   CASE WHEN i.SocialIsolation = 1 THEN 'Yes' 
		        WHEN i.SocialIsolation = 0 THEN 'No'
				WHEN i.SocialIsolation = 9 THEN 'Unknown'
				ELSE i.SocialIsolation
		   END As SocialIsolation,
		   CASE WHEN i.Stress = 1 THEN 'Yes' 
		        WHEN i.Stress = 0 THEN 'No'
				WHEN i.Stress = 9 THEN 'Unknown'
				ELSE i.Stress
		   END As Stress,
		   CASE WHEN i.SubstanceAbuse = 1 THEN 'Yes' 
		        WHEN i.SubstanceAbuse = 0 THEN 'No'
				WHEN i.SubstanceAbuse = 9 THEN 'Unknown'
				ELSE i.SubstanceAbuse
		   END As SubstanceAbuse
    FROM @Cohort c
	LEFT JOIN dbo.codeApp gender ON gender.AppCode = c.Gender AND TRIM(gender.AppCodeGroup) = 'Gender'
	LEFT JOIN @EducationalEnrollment ee ON c.HVCasePK = ee.HVCaseFK
	LEFT JOIN @HighestGrade hg ON hg.HVCaseFK = c.HVCasePK
	LEFT JOIN dbo.codeApp edu ON edu.AppCode = hg.HighestGrade AND TRIM(edu.AppCodeGroup) = 'Education'
	LEFT JOIN @IsCurrentlyEmployed ice ON ice.HVCaseFK = c.HVCasePK
	LEFT JOIN @PrimaryLanguage pl ON pl.HVCaseFK = c.HVCasePK
	LEFT JOIN dbo.codeApp lang ON lang.AppCode = pl.PrimaryLanguage AND TRIM(lang.AppCodeGroup) = 'PrimaryLanguage'
	LEFT JOIN @MaritalStatus ms ON ms.HVCaseFK = c.HVCasePK
	LEFT JOIN dbo.codeApp marital ON marital.AppCode = ms.MaritalStatus AND TRIM(marital.AppCodeGroup) = 'MaritalStatus'
	LEFT JOIN @IntakeAttributes ia ON ia.HVCaseFK = c.HVCasePK
	LEFT JOIN @Parity p ON p.HVCaseFK = c.HVCasePK
	LEFT JOIN @Gravida g ON g.HVCaseFK = c.HVCasePK
	LEFT JOIN @Issues i ON i.HVCaseFK = c.HVCasePK
	LEFT JOIN dbo.codeDischarge cd ON cd.DischargeCode = c.DischargeReason
	LEFT JOIN @OBPInHome oih ON oih.HVCaseFK = c.HVCasePK

END
GO
