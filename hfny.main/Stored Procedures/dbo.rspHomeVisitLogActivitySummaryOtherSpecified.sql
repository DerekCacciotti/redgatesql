SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary Other Specified
-- =============================================
CREATE PROCEDURE [dbo].[rspHomeVisitLogActivitySummaryOtherSpecified] 
	-- Add the parameters for the stored procedure here
	(@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt DATETIME,
	@workerfk INT = NULL,
	@pc1id VARCHAR(13) = '',
	@showWorkerDetail CHAR(1) = 'N',
	@showPC1IDDetail CHAR(1) = 'N')

AS

--DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '09/30/2013'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'


SELECT --DISTINCT
CASE WHEN @showWorkerDetail = 'N' THEN 0 ELSE a.FSWFK END FSWFK
, CASE WHEN @showPC1IDDetail = 'N' THEN '' ELSE cp.PC1ID END PC1ID
--, CurriculumOtherSpecify
, CASE WHEN count(*) > 1 THEN rtrim(CurriculumOtherSpecify) + ' (' + 
convert(VARCHAR(5), count(*)) + ')'
ELSE rtrim(CurriculumOtherSpecify) END CurriculumOtherSpecify
    
FROM HVLog AS a
INNER JOIN worker fsw
ON a.FSWFK = fsw.workerpk
INNER JOIN CaseProgram cp
ON cp.HVCaseFK = a.HVCaseFK
INNER JOIN HVCase AS h
ON h.HVCasePK = a.HVCaseFK
WHERE 
a.ProgramFK = @programfk 
AND cast(VisitStartTime AS date) between @StartDt AND @EndDt 
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND cp.PC1ID = CASE WHEN @pc1ID = '' THEN cp.PC1ID ELSE @pc1ID END
AND substring(VisitType,4,1) <> '1'
AND (CurriculumOtherSpecify IS NOT NULL AND 
len(rtrim(CurriculumOtherSpecify)) > 0)

GROUP BY FSWFK, PC1ID, rtrim(CurriculumOtherSpecify)
ORDER BY FSWFK, PC1ID, CurriculumOtherSpecify
GO
