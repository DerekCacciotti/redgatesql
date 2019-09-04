CREATE TABLE [dbo].[codeAttachmentCategory]
(
[codeAttachmentCategoryPK] [int] NOT NULL IDENTITY(1, 1),
[AttachmentCategory] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeAttachmentCategory] ADD CONSTRAINT [PK__codeAtta__53B9D0CF83768D07] PRIMARY KEY CLUSTERED  ([codeAttachmentCategoryPK]) ON [PRIMARY]
GO
