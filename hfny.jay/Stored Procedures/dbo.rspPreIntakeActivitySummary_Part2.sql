SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspPreIntakeActivitySummary_Part2] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

SELECT c.PC1ID [Participant]
, rtrim(w.LastName) + ', ' + rtrim(w.LastName) [Worker]
, cast(datediff(day, b.KempeDate, a.PIDate) AS VARCHAR(12)) + ' days' [DaysInPreintake]
, CASE WHEN a.CaseStatus = '01' THEN 'Engagement Continue' 
WHEN a.CaseStatus = '02' THEN 'Enrolled ' + (SELECT TOP 1 convert(varchar(12), IntakeDate, 101) FROM HVCase WHERE HVCasePK = a.HVCaseFK )
WHEN a.CaseStatus = '03' THEN 
isnull((SELECT TOP 1 rtrim(ReportDischargeText) FROM codeDischarge WHERE DischargeCode = a.DischargeReason) + ' ', 'Terminated ')
 + isnull(convert(varchar(12), c.DischargeDate, 101), '') 
 ELSE '(Status Unknown)' END [CaseStatus]

, ISNULL(PIParentLetter, 0)  [Letters]
, ISNULL(PICall2Parent, 0) [Call2Parent]
, ISNULL(PICallFromParent, 0) [CallFromParent]
, ISNULL(PIVisitAttempt, 0) [VisitAttempted]
, ISNULL(PIVisitMade, 0) [VisitConducted]
, ISNULL(PIOtherHVProgram, 0) [Referrals]
, ISNULL(PIParent2Office, 0) [Parent2Office]
, ISNULL(PIProgramMaterial, 0) [ProgramMaterial]
, ISNULL(PIGift, 0) [Gift]
, ISNULL(PICaseReview, 0) [CaseReview]
, ISNULL(PIOtherActivity, 0) [OtherActivity]

,a.CaseStatus, a.ProgramFK, a.DischargeReason, a.PIDate, a.PIFSWFK, a.KempeFK, a.HVCaseFK
FROM Preintake AS a
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCaseFK
JOIN Kempe AS b ON b.KempePK = a.KempeFK
LEFT OUTER JOIN Worker AS w ON w.WorkerPK = a.PIFSWFK
WHERE a.ProgramFK = @programfk AND a.PIDate BETWEEN @StartDt AND @EndDt
ORDER BY [Participant]










GO
