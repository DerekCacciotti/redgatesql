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

--DECLARE @StartDtT DATE = '01/01/2011'
--DECLARE @StartDt DATE = '08/01/2011'
--DECLARE @EndDt DATE = '12/31/2011'
--DECLARE @programfk INT = 6

SELECT b.PC1ID
, Convert(VARCHAR(12), a.ScreenDate, 101) [ScreenDate]
, Convert(VARCHAR(12), x.PADate, 101) [PADate]
, x.HVCaseFK
, CASE WHEN x.CaseStatus = '01' THEN 'Engagement Continue'
WHEN x.CaseStatus = '02' THEN 'Positive, Assigned'
WHEN x.CaseStatus = '03' THEN 'Terminated'
WHEN x.CaseStatus = '04' THEN 'Positive, Not Assigned'
ELSE 'No Status' END [CaseStatusText]
, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) [WorkName]
, x.CaseStatus, x.KempeDate, x.KempeResult
, x.PAFAWFK
FROM Preassessment x
JOIN (
SELECT p.HVCaseFK, max(p.PADate) [max_PADATE]
FROM Preassessment AS p 
WHERE p.PADate BETWEEN @StartDt AND @EndDt AND p.ProgramFK = @programfk
GROUP BY p.HVCaseFK
)AS y
ON x.HVCaseFK = y.HVCaseFK AND x.PADate = y.max_PADATE
JOIN HVCase AS a ON x.HVCaseFK = a.HVCasePK
JOIN CaseProgram AS b ON b.HVCaseFK = x.HVCaseFK
JOIN Worker AS w ON w.WorkerPK = x.PAFAWFK

ORDER BY b.PC1ID









GO
