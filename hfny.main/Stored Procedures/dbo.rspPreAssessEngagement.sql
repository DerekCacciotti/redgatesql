
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 16, 2012>
-- Description: 
-- exec rspPreAssessEngagement 19, '07/01/2012', '07/01/2012', '09/30/2012'
-- exec rspPreAssessEngagement 5, '07/01/2012', '07/01/2012', '09/30/2012'

-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement]
(
    @programfk    VARCHAR(MAX) = null,
    @StartDtT     DATETIME = NULL,
    @StartDt      DATETIME = null,
    @EndDt        DATETIME = null,
    @IncludeClosedCase BIT = 0
)
as

--DECLARE @StartDtT DATE = '01/01/2012'
--DECLARE @StartDt DATE = '09/01/2012'
--DECLARE @EndDt DATE = '11/30/2012'
--DECLARE @programfk INT = 4
--DECLARE @IncludeClosedCase BIT = 1

if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
set @programfk = replace(@programfk,'"','')

; WITH 

ScreensThisPeriod AS (
SELECT a.HVCasePK, c.ScreenResult, isnull(a.TCDOB, a.EDC) DOB
, a.ScreenDate, c.ReferralMade, c.DischargeReason 
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
JOIN HVScreen AS c ON a.HVCasePK = c.HVCaseFK
WHERE a.ScreenDate BETWEEN @StartDt AND @EndDt
),

ScreensThisPeriod_1e AS (
SELECT HVCasePK
FROM ScreensThisPeriod
WHERE ScreenResult = 1 AND ReferralMade = 1
),

PreAssessmentCasesAtBeginningOfPeriod AS (
SELECT distinct a.HVCasePK 
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
WHERE (a.ScreenDate < @StartDt) 
AND (a.KempeDate >= @StartDt OR a.KempeDate IS NULL)
AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt)
),

section2Q AS (
SELECT count(*) [Q2PreAssessmentBeforePeriod]
FROM PreAssessmentCasesAtBeginningOfPeriod
),

TotalCasesToBeAssessedThisPeriod_2_1e AS (
SELECT DISTINCT isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
FROM PreAssessmentCasesAtBeginningOfPeriod AS a
FULL OUTER JOIN ScreensThisPeriod_1e AS b 
ON a.HVCasePK = b.HVCasePK
),

PreAssessment_MaxPADate AS (
SELECT a.HVCaseFK, max(a.PADate) [max_PADATE]
FROM Preassessment AS a
JOIN dbo.SplitString(@programfk,',') on a.programfk = listitem
WHERE a.PADate BETWEEN @StartDt AND @EndDt 
GROUP BY a.HVCaseFK
),

PreAssessment_LastOneInPeriod AS (
SELECT a.HVCaseFK, a.CaseStatus, a.FSWAssignDate, a.KempeResult, a.PADate
FROM Preassessment as a 
join PreAssessment_MaxPADate as b 
ON a.HVCaseFK = b.HVCaseFK AND a.PADate = b.max_PADATE
),

Outcomes AS (
SELECT a.HVCasePK, b.*
FROM TotalCasesToBeAssessedThisPeriod_2_1e AS a
LEFT OUTER JOIN PreAssessment_LastOneInPeriod AS b
ON a.HVCasePK = b.HVCaseFK
),

section4Q AS (
SELECT 
  Count(*) [Q3TotalCasesThisPerion]

, sum(CASE WHEN CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) [Q4bCompleted]
, sum(CASE WHEN CaseStatus = '02' AND KempeResult = 1 AND FSWAssignDate <= @EndDt THEN 1 ELSE 0 END) [Q4b1PositiveAssignd]
, sum(CASE WHEN  CaseStatus = '02' AND KempeResult = 1 AND FSWAssignDate > @EndDt THEN 1 ELSE 0 END) [Q4b2PositivePendingAssignd]
, sum(CASE WHEN  CaseStatus = '04'  AND KempeResult = 1 AND FSWAssignDate IS NULL THEN 1 ELSE 0 END) [Q4b3PositiveNotAssignd]
, sum(CASE WHEN CaseStatus = '02' AND KempeResult = 0 THEN 1 ELSE 0 END) [Q4b4Negative]
, sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [Q4cTerminated]
, sum(CASE WHEN CaseStatus = '01' AND datediff( d, PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [Q4aEffortContnue]
FROM Outcomes
),

section1QX AS (
SELECT 
  sum(1) [Q1Screened]
, sum(CASE WHEN ScreenResult = 1 THEN 1 ELSE 0 END) [Q1aScreenResultPositive]
, sum(CASE WHEN ScreenResult != 1 THEN 1 ELSE 0 END) [Q1bScreenResultNegative]
, sum(CASE WHEN DOB > ScreenDate THEN 1 ELSE 0 END) [Q1cPrenatal]
, sum(CASE WHEN DOB <= ScreenDate THEN 1 ELSE 0 END) [Q1dPostnatal]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 1  THEN 1 ELSE 0 END) [Q1ePositiveReferred]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0  THEN 1 ELSE 0 END) [Q1fPositiveNotReferred]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason IN ('05','07','35','36','06','08','33','34','99','13','25')
THEN 1 ELSE 0 END) [Q1DischargeAll]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '05' THEN 1 ELSE 0 END) [Q1f1IncomeIneligible]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '07' THEN 1 ELSE 0 END) [Q1f2OutOfGeoTarget]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '35' THEN 1 ELSE 0 END) [Q1f3NonCompliant]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '36' THEN 1 ELSE 0 END) [Q1f3Refuse]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '06' THEN 1 ELSE 0 END) [Q1f4InappropriateScreen]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '08' THEN 1 ELSE 0 END) [Q1f5CaseLoadFull]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '33' THEN 1 ELSE 0 END) [Q1f6PositiveScreen]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '34' THEN 1 ELSE 0 END) [Q1f7SubsequentBirthOnOpenCase]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '99' THEN 1 ELSE 0 END) [Q1f8Other]
, 0 [Q1f9NoReason]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '13' THEN 1 ELSE 0 END) [Q1f10ControlCase]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '25' THEN 1 ELSE 0 END) [Q1f11Transferred]
FROM ScreensThisPeriod
),

section1Q AS
(
SELECT Q1Screened
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1aScreenResultPositive / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1aScreenResultPositive]
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1bScreenResultNegative / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1bScreenResultNegative]
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1cPrenatal / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1cPrenatal]
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1dPostnatal / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1dPostnatal]
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1ePositiveReferred / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1ePositiveReferredPercent]
, Q1ePositiveReferred
,cast(cast(CASE WHEN Q1Screened > 0 THEN round(100.0 * Q1fPositiveNotReferred / Q1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [Q1fPositiveNotReferredPercent]
, Q1fPositiveNotReferred
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f1IncomeIneligible / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f1IncomeIneligible
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f2OutOfGeoTarget / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f2OutOfGeoTarget
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f3NonCompliant / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f3NonCompliant
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f3Refuse / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f3Refuse
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f4InappropriateScreen / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f4InappropriateScreen
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f5CaseLoadFull / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f5CaseLoadFull
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f6PositiveScreen / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f6PositiveScreen
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f7SubsequentBirthOnOpenCase / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f7SubsequentBirthOnOpenCase
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f8Other / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f8Other
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f9NoReason / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f9NoReason
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f10ControlCase / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f10ControlCase
,cast(cast(CASE WHEN Q1DischargeAll > 0 THEN round(100.0 * Q1f11Transferred / Q1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' Q1f11Transferred
FROM section1QX
),

section5Q AS 
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
FROM Preassessment
JOIN dbo.SplitString(@programfk,',') on programfk = listitem
WHERE PADate BETWEEN @StartDt AND @EndDt
),

/* total */
ScreensThisPeriodT AS (
SELECT a.HVCasePK, c.ScreenResult, isnull(a.TCDOB, a.EDC) DOB
, a.ScreenDate, c.ReferralMade, c.DischargeReason 
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
JOIN HVScreen AS c ON a.HVCasePK = c.HVCaseFK
WHERE a.ScreenDate BETWEEN @StartDtT AND @EndDt
),

ScreensThisPeriod_1eT AS (
SELECT HVCasePK
FROM ScreensThisPeriodT
WHERE ScreenResult = 1 AND ReferralMade = 1
),

PreAssessmentCasesAtBeginningOfPeriodT AS (
SELECT distinct a.HVCasePK 
FROM HVCase AS a 
JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
WHERE (a.ScreenDate < @StartDtT) 
AND (a.KempeDate >= @StartDtT OR a.KempeDate IS NULL)
AND (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDtT)
),

section2QT AS (
SELECT count(*) [T2PreAssessmentBeforePeriod]
FROM PreAssessmentCasesAtBeginningOfPeriodT
),

TotalCasesToBeAssessedThisPeriod_2_1eT AS (
SELECT DISTINCT isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
FROM PreAssessmentCasesAtBeginningOfPeriodT AS a
FULL OUTER JOIN ScreensThisPeriod_1eT AS b 
ON a.HVCasePK = b.HVCasePK
),

PreAssessment_MaxPADateT AS (
SELECT a.HVCaseFK, max(a.PADate) [max_PADATE]
FROM Preassessment AS a
JOIN dbo.SplitString(@programfk,',') on a.programfk = listitem
WHERE a.PADate BETWEEN @StartDtT AND @EndDt 
GROUP BY a.HVCaseFK
),

PreAssessment_LastOneInPeriodT AS (
SELECT a.HVCaseFK, a.CaseStatus, a.FSWAssignDate, a.KempeResult, a.PADate
FROM Preassessment as a 
join PreAssessment_MaxPADateT as b 
ON a.HVCaseFK = b.HVCaseFK AND a.PADate = b.max_PADATE
),

OutcomesT AS (
SELECT a.HVCasePK, b.*
FROM TotalCasesToBeAssessedThisPeriod_2_1eT AS a
LEFT OUTER JOIN PreAssessment_LastOneInPeriodT AS b
ON a.HVCasePK = b.HVCaseFK
),

section4QT AS (
SELECT 
  Count(*) [T3TotalCasesThisPerion]
, sum(CASE WHEN CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) [T4bCompleted]
, sum(CASE WHEN CaseStatus = '02' AND KempeResult = 1 AND FSWAssignDate <= @EndDt THEN 1 ELSE 0 END) [T4b1PositiveAssignd]
, sum(CASE WHEN  CaseStatus = '02' AND KempeResult = 1 AND FSWAssignDate > @EndDt THEN 1 ELSE 0 END) [T4b2PositivePendingAssignd]
, sum(CASE WHEN  CaseStatus = '04'  AND KempeResult = 1 AND FSWAssignDate IS NULL THEN 1 ELSE 0 END) [T4b3PositiveNotAssignd]
, sum(CASE WHEN CaseStatus = '02' AND KempeResult = 0 THEN 1 ELSE 0 END) [T4b4Negative]
, sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [T4cTerminated]
, sum(CASE WHEN CaseStatus = '01' AND datediff( d, PADate, @EndDt) <= 30 THEN 1 ELSE 0 END) [T4aEffortContnue]
FROM OutcomesT
),


section1QXT AS (
SELECT 
  sum(1) [T1Screened]
, sum(CASE WHEN ScreenResult = 1 THEN 1 ELSE 0 END) [T1aScreenResultPositive]
, sum(CASE WHEN ScreenResult != 1 THEN 1 ELSE 0 END) [T1bScreenResultNegative]
, sum(CASE WHEN DOB > ScreenDate THEN 1 ELSE 0 END) [T1cPrenatal]
, sum(CASE WHEN DOB <= ScreenDate THEN 1 ELSE 0 END) [T1dPostnatal]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 1  THEN 1 ELSE 0 END) [T1ePositiveReferred]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0  THEN 1 ELSE 0 END) [T1fPositiveNotReferred]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason IN ('05','07','35','36','06','08','33','34','99','13','25')
THEN 1 ELSE 0 END) [T1DischargeAll]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '05' THEN 1 ELSE 0 END) [T1f1IncomeIneligible]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '07' THEN 1 ELSE 0 END) [T1f2OutOfGeoTarget]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '35' THEN 1 ELSE 0 END) [T1f3NonCompliant]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '36' THEN 1 ELSE 0 END) [T1f3Refuse]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '06' THEN 1 ELSE 0 END) [T1f4InappropriateScreen]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '08' THEN 1 ELSE 0 END) [T1f5CaseLoadFull]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '33' THEN 1 ELSE 0 END) [T1f6PositiveScreen]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '34' THEN 1 ELSE 0 END) [T1f7SubsequentBirthOnOpenCase]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '99' THEN 1 ELSE 0 END) [T1f8Other]
, 0 [T1f9NoReason]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '13' THEN 1 ELSE 0 END) [T1f10ControlCase]
, sum(CASE WHEN ScreenResult = 1 AND ReferralMade = 0 
AND DischargeReason = '25' THEN 1 ELSE 0 END) [T1f11Transferred]
FROM ScreensThisPeriodT
),

section1QT AS (
SELECT T1Screened
,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1aScreenResultPositive / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1aScreenResultPositive]
,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1bScreenResultNegative / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1bScreenResultNegative]
,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1cPrenatal / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1cPrenatal]
,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1dPostnatal / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1dPostnatal]
, T1ePositiveReferred
, T1fPositiveNotReferred

,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1ePositiveReferred / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1ePositiveReferredPercent]

,cast(cast(CASE WHEN T1Screened > 0 THEN round(100.0 * T1fPositiveNotReferred / T1Screened, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' [T1fPositiveNotReferredPercent]

,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f1IncomeIneligible / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f1IncomeIneligible
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f2OutOfGeoTarget / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f2OutOfGeoTarget
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f3NonCompliant / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f3NonCompliant
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f3Refuse / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f3Refuse
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f4InappropriateScreen / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f4InappropriateScreen
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f5CaseLoadFull / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f5CaseLoadFull
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f6PositiveScreen / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f6PositiveScreen
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f7SubsequentBirthOnOpenCase / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f7SubsequentBirthOnOpenCase
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f8Other / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f8Other
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f9NoReason / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f9NoReason
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f10ControlCase / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f10ControlCase
,cast(cast(CASE WHEN T1DischargeAll > 0 THEN round(100.0 * T1f11Transferred / T1DischargeAll, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' T1f11Transferred
FROM section1QXT
),

section5QT AS (
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
FROM Preassessment
JOIN dbo.SplitString(@programfk,',') on programfk = listitem
WHERE PADate BETWEEN @StartDtT AND @EndDt
),

xxxx AS (
SELECT 
  section1Q.* 
, section2Q.*
, section4Q.*
, 0 [Q4dNoStatus1]
, 0 [Q4dNoStatus2]
, section4Q.Q3TotalCasesThisPerion - ([Q4aEffortContnue] + [Q4bCompleted] + [Q4cTerminated]) AS [Q4dNoStatus]
, section5Q.*

, section1QT.* 
, section2QT.*
, section4QT.*
, 0 [T4dNoStatus1]
, 0 [T4dNoStatus2]
, section4QT.T3TotalCasesThisPerion - ([T4aEffortContnue] + [T4bCompleted] + [T4cTerminated]) AS [T4dNoStatus]
, section5QT.*

FROM section1Q
join section2Q ON 1 = 1
join section4Q ON 1 = 1
join section5Q ON 1 = 1
JOIN section1QT ON 1 = 1
join section2QT ON 1 = 1
join section4QT ON 1 = 1
join section5QT ON 1 = 1

)

SELECT * 
FROM xxxx


GO
