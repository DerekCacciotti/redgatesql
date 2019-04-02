SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalNotImmunizations] AS

SELECT MedicalItemCode, MedicalItemText
	FROM dbo.codeMedicalItem
	WHERE MedicalItemUsedWhere = 'TM' AND MedicalItemGroup IS  NULL
	ORDER BY CAST(MedicalItemCode AS int)
GO
