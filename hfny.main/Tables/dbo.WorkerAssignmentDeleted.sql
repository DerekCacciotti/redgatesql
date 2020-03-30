CREATE TABLE [dbo].[WorkerAssignmentDeleted]
(
[WorkerAssignmentDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[WorkerAsskignmentPK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[WorkerAssignmentDeleteDate] [datetime] NULL,
[WorkerAssignmentDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkerAssignmentCreateDate] [datetime] NOT NULL,
[WorkerAssignmentCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkerAssignmentDate] [datetime] NOT NULL,
[WorkerAssignmentEditDate] [datetime] NULL,
[WorkerAssignmentEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerAssignmentDeleted] ADD CONSTRAINT [PK__WorkerAs__6F7C8FF66857ED35] PRIMARY KEY CLUSTERED  ([WorkerAssignmentDeletedPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerAssignmentDeleted] ADD CONSTRAINT [FK_WorkerAssignmentDeleted_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[WorkerAssignmentDeleted] ADD CONSTRAINT [FK_WorkerAssignmentDeleted_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[WorkerAssignmentDeleted] ADD CONSTRAINT [FK_WorkerAssignmentDeleted_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
