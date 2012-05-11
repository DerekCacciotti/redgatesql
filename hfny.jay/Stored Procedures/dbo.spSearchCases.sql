
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spSearchCases] ( @PC1ID VARCHAR(13) = NULL, @PCPK INT = NULL, 
@PCFirstName VARCHAR(20) = NULL, @PCLastName VARCHAR(30) = NULL,@PCDOB DATETIME = NULL, 
@TCFirstName VARCHAR(20) = NULL, @TCLastName VARCHAR(30) = NULL,@TCDOB DATETIME = NULL,
@WorkerPK INT = NULL, @ProgramFK INT = NULL)

AS

SET NOCOUNT ON;
-- Rewrote this store proc to make it compatible with SQL 2008.
WITH results(hvcasepk,pcpk, 
	PC1ID,
	pcfirstname, pclastname, pcdob,
	tcfirstname, tclastname, tcdob,
	workerlastname, workerfirstname,
	dischargedate,caseprogress,levelname,WorkerPK)
AS
(

	SELECT hvcasepk,pc.pcpk, 
		PC1ID,
		pc.pcfirstname, pc.pclastname, pc.pcdob,
		RTRIM(tcid.tcfirstname), RTRIM(tcid.tclastname), hv.tcdob,
		RTRIM(worker.lastname) AS workerlastname, RTRIM(worker.firstname) AS workerfirstname,
		dischargedate, rtrim(cast(CaseProgress as char(4)))+'-'+ccp.CaseProgressBrief as CaseProgress, cdlvl.levelname,WorkerPK
	FROM fnTableCaseProgram(@ProgramFK) cp  -- Note: fnTableCaseProgram is like a parameterised view ... Khalsa
	
	INNER JOIN codeLevel cdlvl ON cdlvl.codeLevelPK = cp.CurrentLevelFK 
		
	INNER JOIN hvcase hv
	ON cp.hvcasefk = hv.hvcasepk	
	
	
	INNER JOIN pc
	ON hv.pc1fk = pc.pcpk
	
	inner join codeCaseProgress ccp on hv.CaseProgress=ccp.CaseProgressCode	
	
	
	LEFT JOIN tcid
	ON tcid.hvcasefk = hv.hvcasepk
	
	LEFT JOIN Workerprogram wp
	ON wp.workerfk = ISNULL(currentfswfk, currentfawfk) --IN(currentfswfk, currentfawfk)
	AND wp.programfk = cp.programfk
	LEFT JOIN worker
	ON workerpk = workerfk
	WHERE (pc1id LIKE '%' + @PC1ID + '%'
	OR pcpk = @PCPK
	OR pc.pcfirstname LIKE @PCFirstName + '%'
	OR pc.pclastname LIKE @PCLastName + '%'
	OR pc.pcdob = @PCDOB
	OR tcid.tcfirstname LIKE @TCFirstName + '%'
	OR tcid.tclastname LIKE @TCLastName + '%'
	OR hv.tcdob = @TCDOB
	OR workerpk = @WorkerPK)

)


SELECT DISTINCT TOP 100 hvcasepk,pcpk, 
	PC1ID,
	pcfirstname + ' ' + pclastname AS PC1,
	pcdob,
	tc = SUBSTRING ((SELECT ', ' + tcfirstname + ' ' + tclastname FROM results r2 WHERE r1.pc1id = r2.pc1id FOR XML PATH ( '' ) ), 3, 1000),
	tcdob,
	workerfirstname + ' ' + workerlastname AS worker,
	dischargedate, caseprogress,levelname, CASE WHEN dischargedate IS NULL THEN 0 ELSE 1 END
	
	,
	(
	CASE WHEN pc1id = @PC1ID THEN 1 ELSE 0 END +
	CASE WHEN pcpk = @PCPK THEN 1 ELSE 0 END +
	CASE WHEN r1.pcfirstname LIKE @PCFirstName + '%' THEN 1 ELSE 0 END +
	CASE WHEN r1.pclastname LIKE @PCLastName + '%' THEN 1 ELSE 0 END +
	CASE WHEN r1.pcdob = @PCDOB THEN 1 ELSE 0 END +
	CASE WHEN r1.tcfirstname LIKE @TCFirstName + '%' THEN 1 ELSE 0 END +
	CASE WHEN r1.tclastname LIKE @TCLastName + '%' THEN 1 ELSE 0 END +
	CASE WHEN r1.tcdob = @TCDOB THEN 1 ELSE 0 END +
	CASE WHEN workerpk = @WorkerPK THEN 1 ELSE 0 END) AS SCORE4ORDERINGROWS
	
	
FROM results r1
ORDER BY
CASE WHEN dischargedate IS NULL THEN 0 ELSE 1 END,
SCORE4ORDERINGROWS DESC,PC1ID
	

GO
