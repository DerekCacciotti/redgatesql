SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetWorkerAssignmentDeletedbyPK]

(@WorkerAssignmentDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM WorkerAssignmentDeleted
WHERE WorkerAssignmentDeletedPK = @WorkerAssignmentDeletedPK
GO
