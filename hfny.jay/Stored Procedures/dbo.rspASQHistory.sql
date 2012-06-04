SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rspASQHistory]
( @programfk INT = NULL, 
  @supervisorfk INT = NULL, 
  @workerfk INT = NULL,
  @UnderCutoffOnly CHAR(1) = 'N')
AS

DECLARE @n INT = 0
SELECT @n = CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END

SELECT 
LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor,
LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) worker,
d.PC1ID, LTRIM(RTRIM(c.TCFirstName)) + ' ' + LTRIM(RTRIM(c.TCLastName)) TCName,
convert(VARCHAR(12), c.TCDOB, 101) TCDOB, 
c.GestationalAge, 
ltrim(rtrim(replace(b.[AppCodeText], '(optional)', ''))) TCAge, 
convert(VARCHAR(12), a.DateCompleted, 101) DateCompleted, 
a.ASQCommunicationScore, 
CASE WHEN UnderCommunication = 1 THEN '*' ELSE '' END UnderCommunication, 
ASQGrossMotorScore, 
CASE WHEN UnderGrossMotor = 1 THEN '*' ELSE '' END UnderGrossMotor, 
ASQFineMotorScore, 
CASE WHEN UnderFineMotor = 1 THEN '*' ELSE '' END UnderFineMotor, 
ASQProblemSolvingScore, 
CASE WHEN UnderProblemSolving = 1 THEN '*' ELSE '' END UnderProblemSolving, 
ASQPersonalSocialScore, 
CASE WHEN UnderPersonalSocial = 1 THEN '*' ELSE '' END UnderPersonalSocial, 
CASE WHEN TCReferred IS NULL THEN 'Unknown' 
WHEN TCReferred = 1 THEN 'Yes' ELSE 'No' END TCReferred, 
CASE WHEN ReviewCDS = 1 THEN 'Yes' ELSE 'No' END ReviewCDS, 
CASE WHEN ASQInWindow IS NULL THEN 'Unknown' 
WHEN ASQInWindow = 1 THEN 'In Window' ELSE 'Out of Window' END InWindow,
a.TCAge [TCAgeCode]

FROM ASQ a 
INNER JOIN codeApp b 
ON a.TCAge = b.AppCode AND b.AppCodeGroup = 'TCAge' AND b.AppCodeUsedWhere LIKE '%AQ%'
INNER JOIN TCID c 
ON c.TCIDPK = a.TCIDFK
INNER JOIN CaseProgram d 
ON d.HVCaseFK = a.HVCaseFK
INNER JOIN worker fsw
ON d.CurrentFSWFK = fsw.workerpk
INNER JOIN workerprogram wp
ON wp.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON wp.supervisorfk = supervisor.workerpk

INNER JOIN 
(SELECT TCIDFK, 
SUM(
CASE WHEN UnderCommunication = 1 THEN 1 ELSE 0 END  + 
CASE WHEN UnderFineMotor = 1 THEN 1 ELSE 0 END +
CASE WHEN UnderGrossMotor = 1 THEN 1 ELSE 0 END +
CASE WHEN UnderPersonalSocial = 1 THEN 1 ELSE 0 END + 
CASE WHEN UnderProblemSolving = 1 THEN 1 ELSE 0 END
) flag
FROM ASQ 
GROUP BY TCIDFK
HAVING SUM(
CASE WHEN UnderCommunication = 1 THEN 1 ELSE 0 END  + 
CASE WHEN UnderFineMotor = 1 THEN 1 ELSE 0 END +
CASE WHEN UnderGrossMotor = 1 THEN 1 ELSE 0 END +
CASE WHEN UnderPersonalSocial = 1 THEN 1 ELSE 0 END + 
CASE WHEN UnderProblemSolving = 1 THEN 1 ELSE 0 END
) >= @n) x 
ON x.TCIDFK = a.TCIDFK

WHERE d.currentFSWFK = ISNULL(@workerfk, d.currentFSWFK)
AND wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)
AND d.programfk = @programfk
ORDER BY  supervisor, worker, TCName, TCAgeCode




GO
