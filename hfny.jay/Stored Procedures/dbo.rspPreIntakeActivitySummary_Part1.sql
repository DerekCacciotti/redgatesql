SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	PreIntakeActivitySummary Report
-- =============================================
CREATE PROCEDURE [dbo].[rspPreIntakeActivitySummary_Part1] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

;WITH HV AS
(
SELECT DISTINCT HVCaseFK FROM Preintake
WHERE ProgramFK = @programfk AND PIDate < @StartDt 
AND CaseStatus IN ('02', '03')
),
At_Start_Of_Month AS
(SELECT DISTINCT HVCaseFK
FROM Preintake WHERE HVCaseFK NOT IN (SELECT HV.HVCaseFK FROM HV )
AND ProgramFK = @programfk AND PIDate < @StartDt
),
HV1 AS 
(
SELECT DISTINCT HVCaseFK FROM Preintake
WHERE ProgramFK = @programfk AND PIDate <= @EndDt 
AND CaseStatus IN ('02', '03')
),
At_End_Of_Month AS
(
SELECT DISTINCT HVCaseFK
FROM Preintake WHERE HVCaseFK NOT IN (SELECT HV1.HVCaseFK FROM HV1 )
AND ProgramFK = @programfk AND PIDate <= @EndDt
)

SELECT  count(*) [PreInTakeCases]
,(SELECT count(*) FROM At_Start_Of_Month) [At_Start_of_Month]
, sum(CASE WHEN PIFSWFK IS NOT NULL THEN 1 ELSE 0 END) [AssignedFSW]
, sum(CASE WHEN CaseStatus = '02' THEN 1 ELSE 0 END) [Enrolled]
, sum(CASE WHEN CaseStatus = '03' THEN 1 ELSE 0 END) [Terminated]
, sum(CASE WHEN CaseStatus = '01' THEN 1 ELSE 0 END) [Continue]
,(SELECT count(*) FROM At_End_Of_Month) [At_End_of_Month]
, sum(ISNULL(PIParentLetter, 0))  [Letters]
, sum(ISNULL(PICall2Parent, 0)) [Call2Parent]
, sum(ISNULL(PICallFromParent, 0)) [CallFromParent]
, sum(ISNULL(PIVisitAttempt, 0)) [VisitAttempted]
, sum(ISNULL(PIVisitMade, 0)) [VisitConducted]
, sum(ISNULL(PIOtherHVProgram, 0)) [Referrals]
, sum(ISNULL(PIParent2Office, 0)) [Parent2Office]
, sum(ISNULL(PIProgramMaterial, 0)) [ProgramMaterial]
, sum(ISNULL(PIGift, 0)) [Gift]
, sum(ISNULL(PICaseReview, 0)) [CaseReview]
, sum(ISNULL(PIOtherActivity, 0)) [OtherActivity]

FROM Preintake 
WHERE ProgramFK = @programfk AND PIDate BETWEEN @StartDt AND @EndDt









GO
