SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spisWorkeraSupervisor] @username VARCHAR(max), @programfk INT AS

SELECT * FROM Worker w 
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK 
WHERE wp.TerminationDate IS NULL 
AND wp.SupervisorStartDate IS NOT NULL AND w.UserName = @username AND wp.ProgramFK = @programfk 
GO
