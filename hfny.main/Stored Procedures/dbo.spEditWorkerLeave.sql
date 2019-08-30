SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditWorkerLeave](@WorkerLeavePK int=NULL,
@WorkerFK int=NULL,
@WorkerProgramFK int=NULL,
@ProgramFK int=NULL,
@LeaveStartDate datetime=NULL,
@LeaveEndDate datetime=NULL)
AS
UPDATE WorkerLeave
SET 
WorkerFK = @WorkerFK, 
WorkerProgramFK = @WorkerProgramFK, 
ProgramFK = @ProgramFK, 
LeaveStartDate = @LeaveStartDate, 
LeaveEndDate = @LeaveEndDate
WHERE WorkerLeavePK = @WorkerLeavePK
GO
