SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Dar Chen>
-- Create date: <Dec 11, 2012>
-- Description: <4-1B. Intensive Home Visitation Level after Target Child is Born>
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE PROC [dbo].[rspHVIntensiveLevel_Detail]
(
    @programfk VARCHAR(MAX)    = NULL,
    @sdate     DATETIME,
    @edate     DATETIME, 
    @sitefk		 INT			 = NULL,
    @posclause	 VARCHAR(200), 
    @negclause	 VARCHAR(200)
)
AS

--declare    @programfk varchar(max)    = '1'
--declare    @sdate     DATETIME = '01/01/2010'
--declare    @edate     DATETIME = '01/01/2011'
--declare    @sitefk		 int			 = null
--declare    @posclause	 varchar(200) = null
--declare    @negclause	 varchar(200) = null

IF @programfk IS NULL
BEGIN
	SELECT @programfk = SUBSTRING((SELECT ','+LTRIM(RTRIM(STR(HVProgramPK)))
									   FROM HVProgram
									   FOR XML PATH ('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','')
SET @sitefk = CASE WHEN dbo.IsNullOrEmpty(@sitefk) = 1 THEN 0 ELSE @sitefk END
SET @posclause = CASE WHEN @posclause = '' THEN NULL ELSE @posclause END

	DECLARE @cteCohort TABLE (
		PC1ID CHAR(13)
		, [Name] VARCHAR(450)
		, [edc_dob] DATETIME
		, IntakeDate DATETIME
		, dischargedate DATETIME
		, [days_length_total] NUMERIC
		, [WorkerName] CHAR(60)
		, [n] INT
		, HVCaseFK INT
		, caseprogress NUMERIC(3, 1)
		, SiteFK INT
		, Levelfk INT
		, StartLevelDate DATETIME
		, EndLevelDate DATETIME
		)

	INSERT INTO @cteCohort 
	SELECT 
	b.PC1ID
	, RTRIM(p.PCFirstName) + ' ' + RTRIM(p.PCLastName) [Name]
	, ISNULL(a.TCDOB,a.EDC) [edc_dob]
	, a.IntakeDate
	, b.DischargeDate
	, SUM((DATEDIFF(dd, c.StartLevelDate, CASE WHEN c.EndLevelDate IS NULL THEN @edate
	WHEN c.EndLevelDate > @edate THEN @edate
	ELSE c.EndLevelDate END + 1))) [days_length_total]
	, RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName) [WorkerName]
	, COUNT(*) [n]
	,b.HVCaseFK
	, a.CaseProgress
	, wp.SiteFK
	, c.LevelFK
	, c.StartLevelDate
	, c.EndLevelDate
	FROM HVCase AS a
		JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
		JOIN dbo.SplitString(@programfk,',') ON b.ProgramFK = ListItem
		JOIN HVLevelDetail AS c ON c.HVCaseFK = a.HVCasePK AND c.StartLevelDate <= @edate
		JOIN udfCaseFilters(@posclause, @negclause, @programfk) cf ON cf.HVCaseFK = a.HVCasePK
		JOIN Worker AS w ON w.WorkerPK = b.CurrentFSWFK
		JOIN WorkerProgram AS wp ON wp.WorkerFK = w.WorkerPK
		LEFT OUTER JOIN PC AS p ON p.PCPK = a.PC1FK
	GROUP BY
		b.HVCaseFK, b.PC1ID
		, RTRIM(p.PCFirstName) + ' ' + RTRIM(p.PCLastName)
		, ISNULL(a.TCDOB,a.EDC)
		, a.IntakeDate
		, RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName)
		, a.CaseProgress
		, wp.SiteFK
		, c.LevelFK
		, c.StartLevelDate
		, c.EndLevelDate
		, b.DischargeDate

	DECLARE @tblCaseProgramCohort TABLE (
		CaseProgramPK INT,
		PC1ID CHAR(13),
		HVCaseFK INT,
		CaseStartDate DATETIME,
		DischargeDate DATETIME,
		ProgramFK INT,
		RowNum INT
	)
	INSERT INTO @tblCaseProgramCohort
	(
	    CaseProgramPK,
	    PC1ID,
		HVCaseFK,
	    CaseStartDate,
	    DischargeDate,
	    ProgramFK,
		RowNum
	)
	SELECT cp.CaseProgramPK, 
		   cp.PC1ID,
		   cp.HVCaseFK,
		   cp.CaseStartDate, 
		   cp.DischargeDate, 
		   cp.ProgramFK, 
		   ROW_NUMBER() OVER(PARTITION BY cp.HVCaseFK ORDER BY cp.CaseStartDate DESC)
	FROM @cteCohort cc
	inner join CaseProgram cp on cp.PC1ID = cc.PC1ID

DECLARE @level2 TABLE (
	hvcasefk INT,
	[StartLevelDate_Level2] DATETIME
)
INSERT INTO @level2
SELECT a.HVCaseFK, MIN(a.StartLevelDate) [StartLevelDate_Level2]
FROM dbo.HVLevelDetail AS a
JOIN dbo.SplitString(@programfk,',') ON a.ProgramFK = ListItem
WHERE a.LevelFK IN (16, 18, 20) --AND ProgramFK = @programfk 
AND a.StartLevelDate <= @edate
GROUP BY a.HVCaseFK

DECLARE @xxx TABLE (
	PC1ID CHAR(15)
	,[Name] VARCHAR(450)
	,[edc_dob] DATETIME
	,IntakeDate DATETIME
	,[days_length_total] INT
	,[WorkerName] VARCHAR(450)
	,[n] INT
	,HVCaseFK INT
)
INSERT INTO @xxx
SELECT 
	cohort.PC1ID
	, [Name]
	, [edc_dob]
	, IntakeDate
	, SUM((DATEDIFF(dd, StartLevelDate, CASE WHEN EndLevelDate IS NULL THEN @edate
	WHEN EndLevelDate > @edate THEN @edate
	ELSE EndLevelDate END + 1))) [days_length_total]
	, [WorkerName]
	, COUNT(*) [n]
	,cohort.HVCaseFK
FROM @cteCohort cohort
INNER JOIN @tblCaseProgramCohort tcpc ON tcpc.HVCaseFK = cohort.HVCaseFK AND tcpc.RowNum = 1
LEFT OUTER JOIN @level2 l2 ON l2.hvcasefk = cohort.HVCaseFK
WHERE --b.ProgramFK = @programfk AND 
caseprogress >= 9
AND IntakeDate <= @edate
AND (cohort.dischargedate IS NULL OR cohort.dischargedate >= @sdate)
AND (CASE WHEN @sitefk = 0 THEN 1 WHEN SiteFK = @sitefk THEN 1 ELSE 0 END = 1)
AND Levelfk IN (12, 14)
AND (StartLevelDate_Level2 IS NULL OR StartLevelDate < StartLevelDate_Level2)
GROUP BY
cohort.HVCaseFK
, cohort.PC1ID
, [Name]
, [edc_dob]
, IntakeDate
, WorkerName

DECLARE @yyy TABLE (
	HVCaseFK INT
)
INSERT INTO @yyy 
SELECT DISTINCT cohort.HVCaseFK
FROM @cteCohort cohort
INNER JOIN @tblCaseProgramCohort tcpc ON tcpc.HVCaseFK = cohort.HVCaseFK AND tcpc.RowNum = 1
WHERE --b.ProgramFK = @programfk AND 
caseprogress >= 9
AND IntakeDate <= @edate
AND (cohort.dischargedate IS NULL OR cohort.dischargedate >= @sdate)
AND (CASE WHEN @sitefk = 0 THEN 1 WHEN SiteFK = @sitefk THEN 1 ELSE 0 END = 1)
AND Levelfk IN (16,18,20)

DECLARE @zzz TABLE (
	[more_than_6mo] INT,
	[less_than_6mo] INT,
	[total_number] INT
)
INSERT INTO @zzz
SELECT 
SUM(CASE WHEN a.days_length_total >= 183 THEN 1 ELSE 0 END) 
, SUM(CASE WHEN a.days_length_total >= 183 THEN 0 ELSE 1 END) 
, COUNT(*) 
FROM @xxx AS a
LEFT OUTER JOIN @yyy AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NOT NULL OR a.[days_length_total] >= 183

SELECT 
CASE WHEN a.days_length_total >= 183 THEN 2 ELSE 1 END [level1_less_183],
a.*,
c.*,
CASE WHEN b.HVCaseFK IS NOT NULL THEN 'Yes' ELSE 'No' END [Level2_3_4]
FROM @xxx AS a
JOIN @zzz AS c ON 1 = 1
LEFT OUTER JOIN @yyy AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NOT NULL OR a.[days_length_total] >= 183
ORDER BY level1_less_183, PC1ID


GO
