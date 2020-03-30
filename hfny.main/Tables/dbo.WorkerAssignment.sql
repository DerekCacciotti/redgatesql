CREATE TABLE [dbo].[WorkerAssignment]
(
[WorkerAssignmentPK] [int] NOT NULL IDENTITY(1, 1),
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[WorkerAssignmentCreateDate] [datetime] NOT NULL CONSTRAINT [DF_WorkerAssignment_WorkerAssignmentCreateDate] DEFAULT (getdate()),
[WorkerAssignmentCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkerAssignmentDate] [datetime] NOT NULL,
[WorkerAssignmentEditDate] [datetime] NULL,
[WorkerAssignmentEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_delWorkerAssignment] ON [dbo].[WorkerAssignment] AFTER DELETE

AS 

INSERT INTO WorkerAssignmentDeleted
(
    WorkerAsskignmentPK,
    HVCaseFK,
    ProgramFK,
    WorkerAssignmentDeleteDate,
    WorkerAssignmentDeleter,
    WorkerAssignmentCreateDate,
    WorkerAssignmentCreator,
    WorkerAssignmentDate,
    WorkerAssignmentEditDate,
    WorkerAssignmentEditor,
    WorkerFK
)
SELECT d.WorkerAssignmentPK, d.HVCaseFK, d.ProgramFK, GETDATE(), NULL, d.WorkerAssignmentCreateDate,
d.WorkerAssignmentCreator,d.WorkerAssignmentDate, d.WorkerAssignmentEditDate,d.WorkerAssignmentEditor, d.WorkerFK 
FROM Deleted d WHERE d.WorkerAssignmentPK = d.WorkerAssignmentPK
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_WorkerAssignmentEditDate ON WorkerAssignment
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_WorkerAssignmentEditDate] ON [dbo].[WorkerAssignment]
For Update 
AS
Update WorkerAssignment Set WorkerAssignment.WorkerAssignmentEditDate= getdate()
From [WorkerAssignment] INNER JOIN Inserted ON [WorkerAssignment].[WorkerAssignmentPK]= Inserted.[WorkerAssignmentPK]
GO
ALTER TABLE [dbo].[WorkerAssignment] ADD CONSTRAINT [PK__WorkerAs__B02E01F929E1370A] PRIMARY KEY CLUSTERED  ([WorkerAssignmentPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_WorkerAssignment_HVCaseFK] ON [dbo].[WorkerAssignment] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_WorkerAssignment_ProgramFK] ON [dbo].[WorkerAssignment] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_WorkerAssignment_WorkerFK] ON [dbo].[WorkerAssignment] ([WorkerFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WorkerAssignment] WITH NOCHECK ADD CONSTRAINT [FK_WorkerAssignment_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[WorkerAssignment] WITH NOCHECK ADD CONSTRAINT [FK_WorkerAssignment_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[WorkerAssignment] WITH NOCHECK ADD CONSTRAINT [FK_WorkerAssignment_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'WorkerAssignment', 'COLUMN', N'WorkerAssignmentPK'
GO
