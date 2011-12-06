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











GO
