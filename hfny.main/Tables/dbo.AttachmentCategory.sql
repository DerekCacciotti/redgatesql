CREATE TABLE [dbo].[AttachmentCategory]
(
[AttachmentCategoryPK] [int] NOT NULL IDENTITY(1, 1),
[AttachmentFK] [int] NOT NULL,
[AttachmentCategoryFK] [int] NOT NULL,
[AttachmentCategoryCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentCategoryCreateDate] [datetime] NULL,
[AttachmentCategoryEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AttachmentCategoryEditDate] [datetime] NULL,
[AttachmentType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttachmentCategory] ADD CONSTRAINT [PK__Attachme__AB86ECEECE748D3F] PRIMARY KEY CLUSTERED  ([AttachmentCategoryPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AttachmentCategory] ADD CONSTRAINT [FK_AttachmentCategory_Attachment] FOREIGN KEY ([AttachmentFK]) REFERENCES [dbo].[Attachment] ([AttachmentPK])
GO
