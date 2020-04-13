SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spDoesKempeExists] @HVCaseFK INT, @ProgramFK INT AS 

SELECT * FROM Kempe k WHERE k.HVCaseFK = @HVCaseFK AND k.ProgramFK = ProgramFK 
GO
