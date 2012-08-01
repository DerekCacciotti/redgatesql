CREATE TABLE [dbo].[codeTopic]
(
[codeTopicPK] [int] NOT NULL IDENTITY(1, 1),
[TopicName] [char] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TopicCode] [numeric] (4, 1) NOT NULL,
[TopicPK_old] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeTopic] ADD CONSTRAINT [PK__Topic__022EC8500A688BB1] PRIMARY KEY CLUSTERED  ([codeTopicPK]) ON [PRIMARY]
GO