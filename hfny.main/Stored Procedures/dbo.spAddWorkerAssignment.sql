SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorkerAssignment](@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@WorkerAssignmentCreator varchar(max)=NULL,
@WorkerAssignmentDate datetime=NULL,
@WorkerFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) WorkerAssignmentPK
FROM WorkerAssignment lastRow
WHERE 
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK AND
@WorkerAssignmentCreator = lastRow.WorkerAssignmentCreator AND
@WorkerAssignmentDate = lastRow.WorkerAssignmentDate AND
@WorkerFK = lastRow.WorkerFK
ORDER BY WorkerAssignmentPK DESC) 
BEGIN
INSERT INTO WorkerAssignment(
HVCaseFK,
ProgramFK,
WorkerAssignmentCreator,
WorkerAssignmentDate,
WorkerFK
)
VALUES(
@HVCaseFK,
@ProgramFK,
@WorkerAssignmentCreator,
@WorkerAssignmentDate,
@WorkerFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
