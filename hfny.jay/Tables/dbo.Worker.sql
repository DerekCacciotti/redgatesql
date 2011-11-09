CREATE TABLE [dbo].[Worker]
(
[WorkerPK] [int] NOT NULL IDENTITY(1, 1),
[Apt] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQTrainingDate] [datetime] NULL,
[CellPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Children] [bit] NULL,
[City] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationLevel] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAWCoreDate] [datetime] NULL,
[FAWInitialStart] [datetime] NULL,
[FirstName] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FSWCoreDate] [datetime] NULL,
[FSWInitialStart] [datetime] NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HomePhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LanguageSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherLanguage] [bit] NULL,
[PreviousName] [char] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorCoreDate] [datetime] NULL,
[SupervisorFirstEvent] [datetime] NULL,
[SupervisorInitialStart] [datetime] NULL,
[WorkerCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Worker_WorkerCreateDate] DEFAULT (getdate()),
[WorkerCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WorkerDOB] [datetime] NULL,
[WorkerEditDate] [datetime] NULL,
[WorkerEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkerPK_old] [int] NOT NULL,
[YoungestChild] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Zip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_WorkerEditDate ON Worker
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_WorkerEditDate] ON [dbo].[Worker]
For Update 
AS
Update Worker Set Worker.WorkerEditDate= getdate()
From [Worker] INNER JOIN Inserted ON [Worker].[WorkerPK]= Inserted.[WorkerPK]
GO
ALTER TABLE [dbo].[Worker] ADD CONSTRAINT [PK__Worker__077F67A4251C81ED] PRIMARY KEY CLUSTERED  ([WorkerPK]) ON [PRIMARY]
GO
