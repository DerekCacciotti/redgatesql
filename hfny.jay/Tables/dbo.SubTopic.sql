CREATE TABLE [dbo].[SubTopic]
(
[SubTopicPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[RequiredBy] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SATFK] [int] NOT NULL,
[SubTopicCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubTopicCreateDate] [datetime] NULL,
[SubTopicCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubTopicEditDate] [datetime] NULL,
[SubTopicEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubTopicName] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubTopicPK_old] [int] NOT NULL,
[TopicFK] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[SubTopic] WITH NOCHECK ADD
CONSTRAINT [FK_SubTopic_TopicFK] FOREIGN KEY ([TopicFK]) REFERENCES [dbo].[codeTopic] ([codeTopicPK])
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_SubTopicEditDate ON SubTopic
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_SubTopicEditDate] ON dbo.SubTopic
For Update 
AS
Update SubTopic Set SubTopic.SubTopicEditDate= getdate()
From [SubTopic] INNER JOIN Inserted ON [SubTopic].[SubTopicPK]= Inserted.[SubTopicPK]
GO
ALTER TABLE [dbo].[SubTopic] ADD CONSTRAINT [PK__SubTopic__3EC19D447849DB76] PRIMARY KEY CLUSTERED  ([SubTopicPK]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SubTopic] WITH NOCHECK ADD CONSTRAINT [FK_SubTopic_SATFK] FOREIGN KEY ([SATFK]) REFERENCES [dbo].[codeSAT] ([codeSATPK])
GO
