SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part5] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 6

-- no status pre-assessment cases (no form this month)
;WITH zzz AS (
SELECT x.*
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
SELECT a.*
FROM zzz AS a LEFT OUTER JOIN qqq AS b ON a.HVCaseFK = b.HVCaseFK
WHERE b.HVCaseFK IS NULL
)
,
AllPreAssessment AS (
SELECT a.*
FROM Preassessment AS a
WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
UNION
SELECT * FROM NoStatus
)

SELECT c.PC1ID [Participant]
, rtrim(w.LastName) + ', ' + rtrim(w.LastName) [Worker]
, CASE WHEN a.PADate < @StartDt THEN rtrim(str(datediff(dd, b.ScreenDate , @EndDt),10))
  WHEN a.CaseStatus = '03' THEN rtrim(str(datediff(dd, b.ScreenDate , a.PADate),10))
  WHEN a.CaseStatus = '01' THEN rtrim(str(datediff(dd, b.ScreenDate, @EndDt),10))
  WHEN a.CaseStatus = '02' THEN rtrim(str(datediff(dd, b.ScreenDate, a.PADate),10))
  ELSE '0 days' END [DaysInPreassess]
  
  
, CASE WHEN a.PADate < @StartDt THEN 'No Status'
  WHEN a.CaseStatus = '03' THEN rtrim(x.ReportDischargeText) + ' ' + convert(VARCHAR(12), a.PADate, 101) 
  WHEN a.CaseStatus = '01' THEN 'Engagement Continue ' + convert(VARCHAR(12), @EndDt, 101) 
  WHEN a.CaseStatus = '02' THEN 'Enrolled ' + convert(VARCHAR(12), b.KempeDate, 101) 
  ELSE '' END [CurrentStatus]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAParentLetter, 0) END [Letters]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PACall2Parent, 0) END [Call2Parent]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PACallFromParent, 0) END [CallFromParent]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAVisitAttempt, 0) END [VisitAttempted]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAVisitMade, 0) END [VisitConducted]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAOtherHVProgram, 0) END [Referrals]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAParent2Office, 0) END [Parent2Office]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAProgramMaterial, 0) END [ProgramMaterial]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAGift, 0) END [Gift]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PACaseReview, 0) END [CaseReview]
, CASE WHEN a.PADate < @StartDt THEN 0 ELSE ISNULL(PAOtherActivity, 0) END [OtherActivity]
-- support fields
--, b.ScreenDate , a.PADate 
--, CASE WHEN c.DischargeDate > @EndDt THEN NULL ELSE c.DischargeDate END [xDischargeDate] 
--,a.HVCaseFK, b.KempeDate, a.CaseStatus, a.KempeResult, a.DischargeReason, x.ReportDischargeText

FROM AllPreAssessment AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
JOIN HVCase AS b ON b.HVCasePK = a.HVCaseFK
LEFT OUTER JOIN codeDischarge x ON x.DischargeCode = a.DischargeReason 
AND x.DischargeUsedWhere LIKE '%PA%'
LEFT OUTER JOIN Worker AS w ON w.WorkerPK = a.PAFAWFK
--WHERE a.ProgramFK = @programfk AND a.PADate BETWEEN @StartDt AND @EndDt
ORDER BY [Participant]






GO
