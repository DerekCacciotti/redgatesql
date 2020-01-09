SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetCasesforreassignment] @workerfk INT, @programfk INT AS 
-- fss cases
SELECT cp.PC1ID, CONCAT(p.PCFirstName, ' ', p.PCLastName) AS PCName, 'FSS' AS WorkerType FROM CaseProgram cp 
INNER JOIN HVCase hc ON hc.HVCasePK = cp.HVCaseFK
INNER JOIN PC p ON p.PCPK = hc.PC1FK
WHERE cp.CurrentFSWFK = @workerfk AND cp.DischargeDate IS NULL AND cp.ProgramFK = @programfk

UNION
 -- FRS Cases 
 SELECT cp.PC1ID, CONCAT(p.PCFirstName, ' ', p.PCLastName) AS PCName, 'FRS' AS WorkerType FROM CaseProgram cp 
INNER JOIN HVCase hc ON hc.HVCasePK = cp.HVCaseFK
INNER JOIN PC p ON p.PCPK = hc.PC1FK
WHERE cp.CurrentFAWFK = @workerfk  AND cp.DischargeDate IS NULL AND cp.ProgramFK = @programfk
GO
