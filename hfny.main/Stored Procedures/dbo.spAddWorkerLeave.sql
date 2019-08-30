SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorkerLeave](@WorkerFK int=NULL,
@WorkerProgramFK int=NULL,
@ProgramFK int=NULL,
@LeaveStartDate datetime=NULL,
@LeaveEndDate datetime=NULL)
AS
INSERT INTO WorkerLeave(
WorkerFK,
WorkerProgramFK,
ProgramFK,
LeaveStartDate,
LeaveEndDate
)
VALUES(
@WorkerFK,
@WorkerProgramFK,
@ProgramFK,
@LeaveStartDate,
@LeaveEndDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
