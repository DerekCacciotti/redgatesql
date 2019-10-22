SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetSupervisorWorker] @SupervisorFK INT AS 

SELECT COUNT(*)  AS WorkerCount 
FROM WorkerProgram wp 
WHERE wp.SupervisorFK = @SupervisorFK
AND wp.TerminationDate IS NULL
GO
