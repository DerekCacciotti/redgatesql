CREATE TABLE [dbo].[Attachment]
(
[AttachmentPK] [int] NOT NULL IDENTITY(1, 1),
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Attachment] [varbinary] (max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Attachment] ADD CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED  ([AttachmentPK]) ON [PRIMARY]
GO
