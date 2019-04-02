SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[SPGetTCMedicalImmunizations] AS


SELECT MedicalItemCode, MedicalItemText
	FROM dbo.codeMedicalItem
	WHERE MedicalItemUsedWhere = 'TM' AND MedicalItemGroup = 'Immunization'
	ORDER BY CAST(MedicalItemCode AS int)
GO
