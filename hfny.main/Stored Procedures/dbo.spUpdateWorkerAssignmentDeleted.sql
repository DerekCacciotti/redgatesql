SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spUpdateWorkerAssignmentDeleted] @workerAssignmentPK INT, @Username VARCHAR(max) AS

UPDATE WorkerAssignmentDeleted SET WorkerAssignmentDeleter = @Username WHERE WorkerAsskignmentPK = @workerAssignmentPK
GO
