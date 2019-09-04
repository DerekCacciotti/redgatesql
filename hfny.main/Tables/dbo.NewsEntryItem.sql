CREATE TABLE [dbo].[NewsEntryItem]
(
[NewsEntryItemPK] [int] NOT NULL IDENTITY(1, 1),
[Contents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrderBy] [int] NOT NULL,
[NewsEntryFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsEntryItem] ADD CONSTRAINT [PK_NewsEntryItem] PRIMARY KEY CLUSTERED  ([NewsEntryItemPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsEntryItem] ADD CONSTRAINT [FK_NewsEntryItem_NewsEntry] FOREIGN KEY ([NewsEntryFK]) REFERENCES [dbo].[NewsEntry] ([NewsEntryPK])
GO
