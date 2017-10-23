SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2017-10-19
-- Description:	Replaces all WorkerFK-related columns in all containing tables 
-- pr_ReplaceWorkerFK 15, 16
-- =============================================
CREATE procedure [dbo].[pr_ReplaceWorkerFK]
(
		@NewWorkerFK int, 
		@OldWorkerFK int
)

-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
as
;

update ASQ 
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update ASQSE
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update CaseProgram 
set CurrentFAFK = @NewWorkerFK
where CurrentFAFK = @OldWorkerFK
update CaseProgram 
set CurrentFAWFK = @NewWorkerFK
where CurrentFAWFK = @OldWorkerFK
update CaseProgram 
set CurrentFSWFK = @NewWorkerFK
where CurrentFSWFK = @OldWorkerFK

update FatherFigure
set FatherAdvocateFK = @NewWorkerFK
where FatherAdvocateFK = @OldWorkerFK

update FollowUp 
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update HVGroup
set FAModerator1 = @NewWorkerFK
where FAModerator1 = @OldWorkerFK
update HVGroup
set FAModerator2 = @NewWorkerFK
where FAModerator2 = @OldWorkerFK

update HVLog
set FatherAdvocateFK = @NewWorkerFK
where FatherAdvocateFK = @OldWorkerFK
update HVLog 
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK
update HVLog
set NonPrimaryFSWFK = @NewWorkerFK
where NonPrimaryFSWFK = @OldWorkerFK

update HVLogOld
set FatherAdvocateFK = @NewWorkerFK
where FatherAdvocateFK = @OldWorkerFK
update HVLogOld
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK
update HVLogOld
set NonPrimaryFSWFK = @NewWorkerFK
where NonPrimaryFSWFK = @OldWorkerFK

update HVScreen
set FAWFK  = @NewWorkerFK
where FAWFK = @OldWorkerFK

update Intake
set FSWFK  = @NewWorkerFK
where FSWFK = @OldWorkerFK

update Kempe
set FAWFK = @NewWorkerFK
where FAWFK = @OldWorkerFK

update Preassessment
set PAFAWFK = @NewWorkerFK
where PAFAWFK = @OldWorkerFK
update Preassessment
set PAFSWFK = @NewWorkerFK
where PAFSWFK = @OldWorkerFK

update Preintake
set PIFSWFK = @NewWorkerFK
where PIFSWFK = @OldWorkerFK

update PSI
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update ServiceReferral
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update Supervision
set SupervisorFK = @NewWorkerFK
where SupervisorFK = @OldWorkerFK
update Supervision
set WorkerFK = @NewWorkerFK
where WorkerFK = @OldWorkerFK

update TCID
set FSWFK = @NewWorkerFK
where FSWFK = @OldWorkerFK

update TrainingAttendee
set WorkerFK = @NewWorkerFK
where WorkerFK = @OldWorkerFK

update WorkerAssignment
set WorkerFK  = @NewWorkerFK
where WorkerFK = @OldWorkerFK

update WorkerProgram
set SupervisorFK  = @NewWorkerFK
where SupervisorFK = @OldWorkerFK
--update WorkerProgram
--set WorkerFK = @NewWorkerFK
--where WorkerFK = @OldWorkerFK

GO
