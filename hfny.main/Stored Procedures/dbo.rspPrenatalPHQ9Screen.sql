SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	  Bill O'Brien
-- Create date: 12/12/2019
-- Description: <report: Credentialing 7-4 B. Administration of the Depression Screen Prenatally (PHQ-2/9) - Summary>
-- EXEC rspPrenatalPHQ9Screen 1, '2018-07-01', null, null, null, null, ''
-- =============================================
CREATE PROCEDURE [dbo].[rspPrenatalPHQ9Screen] (@ProgramFK VARCHAR(MAX) = NULL,
												@CutoffDate DATE = NULL,
												@SupervisorFK INT = NULL,
												@WorkerFK INT = NULL,
												@PC1ID VARCHAR(13) = '',
												@SiteFK INT = NULL,
												@CaseFiltersPositive VARCHAR(100) = ''
											)
AS

IF @ProgramFK is null
	BEGIN
		SELECT	@ProgramFK = SUBSTRING((SELECT	',' + LTRIM(RTRIM(STR(HVProgramPK)))
										FROM HVProgram
									    FOR XML PATH('')), 2, 8000);
	END;
SET @ProgramFK = REPLACE(@ProgramFK, '"', '');
SET @SiteFK = ISNULL(@SiteFK, 0);
SET @PC1ID = ISNULL(@PC1ID, '');
SET @CaseFiltersPositive = CASE	WHEN @CaseFiltersPositive = '' THEN null
								ELSE @CaseFiltersPositive
						   END;

DECLARE @Cohort AS TABLE (
	HVCaseFK INT,
	PC1ID CHAR(13),
	SupervisorFirstName CHAR(20),
	SupervisorLastName CHAR(30),
	WorkerFirstName CHAR(20),
	WorkerLastName CHAR(30),
	TCFirstName VARCHAR(200),
	TCLastName VARCHAR(200),
	GestationalAge INT,
	IntakeDate DATETIME,
	TCDOB DATETIME,
	EDC DATETIME,
	DateAdministered DATETIME,
	Invalid BIT,
	TotalFamilies INT,
	TotalMeeting INT
)
INSERT INTO @Cohort
(
    HVCaseFK,
    PC1ID,
    SupervisorFirstName,
    SupervisorLastName,
    WorkerFirstName,
    WorkerLastName,
    TCFirstName,
    TCLastName,
    IntakeDate,
    TCDOB,
    EDC,
	DateAdministered,
	Invalid
)
SELECT 
	cp.HVCaseFK,
	cp.PC1ID,
	supervisor.FirstName,
	supervisor.LastName,
	fsw.FirstName,
	fsw.LastName,
	tc.TCFirstName,
	tc.TCLastName,
	hc.IntakeDate,
	hc.TCDOB,
	hc.EDC,
	p.DateAdministered,
	p.Invalid
FROM CaseProgram cp
	INNER JOIN HVCase hc ON hc.HVCasePK = cp.HVCaseFK
	INNER JOIN dbo.SplitString(@ProgramFK, ',') ON cp.ProgramFK = ListItem
	INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf ON cf.HVCaseFK = cp.HVCaseFK
	INNER JOIN Worker fsw ON cp.CurrentFSWFK = fsw.WorkerPK
	INNER JOIN WorkerProgram wp ON wp.WorkerFK = fsw.WorkerPK and wp.ProgramFK = ListItem
	INNER JOIN Worker supervisor ON wp.SupervisorFK = supervisor.WorkerPK
	INNER JOIN TCID tc ON tc.HVCaseFK = cp.HVCaseFK
	LEFT JOIN dbo.PHQ9 p ON p.HVCaseFK = cp.HVCaseFK AND p.DateAdministered < hc.TCDOB
WHERE 
	cp.DischargeDate IS NULL
	AND hc.IntakeDate >= @CutoffDate
	AND hc.TCDOB < hc.IntakeDate
	AND cp.CurrentFSWFK = ISNULL(@WorkerFK, cp.CurrentFSWFK)
	AND wp.SupervisorFK = ISNULL(@SupervisorFK, wp.SupervisorFK)
	AND cp.PC1ID = CASE	WHEN @PC1ID = '' THEN cp.PC1ID ELSE @PC1ID END
	AND CASE WHEN @SiteFK = 0 THEN 1 WHEN wp.SiteFK = @SiteFK THEN 1 ELSE 0 END = 1
			 

UPDATE @Cohort SET TotalFamilies = (SELECT COUNT(DISTINCT HVCaseFK) FROM @Cohort)
UPDATE @Cohort SET TotalMeeting = (SELECT COUNT(DISTINCT HVCaseFK) FROM @Cohort  WHERE DateAdministered IS NOT NULL AND Invalid = 0)
SELECT DISTINCT
	   HVCaseFK,
       PC1ID,
       SupervisorFirstName,
       SupervisorLastName,
       WorkerFirstName,
       WorkerLastName,
       TCFirstName,
       TCLastName,
       IntakeDate,
       TCDOB,
       EDC,
       DateAdministered,
       Invalid,
	   TotalFamilies,
	   TotalMeeting,
	   CASE WHEN DateAdministered IS NOT NULL AND Invalid = 0 THEN 'Meets' ELSE 'Does Not Meet' END AS MeetsStandard,
	   CASE WHEN DateAdministered IS NULL THEN 'Not Administered' 
	        WHEN  Invalid = 1 THEN 'PHQ9 Invalid'
			ELSE '' END AS ReasonNotMeeting 
FROM @Cohort
ORDER BY HVCaseFK, DateAdministered
GO
