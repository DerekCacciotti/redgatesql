
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rspPSIHistory]
( @programfk INT = NULL, 
  @supervisorfk INT = NULL, 
  @workerfk INT = NULL,
  @Over85Percent CHAR(1) = 'N',
  @pc1ID VARCHAR(13) = '')
AS

DECLARE @n INT = 0
SELECT @n = CASE WHEN @Over85Percent = 'Y' THEN 1 ELSE 0 END

SELECT 
LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor,
LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) worker,
d.PC1ID,
ltrim(rtrim(b.[AppCodeText])) PSIInterval, 
convert(VARCHAR(12), a.PSIDateComplete, 101) PSIDateComplete, 
a.DefensiveRespondingScore,
CASE WHEN DefensiveRespondingScore <= 10 THEN '*' ELSE '' END DefensiveRespondingScoreX, 
a.ParentalDistressScore, 
CASE WHEN ParentalDistressScore >= 33 THEN '*' ELSE '' END ParentalDistressScoreX, 
CASE WHEN ParentalDistressValid = 1 THEN '' ELSE '#' END ParentalDistressValidX, 
a.ParentChildDisfunctionalInteractionScore, 
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN '*' ELSE '' END ParentChildDisfunctionalInteractionScoreX, 
CASE WHEN ParentChildDysfunctionalInteractionValid = 1 THEN '' ELSE '#' END ParentChildDysfunctionalInteractionValidX, 
a.DifficultChildScore, 
CASE WHEN DifficultChildScore >= 33 THEN '*' ELSE '' END DifficultChildScoreX, 
CASE WHEN DifficultChildValid = 1 THEN '' ELSE '#' END DifficultChildValidX,
a.PSITotalScore, 
CASE WHEN PSITotalScore >= 86 THEN '*' ELSE '' END PSITotalScoreX,
CASE WHEN PSITotalScoreValid = 1 THEN '' ELSE '#' END PSITotalScoreValidX,
CASE WHEN PSIInWindow IS NULL THEN 'Unknown' 
WHEN PSIInWindow = 1 THEN 'In Window' ELSE 'Out of Window' END InWindow,
a.PSIInterval

FROM PSI a 
INNER JOIN codeApp b 
ON a.PSIInterval = b.AppCode AND b.AppCodeGroup = 'PSIInterval' 
AND b.AppCodeUsedWhere LIKE '%PS%'
INNER JOIN CaseProgram d 
ON d.HVCaseFK = a.HVCaseFK
INNER JOIN worker fsw
ON d.CurrentFSWFK = fsw.workerpk
INNER JOIN workerprogram wp
ON wp.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON wp.supervisorfk = supervisor.workerpk

INNER JOIN 
(SELECT HVCaseFK, 
SUM(
CASE WHEN DefensiveRespondingScore <= 10 THEN 1 ELSE 0 END +
CASE WHEN ParentalDistressScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN 1 ELSE 0 END +
CASE WHEN DifficultChildScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN PSITotalScore >= 86 THEN 1 ELSE 0 END 
) flag
FROM PSI 
GROUP BY HVCaseFK
HAVING SUM(
CASE WHEN DefensiveRespondingScore <= 10 THEN 1 ELSE 0 END +
CASE WHEN ParentalDistressScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN ParentChildDisfunctionalInteractionScore >= 26 THEN 1 ELSE 0 END +
CASE WHEN DifficultChildScore >= 33 THEN 1 ELSE 0 END +
CASE WHEN PSITotalScore >= 86 THEN 1 ELSE 0 END 
) >= @n) x 
ON x.HVCaseFK = a.HVCaseFK

WHERE 
d.DischargeDate IS NOT NULL
AND d.currentFSWFK = ISNULL(@workerfk, d.currentFSWFK)
AND wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)
AND d.programfk = @programfk
AND d.PC1ID = CASE WHEN @pc1ID = '' THEN d.PC1ID ELSE @pc1ID END
ORDER BY  supervisor, worker, PC1ID, a.PSIInterval





GO
