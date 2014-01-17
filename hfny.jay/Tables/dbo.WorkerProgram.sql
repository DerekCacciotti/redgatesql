CREATE TABLE [dbo].[WorkerProgram]
(
[WorkerProgramPK] [int] NOT NULL IDENTITY(1, 1),
[CommunityOutreach] [bit] NULL,
[DirectParticipantServices] [bit] NULL,
[FatherAdvocate] [bit] NULL,
[FatherAdvocateEndDate] [datetime] NULL,
[FatherAdvocateStartDate] [datetime] NULL,
[FAW] [bit] NULL,
[FAWEndDate] [datetime] NULL,
[FAWStartDate] [datetime] NULL,
[FSW] [bit] NULL,
[FSWEndDate] [datetime] NULL,
[FSWStartDate] [datetime] NULL,
[FundRaiser] [bit] NULL,
[HireDate] [datetime] NOT NULL,
[LivesTargetArea] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[ProgramManager] [bit] NULL,
[ProgramManagerEndDate] [datetime] NULL,
[ProgramManagerStartDate] [datetime] NULL,
[SiteFK] [int] NULL,
[Supervisor] [bit] NULL,
[SupervisorEndDate] [datetime] NULL,
[SupervisorFK] [int] NULL,
[SupervisorStartDate] [datetime] NULL,
[TerminationDate] [datetime] NULL,
[WorkerFK] [int] NOT NULL,
[WorkerNotes] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkerProgramCreateDate] [datetime] NOT NULL CONSTRAINT [DF_WorkerProgram_WorkerProgramCreateDate] DEFAULT (getdate()),
[WorkerProgramCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkerProgramEditDate] [datetime] NULL,
[WorkerProgramEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'WorkerProgram', 'COLUMN', N'WorkerProgramPK'
GO

ALTER TABLE [dbo].[WorkerProgram] WITH NOCHECK ADD
CONSTRAINT [FK_WorkerProgram_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
ALTER TABLE [dbo].[WorkerProgram] WITH NOCHECK ADD
CONSTRAINT [FK_WorkerProgram_SupervisorFK] FOREIGN KEY ([SupervisorFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
ALTER TABLE [dbo].[WorkerProgram] WITH NOCHECK ADD
CONSTRAINT [FK_WorkerProgram_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
CREATE NONCLUSTERED INDEX [IX_FK_WorkerProgram_ProgramFK] ON [dbo].[WorkerProgram] ([ProgramFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_WorkerProgram_SiteFK] ON [dbo].[WorkerProgram] ([SiteFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_WorkerProgram_SupervisorFK] ON [dbo].[WorkerProgram] ([SupervisorFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_WorkerProgram_WorkerFK] ON [dbo].[WorkerProgram] ([WorkerFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_WorkerProgram_ProgramFK] ON [dbo].[WorkerProgram] ([ProgramFK]) ON [PRIMARY]

ALTER TABLE [dbo].[WorkerProgram] WITH NOCHECK ADD
CONSTRAINT [FK_WorkerProgram_SiteFK] FOREIGN KEY ([SiteFK]) REFERENCES [dbo].[listSite] ([listSitePK])

GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_WorkerProgramEditDate ON WorkerProgram
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_WorkerProgramEditDate] ON [dbo].[WorkerProgram]
For Update 
AS
Update WorkerProgram Set WorkerProgram.WorkerProgramEditDate= getdate()
From [WorkerProgram] INNER JOIN Inserted ON [WorkerProgram].[WorkerProgramPK]= Inserted.[WorkerProgramPK]
GO
ALTER TABLE [dbo].[WorkerProgram] ADD CONSTRAINT [PK__WorkerPr__61F2F2132EA5EC27] PRIMARY KEY CLUSTERED  ([WorkerProgramPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkerProgram] ON [dbo].[WorkerProgram] ([WorkerFK]) ON [PRIMARY]
GO
