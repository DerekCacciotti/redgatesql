SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspFAWMonthlyReport_Part1] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

SELECT count(*) [TotalScreen]
, sum(CASE WHEN a.ScreenResult = '1' THEN 1 ELSE 0 END) [ScreenPositive]
, sum(CASE WHEN a.ScreenResult <> '1' THEN 1 ELSE 0 END) [ScreenNegative]
, sum(CASE WHEN a.ScreenResult = '1' AND a.ReferralMade = '1' THEN 1 ELSE 0 END) [PositiveReferred]
, sum(CASE WHEN a.ScreenResult = '1' AND a.ReferralMade <> '1' THEN 1 ELSE 0 END) [PositiveNotReferred]

, (SELECT count(*) FROM HVScreen WHERE ProgramFK = @programfk 
AND ScreenDate < @StartDt AND ScreenResult = '1' AND ReferralMade = '1' AND
HVCaseFK NOT IN (SELECT DISTINCT HVCaseFK FROM Preassessment 
WHERE ProgramFK = @programfk 
AND PADate <= @EndDt 
AND CaseStatus IN ('02', '03')
)) [PreAssessmentCaseLoad]

, (SELECT count(*) FROM Preassessment WHERE ProgramFK = @programfk AND CaseStatus = '02' AND PADate BETWEEN @StartDt AND @EndDt) [PAAssessed]
, (SELECT count(*) FROM Preassessment WHERE ProgramFK = @programfk AND CaseStatus = '03' AND PADate BETWEEN @StartDt AND @EndDt) [PATerminated]
, (SELECT count(*) FROM Preassessment WHERE ProgramFK = @programfk AND CaseStatus = '01' AND PADate BETWEEN @StartDt AND @EndDt) [PAPending]
, (SELECT count(*) FROM HVScreen WHERE ProgramFK = @programfk 
AND (ScreenDate BETWEEN @StartDt AND @EndDt) AND ScreenResult = '1' AND ReferralMade = '1' AND
HVCaseFK NOT IN (SELECT DISTINCT HVCaseFK FROM Preassessment 
WHERE ProgramFK = @programfk 
AND (PADate BETWEEN @StartDt AND @EndDt)
)) [PositiveReferredNoAssessmentYet]

FROM HVScreen  AS a
WHERE ProgramFK = @programfk AND a.ScreenDate BETWEEN @StartDt AND @EndDt











GO
