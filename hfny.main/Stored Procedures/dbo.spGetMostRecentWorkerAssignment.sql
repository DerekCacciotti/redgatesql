SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetMostRecentWorkerAssignment] @HVCaseFK INT AS
SELECT TOP  1 * FROM WorkerAssignment wa WHERE wa.HVCaseFK = @HVCaseFK
ORDER BY wa.WorkerAssignmentDate DESC
GO
