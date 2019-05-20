SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spIsUserAWorker] @username VARCHAR(MAX), @ProgramFK INT AS 

SELECT TOP 1 *  FROM dbo.Worker INNER JOIN dbo.WorkerProgram ON WorkerProgram.WorkerFK = Worker.WorkerPK 
WHERE UserName = @username AND ProgramFK = @ProgramFK
GO
