SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditWorkerAssignmentDeleted](@WorkerAssignmentDeletedPK int=NULL,
@WorkerAsskignmentPK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@WorkerAssignmentDeleteDate datetime=NULL,
@WorkerAssignmentDeleter varchar(max)=NULL,
@WorkerAssignmentDate datetime=NULL,
@WorkerAssignmentEditor varchar(max)=NULL,
@WorkerFK int=NULL)
AS
UPDATE WorkerAssignmentDeleted
SET 
WorkerAsskignmentPK = @WorkerAsskignmentPK, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
WorkerAssignmentDeleteDate = @WorkerAssignmentDeleteDate, 
WorkerAssignmentDeleter = @WorkerAssignmentDeleter, 
WorkerAssignmentDate = @WorkerAssignmentDate, 
WorkerAssignmentEditor = @WorkerAssignmentEditor, 
WorkerFK = @WorkerFK
WHERE WorkerAssignmentDeletedPK = @WorkerAssignmentDeletedPK
GO
