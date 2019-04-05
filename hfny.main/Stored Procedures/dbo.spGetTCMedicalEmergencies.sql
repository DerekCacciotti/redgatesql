SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalEmergencies] AS 


SELECT MedicalItemCode, MedicalItemText
	FROM dbo.codeMedicalItem
	WHERE MedicalItemUsedWhere = 'TM' AND MedicalItemGroup IS  NULL and MedicalItemCode = 16
	 OR MedicalItemCode = 17 OR MedicalItemCode = 18
	ORDER BY CAST(MedicalItemCode AS int)
GO
