SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Use of Creative Outreach - Detail>
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE PROCEDURE [dbo].[rspPC1IDList] (@programfk INT = 1)
AS

SELECT TOP 100 PERCENT 
	programname,
	hvcasepk,
	pc1id, 
	oldid,
	LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) as workername,
	codelevelpk, 
	levelname, 
	currentleveldate, 
	LTRIM(RTRIM(pc.pcfirstname))+ ' ' + LTRIM(RTRIM(pc.pclastname)) as pcname,
	LTRIM(RTRIM(tcid.tcfirstname)) + ' ' + LTRIM(RTRIM(tcid.tclastname)) as tcname,
	hvcase.tcdob, 
	hvcase.edc,
	hvcase.screendate,
	HVCase.kempedate,
	hvcase.intakedate,
	pc2fk,
    CASE WHEN pc2fk IS NULL OR pc2fk=0 THEN 0 ELSE 1 END AS pc2exists,
	CASE WHEN pc2fk IS NOT NULL AND pc2fk>0 
		 THEN (SELECT LTRIM(RTRIM(pcfirstname)) + ' ' + LTRIM(RTRIM(pclastname)) AS pc2name 
				  FROM pc WHERE pcpk=pc2fk) 
		 ELSE
			''
		 END AS pc2name,
    obpfk,
    CASE WHEN obpfk IS NULL OR obpfk=0 THEN 0 ELSE 1 END AS obpexists,
	CASE WHEN obpfk IS NOT NULL AND obpfk>0 
		 THEN (SELECT LTRIM(RTRIM(pcfirstname)) + ' ' + LTRIM(RTRIM(pclastname)) AS obpname 
				  FROM pc WHERE pcpk=obpfk) 
		 ELSE
			''
		 END AS obpname,
    cpfk as ecfk,
    CASE WHEN cpfk IS NULL OR cpfk=0 THEN 0 ELSE 1 END AS ecexists, 
	CASE WHEN cpfk IS NOT NULL AND cpfk>0 
		 THEN (SELECT LTRIM(RTRIM(pcfirstname)) + ' ' + LTRIM(RTRIM(pclastname)) AS cpname 
				  FROM pc WHERE pcpk=cpfk) 
		 ELSE
			''
		 END AS ecname
FROM hvcase
INNER JOIN caseprogram
ON caseprogram.hvcasefk = hvcasepk
INNER JOIN HVProgram
on hvprogrampk=caseprogram.programfk
INNER JOIN codelevel
ON codelevelpk = currentlevelfk
INNER JOIN pc
ON pc.pcpk = pc1fk
LEFT JOIN tcid
ON tcid.hvcasefk = hvcasepk
INNER JOIN worker fsw
ON CurrentFSWFK = fsw.workerpk
INNER JOIN workerprogram
ON workerfk = fsw.workerpk
WHERE caseprogram.programfk = @programfk
AND dischargedate IS NULL
AND kempedate IS NOT NULL
AND casestartdate <= DATEADD(dd,1,DATEDIFF(dd,0,GETDATE()))
ORDER BY workername,oldid,screendate

/* SET NOCOUNT ON */
RETURN


GO
