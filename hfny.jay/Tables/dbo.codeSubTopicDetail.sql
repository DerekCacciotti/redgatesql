CREATE TABLE [dbo].[codeSubTopicDetail]
(
[codeSubTopicDetailPK] [int] NOT NULL IDENTITY(1, 1),
[CompareToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DaysRequired] [int] NULL,
[Interval] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequiredBy] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SATFK] [money] NULL,
[SubTopicFK] [int] NULL,
[SubTopicName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopicFK] [int] NULL,
[TopicName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STDetailPK_old] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeSubTopicDetail] ADD CONSTRAINT [PK_codeSubTopicDetail] PRIMARY KEY CLUSTERED  ([codeSubTopicDetailPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeSubTopicDetail] WITH NOCHECK ADD CONSTRAINT [FK_codeSubTopicDetail_codeSAT] FOREIGN KEY ([SATFK]) REFERENCES [dbo].[codeSAT] ([codeSATPK])
GO
ALTER TABLE [dbo].[codeSubTopicDetail] WITH NOCHECK ADD CONSTRAINT [FK_codeSubTopicDetail_SubTopic] FOREIGN KEY ([SubTopicFK]) REFERENCES [dbo].[SubTopic] ([SubTopicPK])
GO
ALTER TABLE [dbo].[codeSubTopicDetail] WITH NOCHECK ADD CONSTRAINT [FK_codeSubTopicDetail_codeTopic] FOREIGN KEY ([TopicFK]) REFERENCES [dbo].[codeTopic] ([codeTopicPK])
GO
