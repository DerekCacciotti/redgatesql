SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetCaseNotesForDashboard] @supervisorfk INT, @programfk INT as

SELECT cp.PC1ID, cn.CaseNoteDate FROM CaseProgram cp 
INNER JOIN HVCase hc ON hc.HVCasePK = cp.HVCaseFK 
INNER JOIN CaseNote cn ON cn.HVCaseFK = cp.HVCaseFK
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp	ON wp.WorkerFK = w.WorkerPK
WHERE cn.ProgramFK = 1 AND wp.SupervisorFK = 155 AND cn.CaseNoteDate BETWEEN CAST(GETDATE() AS DATE) 
AND CAST(DATEADD(DAY, 7, GETDATE()) AS DATE)

--SELECT DATEADD(DAY,7,GETDATE())


GO
