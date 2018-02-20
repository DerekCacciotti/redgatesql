CREATE TABLE [dbo].[QuickLink]
(
[QuickLinkPK] [int] NOT NULL IDENTITY(1, 1),
[LinkType] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LinkURL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[QuickLink] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
