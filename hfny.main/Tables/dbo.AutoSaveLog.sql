CREATE TABLE [dbo].[AutoSaveLog]
(
[AutoSavePK] [int] NOT NULL IDENTITY(1, 1),
[AutoSaveDate] [datetime] NOT NULL,
[AutoSaveCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormFK] [int] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AutoSaveLog] ADD CONSTRAINT [PK_AutoSaveLog] PRIMARY KEY CLUSTERED  ([AutoSavePK]) ON [PRIMARY]
GO
