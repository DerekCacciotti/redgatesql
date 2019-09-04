CREATE TABLE [dbo].[AttachmentCategory]
(
[AttachmentCategoryPK] [int] NOT NULL IDENTITY(1, 1),
[AttachmentFK] [int] NOT NULL,
[AttachmentCategoryFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttachmentCategory] ADD CONSTRAINT [PK__Attachme__AB86ECEECE748D3F] PRIMARY KEY CLUSTERED  ([AttachmentCategoryPK]) ON [PRIMARY]
GO
