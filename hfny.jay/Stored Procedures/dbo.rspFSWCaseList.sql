SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[rspFSWCaseList]( @programfk VARCHAR(MAX) = NULL, @supervisorfk INT = NULL, @workerfk INT = NULL)

AS

IF @programfk IS NULL BEGIN
	SELECT @programfk = 
		SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
					FROM HVProgram
					FOR XML PATH('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','')

DECLARE @caselist TABLE(
	pc1id VARCHAR(13), 
	codelevelpk INT, 
	levelname VARCHAR(200), 
	currentleveldate DATETIME, 
	CaseWeight FLOAT, 
	pcfirstname VARCHAR(200),
	pclastname VARCHAR(200), 
	street VARCHAR(200),
	pccity VARCHAR(200), 
	pcstate VARCHAR(2), 
	pczip VARCHAR(200),
	pcphone VARCHAR(200),
	tcfirstname VARCHAR(200), 
	tclastname VARCHAR(200), 
	tcdob DATETIME, 
	edc DATETIME,
	worker VARCHAR(200),
	supervisor VARCHAR(200)
)

INSERT INTO @caselist
SELECT TOP 100 PERCENT 
	pc1id, 
	codelevelpk, 
	levelname, 
	currentleveldate, 
	CaseWeight,
	LTRIM(RTRIM(pc.pcfirstname)), LTRIM(RTRIM(pc.pclastname)),
	rtrim(pc.pcstreet) + CASE WHEN pcapt is null or pcapt='' THEN '' ELSE ', Apt: '+rtrim(pcapt) END as street,
	pc.pccity, 
	pc.pcstate, 
	pc.pczip,
	pc.pcphone + CASE WHEN pc.PCEmergencyPhone IS NOT NULL THEN ', EMR: ' + pc.PCEmergencyPhone ELSE '' END AS pcphone,
	LTRIM(RTRIM(tcid.tcfirstname)), 
	LTRIM(RTRIM(tcid.tclastname)),
	hvcase.tcdob, 
	hvcase.edc,
	LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) worker,
	LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor
FROM hvcase
INNER JOIN caseprogram
ON caseprogram.hvcasefk = hvcasepk
inner join workerassignment wa1
on wa1.hvcasefk = caseprogram.hvcasefk 
and wa1.programfk = caseprogram.programfk
LEFT JOIN kempe
ON kempe.hvcasefk = hvcasepk
INNER JOIN codelevel
ON codelevelpk = currentlevelfk
INNER JOIN pc
ON pc.pcpk = pc1fk
LEFT JOIN tcid
ON tcid.hvcasefk = hvcasepk
INNER JOIN worker fsw
ON CurrentFSWFK = fsw.workerpk
INNER JOIN workerprogram
ON workerprogram.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON supervisorfk = supervisor.workerpk
INNER JOIN dbo.SplitString(@programfk,',')
ON caseprogram.programfk  = listitem
WHERE currentFSWFK = ISNULL(@workerfk, currentFSWFK)
AND supervisorfk = ISNULL(@supervisorfk, supervisorfk)
AND dischargedate IS NULL
--AND kempedate IS NOT NULL 'Chris Papas removed 1/28/2011 This was screwing up because there is no kempe date in kempe table once PreAssessment was done, but before Kempe added
AND casestartdate <= DATEADD(dd,1,DATEDIFF(dd,0,GETDATE()))

-- Get a distinct list after concatenating tcid's
DECLARE @caselist_distinct TABLE(
	CaseWeight FLOAT, 
	Enrolled_Cases INT, 
	Preintake_Cases INT, 
	pc1id VARCHAR(13), 
	currentlevel VARCHAR(200),
	pcfirstname VARCHAR(200),
	pclastname VARCHAR(200), 
	street VARCHAR(200),
	pccity VARCHAR(200), 
	pcstate VARCHAR(2), 
	pczip VARCHAR(200),
	pcphone VARCHAR(200),
	TargetChild VARCHAR(200),
	worker VARCHAR(200),
	supervisor VARCHAR(200)
)

INSERT INTO @caselist_distinct
SELECT DISTINCT
	CaseWeight,
	(SELECT COUNT(DISTINCT PC1ID) FROM @caselist c2 WHERE codelevelpk >= 12 AND c2.worker = r1.worker) AS Enrolled_Cases,
	(SELECT COUNT(DISTINCT PC1ID) FROM @caselist c2 WHERE codelevelpk IN(9, 10) AND c2.worker = r1.worker) AS Preintake_Cases,
	pc1id, 
	RTRIM(levelname) + ' (' + CONVERT(VARCHAR(12),currentleveldate, 101) + ')' currentlevel,
	pcfirstname,
	pclastname,
	street,
	pccity, 
	pcstate, 
	pczip,
	pcphone,
	CASE 
		WHEN tcdob IS NOT NULL THEN
			-- concatenate tcid's and hvcase.tcdob
			SUBSTRING ((SELECT DISTINCT ', ' + tcfirstname + ' ' + tclastname FROM @caselist r2 WHERE r1.pc1id = r2.pc1id FOR XML PATH ( '' ) ), 3, 1000) + ' (' + CONVERT(VARCHAR(12),tcdob, 101) + ')'
		ELSE 
			'EDC: (' + CONVERT(VARCHAR(12),edc, 101) + ')' 
	END TargetChild,
	worker,
	supervisor
FROM @caselist r1	

-- Final Query
SELECT 
	@programfk programfk,
	@supervisorfk supervisorfk,
	@workerfk workerfk,
	(SELECT ISNULL(SUM(CaseWeight), 0) FROM @caselist_distinct c2 WHERE c2.worker = r1.worker) AS CaseWeight_ttl, 
	Enrolled_Cases,
	Preintake_Cases,
	PC1ID,
	CurrentLevel,
	LTRIM(RTRIM(pcfirstname)) + ' ' + LTRIM(RTRIM(pclastname)) AS PC1,
	street,
	PCCity, 
	PCState, 
	PCZip,
	PCPhone,
	TargetChild,
	worker,
	Supervisor
FROM @caselist_distinct r1
ORDER BY supervisor, worker, pclastname



GO
