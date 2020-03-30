SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetWorkerStartDateForReassignment] @workerPK INT AS
SELECT * FROM Worker w INNER JOIN WorkerProgram wp  ON wp.WorkerFK = w.WorkerPK
WHERE w.WorkerPK = @workerPK

GO
