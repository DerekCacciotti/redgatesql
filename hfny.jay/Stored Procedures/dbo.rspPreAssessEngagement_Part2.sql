SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Aug 13, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement_Part2]
(
    @programfk    int      = null,
    @StartDtT     DATETIME = NULL,
    @StartDt      DATETIME = null,
    @EndDt        DATETIME = null
)
as

-- Pre-Assessment Engagement Quartly Report --
--DECLARE @StartDtT DATE = '01/01/2011'
--DECLARE @StartDt DATE = '08/01/2011'
--DECLARE @EndDt DATE = '12/31/2011'
--DECLARE @programfk INT = 6

;WITH base1 AS (
SELECT d.DischargeCode, d.DischargeReason
, CASE WHEN xx.TerminatedNotAssigned IS NULL THEN 0 ELSE xx.TerminatedNotAssigned END [t1]
, CASE WHEN xxx.SSTerminatedNotAssigned IS NULL THEN 0 ELSE xxx.SSTerminatedNotAssigned END [t2]
, CASE WHEN yy.PositiveNotAssigned IS NULL THEN 0 ELSE yy.PositiveNotAssigned END [t3]
, CASE WHEN yyy.SSPositiveNotAssigned IS NULL THEN 0 ELSE yyy.SSPositiveNotAssigned END [t4]

FROM codeDischarge AS d
LEFT OUTER JOIN
(SELECT x.DischargeReason, count(*) [TerminatedNotAssigned]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
WHERE p.PADate BETWEEN @StartDt AND @EndDt AND p.ProgramFK = @programfk
AND p.CaseStatus = '03'
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
GROUP BY x.DischargeReason) AS xx
ON xx.DischargeReason = d.DischargeCode
--
LEFT OUTER JOIN
(SELECT x.DischargeReason, count(*) [PositiveNotAssigned]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
WHERE p.PADate BETWEEN @StartDt AND @EndDt AND p.ProgramFK = @programfk
AND p.CaseStatus = '04'
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
GROUP BY x.DischargeReason) AS yy
ON yy.DischargeReason = d.DischargeCode
--
LEFT OUTER JOIN
(SELECT x.DischargeReason, count(*) [SSTerminatedNotAssigned]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
WHERE p.PADate BETWEEN @StartDtT AND @EndDt AND p.ProgramFK = @programfk
AND p.CaseStatus = '03'
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
GROUP BY x.DischargeReason) AS xxx
ON xxx.DischargeReason = d.DischargeCode
--
LEFT OUTER JOIN
(SELECT x.DischargeReason, count(*) [SSPositiveNotAssigned]
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
WHERE p.PADate BETWEEN @StartDtT AND @EndDt AND p.ProgramFK = @programfk
AND p.CaseStatus = '04'
GROUP BY p.HVCaseFK) AS y 
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
GROUP BY x.DischargeReason) AS yyy
ON yyy.DischargeReason = d.DischargeCode
WHERE d.DischargeUsedWhere LIKE '%PA%'
)

, base2 AS (
SELECT 
  CASE WHEN b.s1 = 0 THEN 1 ELSE b.s1 END s1
, CASE WHEN b.s2 = 0 THEN 1 ELSE b.s2 END s2
, CASE WHEN b.s3 = 0 THEN 1 ELSE b.s3 END s3
, CASE WHEN b.s4 = 0 THEN 1 ELSE b.s4 END s4
FROM (
SELECT sum(a.t1) [s1]
, sum(a.t2) [s2]
, sum(a.t3) [s3]
, sum(a.t4) [s4]
FROM base1 AS a
) AS b
)

SELECT a.DischargeReason
, a.t1
, cast(cast(CASE WHEN b.s1 > 0 THEN round(100.0 * a.t1 / b.s1, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' p1
, a.t2
, cast(cast(CASE WHEN b.s2 > 0 THEN round(100.0 * a.t2 / b.s2, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' p2
, a.t3
, cast(cast(CASE WHEN b.s3 > 0 THEN round(100.0 * a.t3 / b.s3, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' p3
, a.t4
, cast(cast(CASE WHEN b.s4 > 0 THEN round(100.0 * a.t4 / b.s4, 0) 
ELSE 0 END AS INT) AS VARCHAR(20)) + '%' p4
, s1,s2,s3,s4
FROM base1 AS a
CROSS JOIN base2 AS b
ORDER BY a.DischargeCode






















GO
