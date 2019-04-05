SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalNotImmunizations] AS
--- DOES NOT INCLUDE TC EMERGENCY ROOM VISIT, TC URGENT CARE AND NOT WELL BABY VISITY
SELECT MedicalItemCode, MedicalItemText
	FROM dbo.codeMedicalItem
	WHERE MedicalItemUsedWhere = 'TM' AND MedicalItemGroup IS  NULL AND MedicalItemCode != 16
	 AND MedicalItemCode != 17 AND MedicalItemCode != 18
	ORDER BY CAST(MedicalItemCode AS int)
GO
