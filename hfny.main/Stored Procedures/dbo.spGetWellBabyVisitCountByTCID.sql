SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetWellBabyVisitCountByTCID] @TCIDFK INT, @ProgramFK int AS 

SELECT COUNT(*) AS results FROM dbo.TCMedical
INNER JOIN dbo.codeMedicalItem cmi 
ON TCMedicalItem = cmi.MedicalItemCode WHERE TCIDFK = @TCIDFK AND cmi.MedicalItemText = 'Well Baby Visit' AND 
ProgramFK = @ProgramFK
GO
