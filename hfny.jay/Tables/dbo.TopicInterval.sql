CREATE TABLE [dbo].[TopicInterval]
(
[TopicIntervalPK] [int] NOT NULL IDENTITY(1, 1),
[CompareEventName] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysReferrence] [int] NULL,
[ProgramFK] [int] NULL,
[RequiredBy] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SATFK] [int] NULL,
[SubTopicFK] [int] NULL,
[SubtopicName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopicFK] [int] NULL,
[TopicIntervalPK_old] [int] NOT NULL,
[TopicName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingInterval] [char] (41) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TopicInterval] ADD CONSTRAINT [PK__TopicInt__1A4C717F0E391C95] PRIMARY KEY CLUSTERED  ([TopicIntervalPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TopicInterval] WITH NOCHECK ADD CONSTRAINT [FK_TopicInterval_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[TopicInterval] WITH NOCHECK ADD CONSTRAINT [FK_TopicInterval_SATFK] FOREIGN KEY ([SATFK]) REFERENCES [dbo].[codeSAT] ([codeSATPK])
GO
ALTER TABLE [dbo].[TopicInterval] WITH NOCHECK ADD CONSTRAINT [FK_TopicInterval_SubTopicFK] FOREIGN KEY ([SubTopicFK]) REFERENCES [dbo].[SubTopic] ([SubTopicPK])
GO
ALTER TABLE [dbo].[TopicInterval] WITH NOCHECK ADD CONSTRAINT [FK_TopicInterval_TopicFK] FOREIGN KEY ([TopicFK]) REFERENCES [dbo].[Topic] ([TopicPK])
GO
