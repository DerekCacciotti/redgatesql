
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 16, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement]
(
    @programfk    VARCHAR(MAX) = null,
    @StartDtT     DATETIME = NULL,
    @StartDt      DATETIME = null,
    @EndDt        DATETIME = null
)
as

if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
set @programfk = replace(@programfk,'"','')
	
--Pre-Assessment Engagement Quartly Report --
--DECLARE @StartDtT DATE = '09/01/2012'
--DECLARE @StartDt DATE = '09/01/2012'
--DECLARE @EndDt DATE = '11/30/2012'
--DECLARE @programfk INT = 4

; WITH 
section1QX AS
(SELECT 
  sum(1) [Q1Screened]
, sum(CASE WHEN c.ScreenResult = 1 THEN 1 ELSE 0 END) [Q1aScreenResultPositive]
, sum(CASE WHEN c.ScreenResult != 1 THEN 1 ELSE 0 END) [Q1bScreenResultNegative]
, sum(CASE WHEN isnull(a.TCDOB, a.EDC) > a.ScreenDate THEN 1 ELSE 0 END) [Q1cPrenatal]
, sum(CASE WHEN isnull(a.TCDOB, a.EDC) <= a.ScreenDate THEN 1 ELSE 0 END) [Q1dPostnatal]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 1  THEN 1 ELSE 0 END) [Q1ePositiveReferred]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0  THEN 1 ELSE 0 END) [Q1fPositiveNotReferred]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason IN ('05','07','11','06','08','33','34','99','13','25')
THEN 1 ELSE 0 END) [Q1DischargeAll]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '05' THEN 1 ELSE 0 END) [Q1f1IncomeIneligible]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '07' THEN 1 ELSE 0 END) [Q1f2OutOfGeoTarget]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '11' THEN 1 ELSE 0 END) [Q1f3Refuse]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '06' THEN 1 ELSE 0 END) [Q1f4InappropriateScreen]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '08' THEN 1 ELSE 0 END) [Q1f5CaseLoadFull]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '33' THEN 1 ELSE 0 END) [Q1f6PositiveScreen]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '34' THEN 1 ELSE 0 END) [Q1f7SubsequentBirthOnOpenCase]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '99' THEN 1 ELSE 0 END) [Q1f8Other]
, 0 [Q1f9NoReason]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '13' THEN 1 ELSE 0 END) [Q1f10ControlCase]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '25' THEN 1 ELSE 0 END) [Q1f11Transferred]
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
JOIN HVScreen AS c ON a.HVCasePK = c.HVCaseFK
WHERE a.ScreenDate BETWEEN @StartDt AND @EndDt --AND b.ProgramFK = @programfk
)

, section1Q AS
(
SELECT a.Q1Screened
,cast(cast(CASE WHEN a.Q1Screened > 0 THEN round(100.0 * Q1aScreenResultPositive / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1aScreenResultPositive]
,cast(cast(CASE WHEN a.Q1Screened > 0 THEN round(100.0 * Q1bScreenResultNegative / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1bScreenResultNegative]
,cast(cast(CASE WHEN a.Q1Screened > 0 THEN round(100.0 * Q1cPrenatal / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1cPrenatal]
,cast(cast(CASE WHEN a.Q1Screened > 0 THEN round(100.0 * Q1dPostnatal / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1dPostnatal]
, Q1ePositiveReferred
, Q1fPositiveNotReferred
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f1IncomeIneligible / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f1IncomeIneligible
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f2OutOfGeoTarget / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f2OutOfGeoTarget
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f3Refuse / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f3Refuse
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f4InappropriateScreen / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f4InappropriateScreen
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f5CaseLoadFull / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f5CaseLoadFull
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f6PositiveScreen / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f6PositiveScreen
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f7SubsequentBirthOnOpenCase / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f7SubsequentBirthOnOpenCase
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f8Other / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f8Other
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f9NoReason / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f9NoReason
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f10ControlCase / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f10ControlCase
,cast(cast(CASE WHEN a.Q1DischargeAll > 0 THEN round(100.0 * Q1f11Transferred / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f11Transferred

FROM section1QX AS a

)
, section2Q AS 
(
SELECT count(*) [Q2PreAssessmentBeforePeriod]
FROM HVCase AS a1 
JOIN CaseProgram AS b1 ON a1.HVCasePK = b1.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b1.programfk = listitem
WHERE --b1.ProgramFK = @programfk AND 
(a1.ScreenDate < @StartDt) 
AND (a1.KempeDate >= @StartDt OR a1.KempeDate IS NULL)
AND (b1.DischargeDate >= @StartDt OR b1.DischargeDate IS NULL)
)

, section4Qa AS 
(
SELECT 
sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [Q4aEffortContnue]
, sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) > 30 THEN 1 ELSE 0 END) [Q4dNoStatus1]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
JOIN dbo.SplitString(@programfk,',') on p.programfk = listitem
WHERE p.PADate <= @EndDt --AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
)

, section4Qb AS 
(
SELECT count(DISTINCT a.HVCaseFK) [Q4dNoStatus2]
FROM HVScreen AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on c.programfk = listitem
LEFT OUTER JOIN Preassessment AS b ON b.HVCaseFK = a.HVCaseFK AND b.PADate <= @EndDt
WHERE --a.ProgramFK = @programfk AND 
a.ScreenDate <= @EndDt AND a.ScreenResult = '1' AND a.ReferralMade = '1'
AND (c.DischargeDate IS NULL OR c.DischargeDate > @StartDt)
AND b.HVCaseFK IS NULL
)

, section4Q AS 
(
SELECT 
--sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [Q4aEffortContnue]
--, sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) > 30 THEN 1 ELSE 0 END) [Q4dNoStatus1]
sum(CASE WHEN x.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) [Q4bCompleted]
, sum(CASE WHEN x.CaseStatus = '02' AND x.KempeResult = 1 AND x.FSWAssignDate <= @EndDt THEN 1 ELSE 0 END) [Q4b1PositiveAssignd]
, sum(CASE WHEN  x.CaseStatus = '02' AND x.KempeResult = 1 AND x.FSWAssignDate > @EndDt THEN 1 ELSE 0 END) [Q4b2PositivePendingAssignd]
, sum(CASE WHEN  x.CaseStatus = '04'  AND x.KempeResult = 1 AND x.FSWAssignDate IS NULL THEN 1 ELSE 0 END) [Q4b3PositiveNotAssignd]
, sum(CASE WHEN x.CaseStatus = '02' AND x.KempeResult = 0 THEN 1 ELSE 0 END) [Q4b4Negative]
, sum(CASE WHEN x.CaseStatus = '03' THEN 1 ELSE 0 END) [Q4cTerminated]
--, 0 [Q4dNoStatus]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
JOIN dbo.SplitString(@programfk,',') on p.programfk = listitem
WHERE p.PADate BETWEEN @StartDt AND @EndDt --AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
)

--, zzz AS (
--SELECT DISTINCT x.HVCaseFK
--FROM Preassessment AS x
--JOIN (SELECT a.HVCaseFK, max(a.PADate) [maxDate]
--FROM Preassessment AS a
--WHERE a.ProgramFK = @programfk AND a.PADate < @StartDt
--GROUP BY a.HVCaseFK) AS y
--ON x.HVCaseFK = y.HVCaseFK AND x.PADate = maxDate
--WHERE x.CaseStatus = '01')

--, qqq AS (
--SELECT DISTINCT a.HVCaseFK
--FROM Preassessment AS a
--WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
--)

--, NoStatus AS (
--SELECT count(*) [Q4dNoStatus2]
--FROM zzz AS a LEFT OUTER JOIN qqq AS b ON a.HVCaseFK = b.HVCaseFK
--WHERE b.HVCaseFK IS NULL
--)

, section5Q AS 
(
SELECT 
  sum(PAParentLetter) [Q5aPAParentLetter]
, sum(PACall2Parent) [Q5bPACall2Parent]
, sum(PACallFromParent) [Q5cPACallFromParent]
, sum(PAVisitAttempt) [Q5dPAVisitAttempt]
, sum(PAVisitMade) [Q5ePAVisitMade]
, sum(PAOtherHVProgram) [Q5fPAOtherHVProgram]
, sum(PAParent2Office) [Q5gPAParent2Office]
, sum(PAProgramMaterial) [Q5hPAProgramMaterial]
, sum(PAGift) [Q5iPAGift]
, sum(PACaseReview) [Q5jPACaseReview]
, sum(PAOtherActivity) [Q5kPAOtherActivity]
FROM Preassessment AS b
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
WHERE PADate BETWEEN @StartDt AND @EndDt --AND ProgramFK = @programfk
)

-- total
,
section1TX AS
(SELECT 
  sum(1) [T1Screened]
, sum(CASE WHEN c.ScreenResult = 1 THEN 1 ELSE 0 END) [T1aScreenResultPositive]
, sum(CASE WHEN c.ScreenResult != 1 THEN 1 ELSE 0 END) [T1bScreenResultNegative]
, sum(CASE WHEN isnull(a.TCDOB, a.EDC) > a.ScreenDate THEN 1 ELSE 0 END) [T1cPrenatal]
, sum(CASE WHEN isnull(a.TCDOB, a.EDC) <= a.ScreenDate THEN 1 ELSE 0 END) [T1dPostnatal]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 1  THEN 1 ELSE 0 END) [T1ePositiveReferred]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0  THEN 1 ELSE 0 END) [T1fPositiveNotReferred]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason IN ('05','07','11','06','08','33','34','99','13','25')
THEN 1 ELSE 0 END) [T1DischargeAll]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '05' THEN 1 ELSE 0 END) [T1f1IncomeIneligible]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '07' THEN 1 ELSE 0 END) [T1f2OutOfGeoTarget]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '11' THEN 1 ELSE 0 END) [T1f3Refuse]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '06' THEN 1 ELSE 0 END) [T1f4InappropriateScreen]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '08' THEN 1 ELSE 0 END) [T1f5CaseLoadFull]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '33' THEN 1 ELSE 0 END) [T1f6PositiveScreen]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '34' THEN 1 ELSE 0 END) [T1f7SubsequentBirthOnOpenCase]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '99' THEN 1 ELSE 0 END) [T1f8Other]
, 0 [T1f9NoReason]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '13' THEN 1 ELSE 0 END) [T1f10ControlCase]
, sum(CASE WHEN c.ScreenResult = 1 AND c.ReferralMade = 0 
AND c.DischargeReason = '25' THEN 1 ELSE 0 END) [T1f11Transferred]
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
JOIN HVScreen AS c ON a.HVCasePK = c.HVCaseFK
WHERE a.ScreenDate BETWEEN @StartDtT AND @EndDt --AND b.ProgramFK = @programfk
)

, section1T AS
(
SELECT a.T1Screened
,cast(cast(CASE WHEN a.T1Screened > 0 THEN round(100.0 * T1aScreenResultPositive / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1aScreenResultPositive]
,cast(cast(CASE WHEN a.T1Screened > 0 THEN round(100.0 * T1bScreenResultNegative / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1bScreenResultNegative]
,cast(cast(CASE WHEN a.T1Screened > 0 THEN round(100.0 * T1cPrenatal / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1cPrenatal]
,cast(cast(CASE WHEN a.T1Screened > 0 THEN round(100.0 * T1dPostnatal / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1dPostnatal]
, T1ePositiveReferred
, T1fPositiveNotReferred
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f1IncomeIneligible / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f1IncomeIneligible
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f2OutOfGeoTarget / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f2OutOfGeoTarget
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f3Refuse / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f3Refuse
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f4InappropriateScreen / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f4InappropriateScreen
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f5CaseLoadFull / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f5CaseLoadFull
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f6PositiveScreen / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f6PositiveScreen
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f7SubsequentBirthOnOpenCase / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f7SubsequentBirthOnOpenCase
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f8Other / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f8Other
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f9NoReason / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f9NoReason
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f10ControlCase / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f10ControlCase
,cast(cast(CASE WHEN a.T1DischargeAll > 0 THEN round(100.0 * T1f11Transferred / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f11Transferred

FROM section1TX AS a

)
, section2T AS 
(
SELECT count(*) [T2PreAssessmentBeforePeriod]
FROM HVCase AS a1 
JOIN CaseProgram AS b1 ON a1.HVCasePK = b1.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b1.programfk = listitem
WHERE --b1.ProgramFK = @programfk AND 
(a1.ScreenDate < @StartDtT) 
AND (a1.KempeDate >= @StartDtT OR a1.KempeDate IS NULL)
AND (b1.DischargeDate >= @StartDtT OR b1.DischargeDate IS NULL)
)


, section4Ta AS 
(
SELECT 
sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [T4aEffortContnue]
, sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) > 30 THEN 1 ELSE 0 END) [T4dNoStatus1]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
JOIN dbo.SplitString(@programfk,',') on p.programfk = listitem
WHERE p.PADate <= @EndDt --AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
)

, section4Tb AS 
(
SELECT count(DISTINCT a.HVCaseFK) [T4dNoStatus2]
FROM HVScreen AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on c.programfk = listitem
LEFT OUTER JOIN Preassessment AS b ON b.HVCaseFK = a.HVCaseFK AND b.PADate <= @EndDt
WHERE --a.ProgramFK = @programfk AND 
a.ScreenDate <= @EndDt AND a.ScreenResult = '1' AND a.ReferralMade = '1'
AND (c.DischargeDate IS NULL OR c.DischargeDate > @StartDtT)
AND b.HVCaseFK IS NULL
)

, section4T AS 
(
SELECT 
--sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [T4aEffortContnue]
--, sum(CASE WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) > 30 THEN 1 ELSE 0 END) [T4dNoStatus1]
sum(CASE WHEN x.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) [T4bCompleted]
, sum(CASE WHEN x.CaseStatus = '02' AND x.KempeResult = 1 AND x.FSWAssignDate <= @EndDt THEN 1 ELSE 0 END) [T4b1PositiveAssignd]
, sum(CASE WHEN  x.CaseStatus = '02' AND x.KempeResult = 1 AND x.FSWAssignDate > @EndDt THEN 1 ELSE 0 END) [T4b2PositivePendingAssignd]
, sum(CASE WHEN  x.CaseStatus = '04'  AND x.KempeResult = 1 AND x.FSWAssignDate IS NULL THEN 1 ELSE 0 END) [T4b3PositiveNotAssignd]
, sum(CASE WHEN x.CaseStatus = '02' AND x.KempeResult = 0 THEN 1 ELSE 0 END) [T4b4Negative]
, sum(CASE WHEN x.CaseStatus = '03' THEN 1 ELSE 0 END) [T4cTerminated]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
JOIN dbo.SplitString(@programfk,',') on p.programfk = listitem
WHERE p.PADate BETWEEN @StartDtT AND @EndDt --AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
)

--, zzzT AS (
--SELECT DISTINCT x.HVCaseFK
--FROM Preassessment AS x
--JOIN (SELECT a.HVCaseFK, max(a.PADate) [maxDate]
--FROM Preassessment AS a
--WHERE a.ProgramFK = @programfk AND a.PADate < @StartDtT
--GROUP BY a.HVCaseFK) AS y
--ON x.HVCaseFK = y.HVCaseFK AND x.PADate = maxDate
--WHERE x.CaseStatus = '01')

--, qqqT AS (
--SELECT DISTINCT a.HVCaseFK
--FROM Preassessment AS a
--WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDtT AND @EndDt
--)

--, NoStatusT AS (
--SELECT count(*) [T4dNoStatus2]
--FROM zzzT AS a LEFT OUTER JOIN qqqT AS b ON a.HVCaseFK = b.HVCaseFK
--WHERE b.HVCaseFK IS NULL
--)

, section5T AS 
(
SELECT 
  sum(PAParentLetter) [T5aPAParentLetter]
, sum(PACall2Parent) [T5bPACall2Parent]
, sum(PACallFromParent) [T5cPACallFromParent]
, sum(PAVisitAttempt) [T5dPAVisitAttempt]
, sum(PAVisitMade) [T5ePAVisitMade]
, sum(PAOtherHVProgram) [T5fPAOtherHVProgram]
, sum(PAParent2Office) [T5gPAParent2Office]
, sum(PAProgramMaterial) [T5hPAProgramMaterial]
, sum(PAGift) [T5iPAGift]
, sum(PACaseReview) [T5jPACaseReview]
, sum(PAOtherActivity) [T5kPAOtherActivity]
FROM Preassessment AS p
JOIN dbo.SplitString(@programfk,',') on p.programfk = listitem
WHERE PADate BETWEEN @StartDtT AND @EndDt --AND ProgramFK = @programfk
)

SELECT 
  section1Q.* 
, section2Q.*
, section1Q.[Q1ePositiveReferred] + section2Q.[Q2PreAssessmentBeforePeriod] [Q3TotalCasesThisPerion]
, section4Q.*
, section4Qa.*
, section4Qb.*
, [Q4dNoStatus1] + [Q4dNoStatus2] AS [Q4dNoStatus]
, section5Q.*
, section1T.* 
, section2T.*
, section1T.[T1ePositiveReferred] + section2T.[T2PreAssessmentBeforePeriod] [T3TotalCasesThisPerion]
, section4T.*
, section4Ta.*
, section4Tb.*
, [T4dNoStatus1] + [T4dNoStatus2] AS [T4dNoStatus]
, section5T.*

FROM section1Q
join section2Q ON 1 = 1
join section4Q ON 1 = 1
join section4Qa ON 1 = 1
join section4Qb ON 1 = 1
join section5Q ON 1 = 1
join section1T ON 1 = 1
join section2T ON 1 = 1
join section4T ON 1 = 1
join section4Ta ON 1 = 1
join section4Tb ON 1 = 1
join section5T ON 1 = 1
























GO
