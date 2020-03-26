SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelWorkerAssignmentDeleted](@WorkerAssignmentDeletedPK int)

AS


DELETE 
FROM WorkerAssignmentDeleted
WHERE WorkerAssignmentDeletedPK = @WorkerAssignmentDeletedPK
GO
