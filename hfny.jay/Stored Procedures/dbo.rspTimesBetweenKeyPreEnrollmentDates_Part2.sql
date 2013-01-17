
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspTimesBetweenKeyPreEnrollmentDates_Part2] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @StartDt DATE = '01/01/2012'
--DECLARE @EndDt DATE = '06/30/2012'
--DECLARE @programfk INT = 17

SELECT avg([ScreenToKempe]) [ScreenToKempe]
, avg([KempeToIntake]) [KempeToIntake]
, avg( [KempeToFSW]) [KempeToFSW]
, avg([FSWToIntake]) [FSWToIntake]
, avg([ScreenToIntake]) [ScreenToIntake]
, count(*) [n]
FROM(
SELECT e.PC1ID 
, rtrim(faw.LastName) + ', ' + rtrim(faw.FirstName) [faw]
, b.ScreenDate
, d.KempeDate 
, datediff(day, b.ScreenDate, c.KempeDate) [ScreenToKempe]
, c.FSWAssignDate
, rtrim(fsw.LastName) + ', ' + rtrim(fsw.FirstName) [fsw]
, datediff(day, c.KempeDate, c.FSWAssignDate) [KempeToFSW]
, a.IntakeDate
, datediff(day, c.FSWAssignDate, a.IntakeDate) [FSWToIntake]
, datediff(day, b.ScreenDate, a.IntakeDate) [ScreenToIntake]
, datediff(day, d.KempeDate, a.IntakeDate) [KempeToIntake]

FROM HVCase AS a
LEFT OUTER JOIN HVScreen AS b ON a.HVCasePK = b.HVCaseFK
LEFT OUTER JOIN Preassessment AS c ON c.HVCaseFK = a.HVCasePK AND c.CaseStatus = '02' 
LEFT OUTER JOIN Kempe  AS d ON d.HVCaseFK = a.HVCasePK
JOIN dbo.CaseProgram AS e ON e.HVCaseFK = a.HVCasePK
JOIN dbo.Worker AS faw ON faw.WorkerPK = b.FAWFK -- e.CurrentFAWFK
JOIN dbo.Worker AS fsw	ON fsw.WorkerPK = c.PAFSWFK -- e.CurrentFSWFK
WHERE e.ProgramFK = @programfk AND a.IntakeDate BETWEEN @StartDt AND @EndDt
) AS gg









GO
