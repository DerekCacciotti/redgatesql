CREATE TABLE [dbo].[Topic]
(
[TopicPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[TopicName] [char] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TopicCode] [numeric] (4, 1) NOT NULL,
[TopicPK_old] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Topic] ADD CONSTRAINT [PK__Topic__022EC8500A688BB1] PRIMARY KEY CLUSTERED  ([TopicPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Topic] WITH NOCHECK ADD CONSTRAINT [FK_Topic_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
