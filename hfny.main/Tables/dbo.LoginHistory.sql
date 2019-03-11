CREATE TABLE [dbo].[LoginHistory]
(
[LoginHistoryPK] [int] NOT NULL IDENTITY(1, 1),
[Username] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoginTime] [datetime] NOT NULL,
[Role] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NULL,
[LogoutTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoginHistory] ADD CONSTRAINT [PK_LoginHistory] PRIMARY KEY CLUSTERED  ([LoginHistoryPK]) ON [PRIMARY]
GO
