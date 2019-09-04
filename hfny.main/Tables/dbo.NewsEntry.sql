CREATE TABLE [dbo].[NewsEntry]
(
[NewsEntryPK] [int] NOT NULL IDENTITY(1, 1),
[EntryDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NewsEntry] ADD CONSTRAINT [PK_NewsEntry] PRIMARY KEY CLUSTERED  ([NewsEntryPK]) ON [PRIMARY]
GO
