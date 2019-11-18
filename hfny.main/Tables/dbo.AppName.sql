CREATE TABLE [dbo].[AppName]
(
[AppNamePK] [int] NOT NULL,
[AppName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppName] ADD CONSTRAINT [CK_AppNameOneRow] CHECK (([AppNamePK]=(1)))
GO
ALTER TABLE [dbo].[AppName] ADD CONSTRAINT [PK_AppName] PRIMARY KEY CLUSTERED  ([AppNamePK]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Only allow 1 row in this table', 'SCHEMA', N'dbo', 'TABLE', N'AppName', 'CONSTRAINT', N'CK_AppNameOneRow'
GO
