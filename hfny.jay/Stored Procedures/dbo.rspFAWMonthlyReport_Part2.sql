SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part2] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

SELECT rtrim(w.LastName) + ', ' + rtrim(w.FirstName) [workerName]
, [FAWFK]
, isnull([AssignThisMonth],0) [AssignThisMonth]
, isnull([CaseAtBeginning],0) [CaseAtBeginning]
, isnull([PAAssessed],0) [PAAssessed]
, isnull([PATerminated],0) [PATerminated]
, isnull([PAPending],0) [PAPending]
, isnull([MOBOnly],0) [MOBOnly]
, isnull([BOTH],0) [BOTH]
, isnull([FOBOnly],0) [FOBOnly]
, isnull([MOBPartner],0) [MOBPartner]
, isnull([FOBPartner],0) [FOBPartner]
, isnull([MOBGrandmother],0) [MOBGrandmother]
, isnull([Other],0) [Other]
FROM
(SELECT isnull(aa1.FAWFK, d.FAWFK) [FAWFK]
, [AssignThisMonth], [CaseAtBeginning] 
, [PAAssessed], [PATerminated], [PAPending]
, [MOBOnly],[BOTH], [FOBOnly], [MOBPartner], [FOBPartner], [MOBGrandmother], [Other]
FROM 
(SELECT isnull(a1.FAWFK, c.FAWFK) [FAWFK]
, [AssignThisMonth], [CaseAtBeginning] 
, [PAAssessed], [PATerminated], [PAPending]
FROM
(SELECT 
isnull(a.FAWFK, b.FAWFK) [FAWFK], [AssignThisMonth], [CaseAtBeginning] 
FROM 
(SELECT FAWFK, count(*) [AssignThisMonth]
FROM HVScreen
WHERE ProgramFK = @programfk AND (ScreenDate BETWEEN @StartDt AND @EndDt)
AND ScreenResult = '1' AND ReferralMade = '1'
GROUP BY FAWFK) AS a
FULL OUTER JOIN
(SELECT FAWFK, count(*) [CaseAtBeginning] 
FROM HVScreen WHERE ProgramFK = @programfk 
AND ScreenDate < @StartDt AND ScreenResult = '1' AND ReferralMade = '1' AND
HVCaseFK NOT IN (SELECT DISTINCT HVCaseFK FROM Preassessment 
WHERE ProgramFK = @programfk 
AND PADate <= @EndDt 
AND CaseStatus IN ('02', '03'))
GROUP BY FAWFK) AS b
ON a.FAWFK = b.FAWFK) AS a1

FULL OUTER JOIN
(SELECT PAFAWFK [FAWFK]
, sum(CASE WHEN CaseStatus = '02' THEN 1 ELSE 0 END) [PAAssessed]
, sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [PATerminated]
, sum(CASE WHEN CaseStatus = '01' THEN 1 ELSE 0 END) [PAPending]
FROM Preassessment WHERE ProgramFK = @programfk AND (PADate BETWEEN @StartDt AND @EndDt) 
GROUP BY PAFAWFK) AS c
ON a1.FAWFK = c.FAWFK
) AS aa1

FULL OUTER JOIN
(SELECT FAWFK, sum(CASE WHEN MOBPresent = 1 AND FOBPresent != 1 THEN 1 ELSE 0 END) [MOBOnly]
, sum(CASE WHEN MOBPresent = 1 AND FOBPresent = 1 THEN 1 ELSE 0 END) [BOTH]
, sum(CASE WHEN MOBPresent != 1 AND FOBPresent = 1 THEN 1 ELSE 0 END) [FOBOnly]
, sum(CASE WHEN MOBPartnerPresent = 1 THEN 1 ELSE 0 END) [MOBPartner]
, sum(CASE WHEN FOBPartnerPresent = 1 THEN 1 ELSE 0 END) [FOBPartner]
, sum(CASE WHEN GrandParentPresent = 1 THEN 1 ELSE 0 END) [MOBGrandmother]
, sum(CASE WHEN OtherPresent = 1 THEN 1 ELSE 0 END) [Other]
FROM Kempe
WHERE ProgramFK = @programfk AND (KempeDate BETWEEN @StartDt AND @EndDt) 
GROUP BY FAWFK) AS d
ON aa1.FAWFK = d.FAWFK
) z

JOIN Worker w
ON z.FAWFK = w.WorkerPK
ORDER BY w.LastName












GO
