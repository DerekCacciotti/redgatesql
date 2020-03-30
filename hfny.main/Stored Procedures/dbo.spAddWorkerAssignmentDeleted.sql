SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorkerAssignmentDeleted](@WorkerAsskignmentPK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@WorkerAssignmentDeleteDate datetime=NULL,
@WorkerAssignmentDeleter varchar(max)=NULL,
@WorkerAssignmentCreator varchar(max)=NULL,
@WorkerAssignmentDate datetime=NULL,
@WorkerFK int=NULL)
AS
INSERT INTO WorkerAssignmentDeleted(
WorkerAsskignmentPK,
HVCaseFK,
ProgramFK,
WorkerAssignmentDeleteDate,
WorkerAssignmentDeleter,
WorkerAssignmentCreator,
WorkerAssignmentDate,
WorkerFK
)
VALUES(
@WorkerAsskignmentPK,
@HVCaseFK,
@ProgramFK,
@WorkerAssignmentDeleteDate,
@WorkerAssignmentDeleter,
@WorkerAssignmentCreator,
@WorkerAssignmentDate,
@WorkerFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
