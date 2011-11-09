CREATE TABLE [dbo].[TrainingAttendee]
(
[TrainingAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[ExemptDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExemptType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExempt] [bit] NULL,
[ProgramFK] [int] NULL,
[SubtopicFK] [int] NULL,
[TopicFK] [int] NOT NULL,
[TrainingAttendeeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TrainingAttendee_TrainingAttendeeCreateDate] DEFAULT (getdate()),
[TrainingAttendeeCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingAttendeeEditDate] [datetime] NULL,
[TrainingAttendeeEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingAttendeePK_old] [int] NOT NULL,
[TrainingDetailFK] [int] NULL,
[TrainingFK] [int] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingAttendeeEditDate ON TrainingAttendee
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingAttendeeEditDate] ON dbo.TrainingAttendee
For Update 
AS
Update TrainingAttendee Set TrainingAttendee.TrainingAttendeeEditDate= getdate()
From [TrainingAttendee] INNER JOIN Inserted ON [TrainingAttendee].[TrainingAttendeePK]= Inserted.[TrainingAttendeePK]
GO
ALTER TABLE [dbo].[TrainingAttendee] ADD CONSTRAINT [PK__Training__C0BC3C361B9317B3] PRIMARY KEY CLUSTERED  ([TrainingAttendeePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_SubtopicFK] FOREIGN KEY ([SubtopicFK]) REFERENCES [dbo].[SubTopic] ([SubTopicPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_TopicFK] FOREIGN KEY ([TopicFK]) REFERENCES [dbo].[Topic] ([TopicPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_TrainingDetailFK] FOREIGN KEY ([TrainingDetailFK]) REFERENCES [dbo].[TrainingDetail] ([TrainingDetailPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_TrainingFK] FOREIGN KEY ([TrainingFK]) REFERENCES [dbo].[Training] ([TrainingPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] WITH NOCHECK ADD CONSTRAINT [FK_TrainingAttendee_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
