CREATE TABLE [dbo].[PublishShutdown]
(
[PublishShutdownPK] [int] NOT NULL IDENTITY(1, 1),
[PublishShutdownCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PublishShutdownCreateDate] [datetime] NULL,
[PublishShutdownStartDate] [datetime] NOT NULL,
[PublishShutdownEndDate] [datetime] NOT NULL,
[PublishShutdownEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublishShutdownEditDate] [datetime] NULL,
[PublishShutdownMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PublishShutdown] ADD CONSTRAINT [PK_PublishShutdown] PRIMARY KEY CLUSTERED  ([PublishShutdownPK]) ON [PRIMARY]
GO
