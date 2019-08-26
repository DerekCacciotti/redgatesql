SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spIsWorkerFRS] @WorkerFK INT AS


SELECT * FROM  dbo.Worker INNER JOIN dbo.WorkerProgram wp ON wp.WorkerFK = Worker.WorkerPK WHERE dbo.Worker.WorkerPK = @WorkerFK AND wp.FAWStartDate IS NOT null
GO
