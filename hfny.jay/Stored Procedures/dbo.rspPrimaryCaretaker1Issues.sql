SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspPrimaryCaretaker1Issues] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @programfk INT = 6 
--DECLARE @StartDt DATETIME = '07/01/2011'
--DECLARE @EndDt DATETIME = '03/31/2012'

DECLARE @x INT = 0
DECLARE @y INT = 0

SELECT @x = count(DISTINCT a.HVCaseFK)
FROM dbo.PC1Issues AS a
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE a.PC1IssuesDate BETWEEN @StartDt AND @EndDt
AND a.ProgramFK = @programfk AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)

SELECT @y = count(DISTINCT a.HVCaseFK)
FROM dbo.PC1Issues AS a
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE a.PC1IssuesDate BETWEEN @StartDt AND @EndDt
AND rtrim(a.Interval) = '1'
AND a.ProgramFK = @programfk AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)

IF @x = 0 
BEGIN
  SET @x = 1
END
IF @y = 0 
BEGIN
  SET @y = 1
END

; WITH xxx AS (
SELECT a.HVCaseFK, max(PC1IssuesPK) [PC1IssuesPK]
FROM dbo.PC1Issues AS a
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE a.PC1IssuesDate BETWEEN @StartDt AND @EndDt
AND a.ProgramFK = @programfk AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
GROUP BY a.HVCaseFK
)
,
yyy AS (
SELECT a.HVCaseFK, max(a.PC1IssuesPK) [PC1IssuesPK]
FROM dbo.PC1Issues AS a
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE a.PC1IssuesDate BETWEEN @StartDt AND @EndDt
AND rtrim(a.Interval) = '1'
AND a.ProgramFK = @programfk AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
GROUP BY a.HVCaseFK
)
,

sub1 AS (
SELECT 
str(sum(CASE WHEN AlcoholAbuse = '1' OR SubstanceAbuse = '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN AlcoholAbuse IN ('1', '0', '9') OR SubstanceAbuse IN ('1', '0', '9') 
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [01SubstanceAbuse]
, '0 %' [02PhysicalDisability]
, str(sum(CASE WHEN MentalIllness = '1' OR Depression = '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN MentalIllness IN ('1', '0', '9') OR Depression IN ('1', '0', '9') 
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [03MentalHealth]
, str(sum(CASE WHEN Stress = '1'  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Stress IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [04Stress]
, '0 %' [05DevelopmentalDisability]
, str(sum(CASE WHEN DomesticViolence = '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN DomesticViolence IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [06Violence]
, str(sum(CASE WHEN MaritalProblems = '1'  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN MaritalProblems IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [07MaritalProblem]
, str(sum(CASE WHEN CriminalActivity = '1'  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN CriminalActivity IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [08LegalIssues]
, str(sum(CASE WHEN FinancialDifficulty = '1' OR InadequateBasics = '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN FinancialDifficulty IN ('1', '0', '9') OR InadequateBasics IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [09ResourceIssues]
, str(sum(CASE WHEN Homeless = '1'  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Homeless IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [10Homeless]
, str(sum(CASE WHEN SocialIsolation = '1'  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN SocialIsolation IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [11SocialIsolation]
, str(sum(CASE WHEN Smoking = '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Stress IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @x < 75.0 THEN '**' ELSE '' END [12Smoking]

FROM dbo.PC1Issues AS a
JOIN xxx AS a1 ON a.PC1IssuesPK = a1.PC1IssuesPK
)
,
sub2 AS (
SELECT 
str(sum(CASE WHEN AlcoholAbuse = '1' OR SubstanceAbuse = '1' THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN AlcoholAbuse IN ('1', '0', '9') OR SubstanceAbuse IN ('1', '0', '9') 
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [01SubstanceAbuseAE]
, '0 %' [02PhysicalDisabilityAE]
, str(sum(CASE WHEN MentalIllness = '1' OR Depression = '1' THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN MentalIllness IN ('1', '0', '9') OR Depression IN ('1', '0', '9') 
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [03MentalHealthAE]
, str(sum(CASE WHEN Stress = '1'  THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Stress IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [04StressAE]
, '0 %' [05DevelopmentalDisabilityAE]
, str(sum(CASE WHEN DomesticViolence = '1' THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN DomesticViolence IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [06ViolenceAE]
, str(sum(CASE WHEN MaritalProblems = '1'  THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN MaritalProblems IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [07MaritalProblemAE]
, str(sum(CASE WHEN CriminalActivity = '1'  THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN CriminalActivity IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [08LegalIssuesAE]
, str(sum(CASE WHEN FinancialDifficulty = '1' OR InadequateBasics = '1' THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN FinancialDifficulty IN ('1', '0', '9') OR InadequateBasics IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [09ResourceIssuesAE]
, str(sum(CASE WHEN Homeless = '1'  THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Homeless IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [10HomelessAE]
, str(sum(CASE WHEN SocialIsolation = '1'  THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN SocialIsolation IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [11SocialIsolationAE]
, str(sum(CASE WHEN Smoking = '1' THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + ' %' 
+ CASE WHEN sum(CASE WHEN Stress IN ('1', '0', '9')
THEN 1 ELSE 0 END) * 100.0 / @y < 75.0 THEN '**' ELSE '' END [12SmokingAE]

FROM dbo.PC1Issues AS a
JOIN yyy AS b ON a.PC1IssuesPK = b.PC1IssuesPK
)

SELECT @y [00AssessmentN], @x [00CurrentIssueN], * FROM sub2
JOIN sub1 ON 1 = 1
GO
