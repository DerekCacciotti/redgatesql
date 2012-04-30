
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spSearchCases] ( @PC1ID VARCHAR(11) = NULL, @PCPK INT = NULL, 
@PCFirstName VARCHAR(20) = NULL, @PCLastName VARCHAR(30) = NULL,@PCDOB DATETIME = NULL, 
@TCFirstName VARCHAR(20) = NULL, @TCLastName VARCHAR(30) = NULL,@TCDOB DATETIME = NULL,
@WorkerPK INT = NULL, @ProgramFK INT = NULL)

AS

SET NOCOUNT ON;

WITH results(hvcasepk,pcpk, 
	PC1ID,
	pcfirstname, pclastname, pcdob,
	tcfirstname, tclastname, tcdob,
	workerlastname, workerfirstname,
	dischargedate, caseprogress,levelname)
AS
(
	SELECT TOP 100 hvcasepk,pc.pcpk, 
		PC1ID,
		pc.pcfirstname, pc.pclastname, pc.pcdob,
		RTRIM(tcid.tcfirstname), RTRIM(tcid.tclastname), hvcase.tcdob,
		RTRIM(worker.lastname) AS workerlastname, RTRIM(worker.firstname) AS workerfirstname,
		dischargedate, rtrim(cast(CaseProgress as char(4)))+'-'+ccp.CaseProgressBrief as CaseProgress, cdlvl.levelname
	FROM caseprogram cp
	INNER JOIN codeLevel cdlvl ON cdlvl.codeLevelPK = cp.CurrentLevelFK 
	INNER JOIN hvcase ON hvcasefk = hvcasepk
	INNER JOIN pc ON pc1fk = pc.pcpk
	inner join codeCaseProgress ccp on CaseProgress=ccp.CaseProgressCode
	LEFT JOIN tcid ON tcid.hvcasefk = hvcasepk
	LEFT JOIN Workerprogram wp ON wp.workerfk = ISNULL(currentfswfk, currentfawfk) --IN(currentfswfk, currentfawfk)
									AND wp.programfk = cp.programfk
	LEFT JOIN worker ON workerpk = workerfk	
	WHERE (pc1id LIKE '%' + @PC1ID + '%'
	OR pcpk = @PCPK
	OR pc.pcfirstname LIKE @PCFirstName + '%'
	OR pc.pclastname LIKE @PCLastName + '%'
	OR pc.pcdob = @PCDOB
	OR tcid.tcfirstname LIKE @TCFirstName + '%'
	OR tcid.tclastname LIKE @TCLastName + '%'
	OR hvcase.tcdob = @TCDOB
	OR workerpk = @WorkerPK)
	AND cp.ProgramFK = ISNULL(@ProgramFK, cp.ProgramFK)
	ORDER BY 
	CASE WHEN pc1id = @PC1ID THEN 1 ELSE 0 END +
	CASE WHEN pcpk = @PCPK THEN 1 ELSE 0 END +
	CASE WHEN pc.pcfirstname LIKE @PCFirstName + '%' THEN 1 ELSE 0 END +
	CASE WHEN pc.pclastname LIKE @PCLastName + '%' THEN 1 ELSE 0 END +
	CASE WHEN pc.pcdob = @PCDOB THEN 1 ELSE 0 END +
	CASE WHEN tcid.tcfirstname LIKE @TCFirstName + '%' THEN 1 ELSE 0 END +
	CASE WHEN tcid.tclastname LIKE @TCLastName + '%' THEN 1 ELSE 0 END +
	CASE WHEN tcid.tcdob = @TCDOB THEN 1 ELSE 0 END +
	CASE WHEN workerpk = @WorkerPK THEN 1 ELSE 0 END DESC
)

SELECT distinct hvcasepk,pcpk, 
	PC1ID,
	pcfirstname + ' ' + pclastname AS PC1,
	pcdob,
	--tc = '',
	tc = SUBSTRING ((SELECT DISTINCT ', ' + tcfirstname + ' ' + tclastname FROM results r2 WHERE r1.pc1id = r2.pc1id FOR XML PATH ( '' ) ), 3, 1000),
	tcdob,
	workerfirstname + ' ' + workerlastname AS worker,
	dischargedate, caseprogress,levelname, CASE WHEN dischargedate IS NULL THEN 0 ELSE 1 END
FROM results r1
ORDER BY CASE WHEN dischargedate IS NULL THEN 0 ELSE 1 END, dischargedate DESC, pc1id

GO
