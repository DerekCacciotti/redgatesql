SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spIsUserAWorker] @username VARCHAR(max), @programfk INT AS


SELECT TOP 1 * FROM worker w INNER JOIN dbo.WorkerProgram wp ON wp.WorkerFK = w.WorkerPK

 WHERE w.UserName = @username AND wp.ProgramFK = @programfk
GO
