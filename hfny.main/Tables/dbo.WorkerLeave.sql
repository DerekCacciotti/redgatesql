CREATE TABLE [dbo].[WorkerLeave]
(
[WorkerLeavePK] [int] NOT NULL IDENTITY(1, 1),
[WorkerFK] [int] NOT NULL,
[WorkerProgramFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[LeaveStartDate] [datetime] NOT NULL,
[LeaveEndDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerLeave] ADD CONSTRAINT [PK_WorkerLeave] PRIMARY KEY CLUSTERED  ([WorkerLeavePK]) ON [PRIMARY]
GO
