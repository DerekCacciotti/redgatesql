SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[rspFAWTickler](@programfk VARCHAR(MAX) = NULL, @workerpk INT = NULL)
AS

IF @programfk IS NULL BEGIN
	SELECT @programfk = 
		SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
					FROM HVProgram
					FOR XML PATH('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','')

DECLARE @tickler TABLE(
	pc1id VARCHAR(13), 
	pcfirstname VARCHAR(200), 
	pclastname VARCHAR(200), 
	pcstreet VARCHAR(200), 
	pccity VARCHAR(200), 
	pcstate VARCHAR(2), 
	pczip VARCHAR(200), 
	pcphone VARCHAR(200), 
	screendate DATETIME,
	tcdob DATETIME, 
	natal VARCHAR(200),
	worker VARCHAR(200), 
	ReferralSourceName VARCHAR(200),
	padate VARCHAR(12)
)

INSERT INTO @tickler
SELECT 
	pc1id, 
	LTRIM(RTRIM(pc.pcfirstname)), 
	LTRIM(RTRIM(pc.pclastname)),
	pc.pcstreet, 
	pc.pccity, 
	pc.pcstate, 
	pc.pczip,
	pc.pcphone + 
		CASE 
			WHEN pc.PCEmergencyPhone IS NOT NULL THEN 
				', EMR: ' + pc.PCEmergencyPhone 
			ELSE 
				'' 
		END AS pcphone,
	hvcase.ScreenDate,
	CASE 
		WHEN hvcase.tcdob IS NOT NULL THEN
			hvcase.tcdob
		ELSE
			hvcase.edc
	END tcdob,
	CASE 
		WHEN hvcase.tcdob IS NOT NULL THEN
			'Post-Natal'
		ELSE
			'Pre-Natal'
	END natal,
	LTRIM(RTRIM(faw.firstname)) + ' ' + LTRIM(RTRIM(faw.lastname)) worker,
	ReferralSourceName,
	padate
FROM hvcase
INNER JOIN caseprogram
ON caseprogram.hvcasefk = hvcasepk
INNER JOIN hvscreen
ON hvscreen.hvcasefk = caseprogram.hvcasefk
AND hvscreen.programfk = caseprogram.programfk
INNER JOIN listReferralSource
ON ReferralSourceFK = listreferralsourcepk
LEFT JOIN preassessment
ON preassessment.hvcasefk = caseprogram.hvcasefk
AND preassessment.programfk = caseprogram.programfk
AND padate IN (
	SELECT MAX(padate) 
	FROM preassessment 
	WHERE hvcasefk = caseprogram.hvcasefk 
	AND programfk = caseprogram.programfk
)
LEFT JOIN kempe
ON kempe.hvcasefk = caseprogram.hvcasefk
AND kempe.programfk = caseprogram.programfk
INNER JOIN pc
ON pc.pcpk = pc1fk
INNER JOIN worker faw
ON CurrentFAWFK = faw.workerpk
INNER JOIN workerprogram
ON workerfk = faw.workerpk
INNER JOIN dbo.SplitString(@programfk,',')
ON caseprogram.programfk  = listitem
WHERE workerfk = ISNULL(@workerpk, workerfk)
AND dischargedate IS NULL
AND kempe.kempedate IS NULL
AND hvcase.ScreenDate IS NOT NULL
AND casestartdate <= DATEADD(dd,1,DATEDIFF(dd,0,GETDATE()))

-- Final Query
SELECT
	(SELECT COUNT(*) FROM @tickler t2 WHERE t2.worker = tickler.worker GROUP BY t2.worker) AS ttl,
	pc1id, pcfirstname + ' ' + pclastname pc1, 
	pcstreet, 
	pccity, 
	pcstate, 
	pczip, 
	pcphone, 
	screendate,
	tcdob,
	natal,
	worker,
	ReferralSourceName,
	DATEADD(dd, 14, tcdob) TargetDate,
	DATEADD(dd, 91, tcdob) AgeOutDate,
	CASE 
		WHEN padate IS NOT NULL THEN
			RIGHT('0' + RTRIM(MONTH(padate)),2) + '/' + RTRIM(YEAR(padate))
		ELSE
			'NONE'
	END PADate
FROM @tickler tickler
ORDER BY worker, screendate ASC, pclastname





GO
