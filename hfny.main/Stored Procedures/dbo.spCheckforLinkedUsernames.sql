SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spCheckforLinkedUsernames] @username VARCHAR(max), @ProgramFK INT AS 
SELECT w.UserName FROM Worker w INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK
WHERE w.UserName = @username AND wp.ProgramFK = @ProgramFK
GO
