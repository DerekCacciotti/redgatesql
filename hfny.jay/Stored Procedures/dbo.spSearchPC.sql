
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[spSearchPC] (
	@PCFirstName VARCHAR(20) = NULL, @PCLastName VARCHAR(30) = NULL, @PCDOB DATETIME = NULL, 
	@PCPhone VARCHAR(12) = NULL, @PCEmergencyPhone VARCHAR(12) = NULL, 
	@Ethnicity VARCHAR(30) = NULL, @Race VARCHAR(2) = NULL, @ProgramFK INT = NULL)

AS

SET NOCOUNT ON
/*
SELECT pc.pcpk, pc.pcfirstname,pc.pclastname,pc.pcdob,
	pc.pcphone,pc.PCEmergencyPhone,
	CASE WHEN AppCodeText = 'Other' THEN racespecify ELSE AppCodeText END AS race,racespecify--,
	--caseprogram.dischargedate
FROM pc
LEFT JOIN codeApp
ON appcode = pc.race
AND appcodegroup = 'Race'
--INNER JOIN hvcase
--ON pcpk IN(cpfk, pc1fk, pc2fk, obpfk)
--INNER JOIN caseprogram
--ON hvcasefk = hvcasepk
WHERE (pc.pcfirstname LIKE @PCFirstName + '%'
OR pc.pclastname LIKE @PCLastName + '%'
OR pc.pcdob = @PCDOB
OR pc.pcphone = @PCPhone
OR pc.pcemergencyphone = @PCEmergencyPhone
OR pc.ethnicity = @Ethnicity
OR pc.race = @Race)
--AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
AND pcpk IN (SELECT pcfk FROM pcprogram WHERE ProgramFK = ISNULL(@ProgramFK, ProgramFK))
ORDER BY
CASE WHEN pc.pcfirstname LIKE @PCFirstName + '%' THEN 1 ELSE 0 END +
CASE WHEN pc.pclastname LIKE @PCLastName + '%' THEN 1 ELSE 0 END +
CASE WHEN pc.pcdob = @PCDOB THEN 1 ELSE 0 END +
CASE WHEN pc.pcphone = @PCPhone THEN 1 ELSE 0 END +
CASE WHEN pc.pcemergencyphone = @PCEmergencyPhone THEN 1 ELSE 0 END +
CASE WHEN pc.ethnicity = @Ethnicity THEN 1 ELSE 0 END +
CASE WHEN pc.race = @Race THEN 1 ELSE 0 END DESC
*/

; WITH xxx AS (
SELECT DISTINCT pc.pcpk, pc.pcfirstname,pc.pclastname,pc.pcdob,pc.pcphone,pc.PCEmergencyPhone, pc.race, pc.racespecify
FROM PC AS pc
WHERE 
(pc.pcfirstname LIKE @PCFirstName + '%'
OR pc.pclastname LIKE @PCLastName + '%'
OR pc.pcdob = @PCDOB
OR pc.pcphone = @PCPhone
OR pc.pcemergencyphone = @PCEmergencyPhone)
AND pc.pcpk IN (SELECT pcfk FROM pcprogram WHERE ProgramFK = ISNULL(@ProgramFK, ProgramFK))
)

, yy1 AS (
SELECT b.PCPK, max(a.HVCasePK) [HVCasePK]
FROM HVCase AS a
JOIN xxx AS b ON b.PCPK = a.PC1FK
GROUP BY b.PCPK
)

, yyy AS (
SELECT a.*, c.LevelName
FROM yy1 AS a
JOIN CaseProgram b ON a.HVCasePK = b.HVCaseFK
JOIN codeLevel AS c ON c.codeLevelPK = b.CurrentLevelFK
)

, zzzPC2 AS (
SELECT b.PCPK, count(*) [pc2]
FROM HVCase AS a
JOIN xxx AS b ON b.PCPK = a.pc2fk
GROUP BY b.PCPK
)

, zzzOBP AS (
SELECT b.PCPK, count(*) [obp]
FROM HVCase AS a
JOIN xxx AS b ON b.PCPK = a.obpfk
GROUP BY b.PCPK
)

, qqq AS (
SELECT 
a.pcpk, a.pcfirstname, a.pclastname, a.pcdob, a.pcphone, a.PCEmergencyPhone
,CASE WHEN AppCodeText = 'Other' THEN racespecify ELSE AppCodeText END AS race, a.racespecify
, status = 
CASE WHEN b.PCPK IS NOT NULL THEN b.LevelName + ' ' ELSE '' END +
CASE WHEN c.PCPK IS NOT NULL THEN 'PC2 ' ELSE '' END +
CASE WHEN d.PCPK IS NOT NULL THEN 'OBP ' ELSE '' END
FROM xxx AS a
LEFT OUTER JOIN yyy AS b ON b.pcpk = a.pcpk
LEFT OUTER JOIN zzzPC2 AS c ON c.pcpk = a.pcpk
LEFT OUTER JOIN zzzOBP AS d ON d.pcpk = a.pcpk
LEFT JOIN codeApp ON appcode = a.race AND appcodegroup = 'Race'
)

select * from qqq









GO
