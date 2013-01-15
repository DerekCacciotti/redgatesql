
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Aug 13, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement_Part3]
(
    @programfk    int      = null,
    @StartDtT     DATETIME = NULL,
    @StartDt      DATETIME = null,
    @EndDt        DATETIME = null
)
as

--DECLARE @StartDtT DATE = '09/01/2012'
--DECLARE @StartDt DATE = '09/01/2012'
--DECLARE @EndDt DATE = '11/30/2012'
--DECLARE @programfk INT = 4

-- no status pre-assessment cases (no form this month)
;WITH zzz AS (
SELECT x.HVCaseFK, x.PADate, 'xx' [CaseStatus]
FROM Preassessment AS x
JOIN (SELECT a.HVCaseFK, max(a.PADate) [maxDate]
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate < @StartDt
GROUP BY a.HVCaseFK) AS y
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = maxDate
WHERE x.CaseStatus = '01')
,

qqq AS (
SELECT *
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
)
,
NoStatus AS (
SELECT a.*, '1' [NoStatus]
FROM zzz AS a LEFT OUTER JOIN qqq AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NULL
)
,

No_PreAssessment AS (
SELECT a.HVCaseFK, NULL [PADate], 'xx' [CaseStatus], '1' [NoStatus]
FROM HVScreen AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
LEFT OUTER JOIN Preassessment AS b ON b.HVCaseFK = a.HVCaseFK AND b.PADate <= @EndDt
WHERE a.ProgramFK = @programfk AND a.ScreenDate <= @EndDt AND a.ScreenResult = '1' AND a.ReferralMade = '1'
AND (c.DischargeDate IS NULL OR c.DischargeDate > @StartDt)
AND b.HVCaseFK IS NULL
)
,

AllPreAssessment AS (
SELECT x.HVCaseFK, x.PADate, x.CaseStatus, '0' [NoStatus]
FROM Preassessment AS x
JOIN (SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM PreAssessment AS p 
WHERE p.PADate BETWEEN @StartDt AND @EndDt AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK) AS y
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
UNION ALL
SELECT * FROM NoStatus
UNION ALL
SELECT * FROM No_PreAssessment
)

SELECT b.PC1ID
, Convert(VARCHAR(12), a.ScreenDate, 101) [ScreenDate]
, Convert(VARCHAR(12), x.PADate, 101) [PADate]
, x.HVCaseFK
, CASE WHEN x.NoStatus = '1' THEN 'No Status'
WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) <= 30 THEN  'Engagement Continue'
WHEN x.CaseStatus = '01' AND datediff( d, x.PADate, @EndDt) > 30 THEN  'No Status'
WHEN x.CaseStatus = '02' THEN 'Positive, Assigned'
WHEN x.CaseStatus = '03' THEN 'Terminated'
WHEN x.CaseStatus = '04' THEN 'Positive, Not Assigned'
ELSE 'No Status' END [CaseStatusText]
, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) [WorkName]

FROM AllPreAssessment x
JOIN HVCase AS a ON x.HVCaseFK = a.HVCasePK
JOIN CaseProgram AS b ON b.HVCaseFK = x.HVCaseFK
JOIN Worker AS w ON w.WorkerPK = b.CurrentFAWFK

ORDER BY [WorkName], b.PC1ID





GO
