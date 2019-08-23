SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetImmunizationCountByTCID] @TCIDFK INT AS 


(SELECT COUNT(*) AS results FROM dbo.TCMedical 
INNER JOIN dbo.codeMedicalItem cmi
ON TCMedicalItem = cmi.MedicalItemCode WHERE TCIDFK = @TCIDFK AND cmi.MedicalItemGroup = 'Immunization')
GO
