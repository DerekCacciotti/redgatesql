SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Bill O'Brien>
-- Create date: <February 4th, 2020>
-- Description:	<This QA report gets you 'ASQs for Active Cases with Target Child 4 months or older, calc. DOB '>
-- rspQAReport7 3, 'summary'	--- for summary page
-- rspQAReport7 1			--- for main report - location = 1
-- rspQAReport7 null			--- for main report for all locations
-- =============================================


CREATE PROCEDURE [dbo].[rspQAReport7]
(
	@ProgramFK INT = NULL,
	@ReportType char(7) = NULL 
)

AS

-- Last Day of Previous Month 
DECLARE @LastDayofPreviousMonth DATETIME 
SET @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

DECLARE @Cohort AS TABLE (
	HVCaseFK INT,
	PC1ID CHAR(13),
	TCIDPK INT,
	TCDOB DATETIME,
	CalcDOB DATETIME,
	TCAgeInDays INT,
	TCName VARCHAR(400),
	Worker VARCHAR(50),
	GestationalAge INT,
	CurrentLevel VARCHAR(50),
	YearOneASQCount INT,
	YearOneNotInWindow INT,
	YearOneNotReviewed INT,
	YearTwoASQCount INT,
	YearTwoNotInWindow INT,
	YearTwoNotReviewed INT,
	YearThreeASQCount INT,
	YearThreeNotInWindow INT,
	YearThreeNotReviewed INT,
	YearFourASQCount INT,
	YearFourNotInWindow INT,
	YearFourNotReviewed INT,
	YearFiveASQCount INT,
	YearFiveNotInWindow INT,
	YearFiveNotReviewed INT
)

INSERT INTO @Cohort (
	HVCaseFK,
	PC1ID,
	TCIDPK,
	TCDOB,
	CalcDOB,
	TCAgeInDays,
	TCName,
	Worker,
	GestationalAge,
	CurrentLevel
)

SELECT
	h.HVCasePK,
	cp.PC1ID,
	t.TCIDPK,
	t.TCDOB,
	DATEADD(d, ((40 - GestationalAge) * 7), t.TCDOB),
	DATEDIFF(DAY, DATEADD(d, ((40 - GestationalAge) * 7), t.TCDOB), @LastDayofPreviousMonth),
	TCFirstName + ' ' + TCLastName,
	Trim(FirstName) + ' ' + Trim(LastName),
	GestationalAge,
	LevelName
FROM HVCase h 
inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK and cp.ProgramFK = @ProgramFK
inner join Worker w on cp.CurrentFSWFK = w.WorkerPK 
inner join TCID t on t.HVCaseFK = h.HVCasePK and DATEDIFF(DAY, DATEADD(d, ((40 - GestationalAge) * 7), t.TCDOB), @LastDayofPreviousMonth) >= 365
inner join codeLevel cl on cp.CurrentLevelFK = cl.codeLevelPK
WHERE (DATEDIFF(DAY, h.IntakeDate, @LastDayofPreviousMonth) >= 30)
      AND
	  (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)

UPDATE @Cohort 
SET TCAgeInDays = 
	CASE WHEN TCDOB <> CalcDOB THEN DATEDIFF(DAY, CalcDOB, @LastDayOfPreviousMonth) 
		 ELSE DATEDIFF(DAY, TCDOB, @LastDayOfPreviousMonth)
	END

--calculating age in days

DECLARE @ASQs AS TABLE (
	ASQPK INT,
	HVCaseFK INT,
	TCIDFK INT,
	DateCompleted DATETIME,
	AgeWhenCompleted INT,
	Interval CHAR(2),
	InWindow BIT,
	Reviewed BIT
)

INSERT INTO @ASQs (
	ASQPK,
	HVCaseFK,
	TCIDFK,
	DateCompleted,
	Interval,
	InWindow,
	Reviewed
)

SELECT 
	a.ASQPK,
	a.HVCaseFK,
	a.TCIDFK,
	a.DateCompleted,
	a.TCAge,
	a.ASQInWindow,	
	dbo.IsFormReviewed(a.DateCompleted, 'AQ', ASQPK)
FROM ASQ a
WHERE a.HVCaseFK IN (SELECT HVCaseFK FROM @Cohort)

UPDATE @ASQs 
SET AgeWhenCompleted = CASE WHEN TCDOB <> CalcDOB THEN DATEDIFF(DAY, CalcDOB, DateCompleted) ELSE DATEDIFF(DAY, TCDOB, DateCompleted) END
FROM @ASQS a
INNER JOIN @Cohort c on a.HVCaseFK = c.HVCaseFK

-------------------------
--FIRST YEAR CALCULATIONS
-------------------------

--Get counts of reviewed, in window
UPDATE @Cohort 
SET YearOneASQCount = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('02', '04', '06', '08', '09', '10', '12')
	AND Reviewed = 1
	AND InWindow = 1
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of out of window
UPDATE @Cohort 
SET YearOneNotInWindow = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('02', '04', '06', '08', '09', '10', '12')
	AND InWindow = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of not reviewed
UPDATE @Cohort 
SET YearOneNotReviewed = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('02', '04', '06', '08', '09', '10', '12')
	AND Reviewed = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--------------------------
--SECOND YEAR CALCULATIONS
--------------------------
--Get counts of reviewed, in window
UPDATE @Cohort 
SET YearTwoASQCount = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('14', '16', '18', '20', '22', '24')
	AND Reviewed = 1
	AND InWindow = 1
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of out of window
UPDATE @Cohort 
SET YearTwoNotInWindow = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('14', '16', '18', '20', '22', '24')
	AND InWindow = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of not reviewed
UPDATE @Cohort 
SET YearTwoNotReviewed = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('14', '16', '18', '20', '22', '24')
	AND Reviewed = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

-------------------------
--THIRD YEAR CALCULATIONS
-------------------------
--Get counts of reviewed, in window
UPDATE @Cohort 
SET YearThreeASQCount = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('27', '30', '33', '36')
	AND Reviewed = 1
	AND InWindow = 1
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of out of window
UPDATE @Cohort 
SET YearThreeNotInWindow = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('27', '30', '33', '36')
	AND InWindow = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of not reviewed
UPDATE @Cohort 
SET YearThreeNotReviewed = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('27', '30', '33', '36')
	AND Reviewed = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--------------------------
--FOURTH YEAR CALCULATIONS
--------------------------
--Get counts of reviewed, in window
UPDATE @Cohort 
SET YearFourASQCount = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('42', '48')
	AND Reviewed = 1
	AND InWindow = 1
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of out of window
UPDATE @Cohort 
SET YearFourNotInWindow = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('42', '48')
	AND InWindow = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of not reviewed
UPDATE @Cohort 
SET YearFourNotReviewed = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('42', '48')
	AND Reviewed = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--------------------------
--FIFTH YEAR CALCULATIONS
--------------------------
--Get counts of reviewed, in window
UPDATE @Cohort 
SET YearFiveASQCount = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('54', '60')
	AND Reviewed = 1
	AND InWindow = 1
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of out of window
UPDATE @Cohort 
SET YearFiveNotInWindow = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('54', '60')
	AND InWindow = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK

--Get counts of not reviewed
UPDATE @Cohort 
SET YearFiveNotReviewed = ASQCount
FROM @Cohort c
INNER JOIN (
SELECT
	TCIDFK,
	COUNT(*) AS ASQCount 
FROM @ASQs 
WHERE Interval IN ('54', '60')
	AND Reviewed = 0
GROUP BY TCIDFK) sub ON c.TCIDPK = sub.TCIDFK


--Calculate who failed so we can send the counts to the summary and the details to the details.
DECLARE @Details TABLE (
	HVCaseFK INT,
	PC1ID CHAR(13),
	TCIDPK INT,
	TCDOB DATETIME,
	CalcDOB DATETIME,
	TCAgeInDays INT,
	TCName VARCHAR(400),
	Worker VARCHAR(50),
	GestationalAge INT,
	CurrentLevel VARCHAR(50),
	YearOneFailureReason VARCHAR(32),
	YearTwoFailureReason VARCHAR(32),
	YearThreeFailureReason VARCHAR(32),
	YearFourFailureReason VARCHAR(32),
	YearFiveFailureReason VARCHAR(32)
)
INSERT INTO @Details (
	HVCaseFK,
	PC1ID,
	TCIDPK,
	TCDOB,
	CalcDOB,
	TCAgeInDays,
	TCName,
	Worker,
	GestationalAge,
	CurrentLevel,
	YearOneFailureReason,
	YearTwoFailureReason,
	YearThreeFailureReason, 
	YearFourFailureReason,
	YearFiveFailureReason
)
SELECT 
	HVCaseFK,
	PC1ID,
	TCIDPK,
	TCDOB,
	CalcDOB,
	TCAgeInDays,
	TCName,
	Worker,
	GestationalAge,
	CurrentLevel,
	--If there aren't the required number of reviewed and in window asqs, figure out why.
	--We're pulling TCs that are at least 12 months old, so don't need to check age for 1st year.
	CASE WHEN YearOneASQCount < 2 THEN
		CASE WHEN YearOneNotInWindow > 0 AND YearOneNotReviewed IS NULL THEN 'Out of Window'
			 WHEN YearOneNotInWindow IS NULL AND YearOneNotReviewed > 0 THEN 'Not Reviewed' 
			 WHEN YearOneNotInWindow > 0 AND YearOneNotReviewed > 0 THEN 'Out of Window / Not Reviewed'
			 WHEN YearOneNotInWindow IS NULL AND YearOneNotReviewed IS NULL THEN 'Missing'
		END
	END AS YearOneFailureReason,

	CASE WHEN YearTwoASQCount < 2 THEN
		CASE
		--TC must be at least two years old to fail the two year asq requirement. Pattern continues with 3, 4, 5 year ASQs 
			WHEN TCAgeInDays > 730 THEN
				CASE WHEN YearTwoNotInWindow > 0 AND YearTwoNotReviewed IS NULL THEN 'Out of Window'
					 WHEN YearTwoNotInWindow IS NULL AND YearTwoNotReviewed > 0 THEN 'Not Reviewed' 
					 WHEN YearTwoNotInWindow > 0 AND YearTwoNotReviewed > 0 THEN 'Out of Window / Not Reviewed'
					 WHEN YearTwoNotInWindow IS NULL AND YearTwoNotReviewed IS NULL THEN 'Missing'
				END
		END
	END AS YearTwoFailureReason,

	CASE WHEN YearThreeASQCount < 2 THEN
		CASE
			WHEN TCAgeInDays > 1095 THEN
				CASE WHEN YearThreeNotInWindow > 0 AND YearThreeNotReviewed IS NULL THEN 'Out of Window'
					 WHEN YearThreeNotInWindow IS NULL AND YearThreeNotReviewed > 0 THEN 'Not Reviewed' 
					 WHEN YearThreeNotInWindow > 0 AND YearThreeNotReviewed > 0 THEN 'Out of Window / Not Reviewed'
					 WHEN YearThreeNotInWindow IS NULL AND YearThreeNotReviewed IS NULL THEN 'Missing'
				END
		END
	END	AS YearThreeFailureReason,

	CASE WHEN YearFourASQCount < 1 THEN
		CASE
			WHEN TCAgeInDays > 1460 THEN
				CASE WHEN YearFourNotInWindow > 0 AND YearFourNotReviewed IS NULL THEN 'Out of Window'
					 WHEN YearFourNotInWindow IS NULL AND YearFourNotReviewed > 0 THEN 'Not Reviewed' 
					 WHEN YearFourNotInWindow > 0 AND YearFourNotReviewed > 0 THEN 'Out of Window / Not Reviewed'
					 WHEN YearFourNotInWindow IS NULL AND YearFourNotReviewed IS NULL THEN 'Missing'
				END 
		END
	END AS YearFiveFailureReason,

	CASE WHEN YearFiveASQCount < 1 THEN
		CASE
			WHEN TCAgeInDays > 1825 THEN
				CASE WHEN YearFiveNotInWindow > 0 AND YearFiveNotReviewed IS NULL THEN 'Out of Window'
					 WHEN YearFiveNotInWindow IS NULL AND YearFiveNotReviewed > 0 THEN 'Not Reviewed' 
					 WHEN YearFiveNotInWindow > 0 AND YearFiveNotReviewed > 0 THEN 'Out of Window / Not Reviewed'
					 WHEN YearFiveNotInWindow IS NULL AND YearFiveNotReviewed IS NULL THEN 'Missing'
				END 
		END
	END AS YearFiveFailureReason

FROM @Cohort
WHERE 
	--TCs less than two years old can only fail on Year 1 ASQs
	(TCAgeInDays BETWEEN 0 AND 730 AND YearOneASQCount < 2)
	OR
	--TCs less than three years old can only fail on Year 1, 2 ASQs
	(TCAgeInDays BETWEEN 731 AND 1095 AND (YearOneASQCount < 2 OR YearTwoASQCount < 2))
	OR
	--TCs less than four years old can only fail on Year 1, 2, 3 ASQs
	(TCAgeInDays BETWEEN 1096 AND 1460 AND (YearOneASQCount < 2 OR YearTwoASQCount < 2 OR YearThreeASQCount < 2))
	OR
	--TCs less than five years old can only fail on Year 1, 2, 3, 4 ASQs
	(TCAgeInDays BETWEEN 1461 AND 1825 AND (YearOneASQCount < 2 OR YearTwoASQCount < 2 OR YearThreeASQCount < 2 OR YearFourASQCount < 1))
	OR
	--TCs greater than five years old can fail in any period 
	(TCAgeInDays >= 1826 AND (YearOneASQCount < 2 OR YearTwoASQCount < 2 OR YearThreeASQCount < 2 OR YearFourASQCount < 1 OR YearFiveASQCount < 1))

IF @ReportType = 'summary'

BEGIN 

DECLARE @Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[MissingCases] [varchar](200),
	[NotOnTimeCases] [varchar](200),
	[SummaryTotal] [varchar](100)
)

DECLARE @TotalTC INT = (SELECT COUNT(DISTINCT TCIDPK) FROM @Cohort)

DECLARE @TotalOutOfWindowOrNotReviewed INT = (
	SELECT COUNT(DISTINCT TCIDPK) 
	FROM @Details 
	WHERE
		(YearOneFailureReason IS NOT NULL AND YearOneFailureReason <> 'Missing')
		OR
		(YearTwoFailureReason IS NOT NULL AND YearTwoFailureReason <> 'Missing')
		OR
		(YearThreeFailureReason IS NOT NULL AND YearThreeFailureReason <> 'Missing')
		OR
		(YearFourFailureReason IS NOT NULL AND YearFourFailureReason <> 'Missing')
		OR
		(YearFiveFailureReason IS NOT NULL AND YearFiveFailureReason <> 'Missing')
)

DECLARE @TotalMissing INT = ( 
	SELECT COUNT(DISTINCT TCIDPK)
	FROM @Details
	WHERE
	  YearOneFailureReason = 'Missing'
	  OR
	  YearTwoFailureReason = 'Missing'
	  OR
	  YearThreeFailureReason = 'Missing'
	  OR
	  YearFourFailureReason = 'Missing'
	  OR
	  YearFiveFailureReason = 'Missing'
	)

INSERT INTO @Summary([SummaryId],[SummaryText],[MissingCases],[NotOnTimeCases],[SummaryTotal])
VALUES(
	7 ,
	'ASQs for Active Cases with Target Child 12 months or older, calc. DOB (N=' + CONVERT(VARCHAR, @TotalTC) + ')',
	CONVERT(VARCHAR, @TotalMissing) + 
		CASE WHEN @TotalTC > 0 THEN '(' +  CONVERT(VARCHAR, ROUND(CONVERT(FLOAT, @TotalMissing) / @TotalTC * 100, 0, 0)) + '%)' ELSE '' END,

	CONVERT(VARCHAR, @TotalOutOfWindowOrNotReviewed) + 
		CASE WHEN @TotalTC > 0 
			 THEN '(' +  CONVERT(VARCHAR, ROUND(CONVERT(FLOAT, @TotalOutOfWindowOrNotReviewed) / @TotalTC * 100, 0, 0)) + '%)' 
		ELSE '' END,

	CONVERT(VARCHAR, @TotalMissing + @TotalOutOfWindowOrNotReviewed) + 
		CASE 
			WHEN @TotalTC > 0 
			THEN '(' +  CONVERT(VARCHAR, ROUND(CONVERT(FLOAT, @TotalMissing +	@TotalOutOfWindowOrNotReviewed) / @TotalTC * 100, 0, 0)) + '%)' 
		ELSE '' END
)

	SELECT * FROM @Summary

	END
ELSE

SELECT 
	PC1ID,
	TCName,
	Worker,
	GestationalAge,
	CurrentLevel,
	CONVERT(VARCHAR, TCDOB, 101) AS TCDOB,
	CONVERT(VARCHAR, CalcDOB, 101) AS CalcDOB,
	TCAgeInDays,
	CASE WHEN YearOneFailureReason IS NOT NULL THEN 'Year 1: ' + YearOneFailureReason + '<br/>' ELSE '' END +
	CASE WHEN YearTwoFailureReason IS NOT NULL THEN 'Year 2: ' + YearTwoFailureReason + '<br/>' ELSE '' END +
	CASE WHEN YearThreeFailureReason IS NOT NULL THEN 'Year 3: ' + YearThreeFailureReason + '<br/>' ELSE '' END +
	CASE WHEN YearFourFailureReason IS NOT NULL THEN 'Year 4: ' + YearFourFailureReason + '<br/>' ELSE '' END +
	CASE WHEN YearFiveFailureReason IS NOT NULL THEN 'Year 5: ' + YearFiveFailureReason + '<br/>' ELSE '' END As [Reason Not Meeting]	
FROM @Details	


GO
