CREATE TABLE [dbo].[PublishShutdown]
(
[PublishShutdownPK] [int] NOT NULL IDENTITY(1, 1),
[PublishShutdownCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PublishShutdownCreateDate] [datetime] NULL,
[PublishShutdownStart] [datetime] NOT NULL,
[PublishShutdownEnd] [datetime] NOT NULL,
[PublishShutdownEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublishShutdownEditDate] [datetime] NULL,
[PublishShutdownMessage] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[trPublishCreateDate] ON [dbo].[PublishShutdown] AFTER INSERT AS
DECLARE @pk INT = (SELECT i.PublishShutdownPK FROM Inserted i)

UPDATE PublishShutdown SET PublishShutdownCreateDate = GETDATE() WHERE PublishShutdownPK = @pk 
GO
ALTER TABLE [dbo].[PublishShutdown] ADD CONSTRAINT [PK_PublishShutdown] PRIMARY KEY CLUSTERED  ([PublishShutdownPK]) ON [PRIMARY]
GO
