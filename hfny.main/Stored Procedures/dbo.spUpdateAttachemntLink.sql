SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spUpdateAttachemntLink] @AttachmentPK INT, @newPath VARCHAR(max) as


UPDATE dbo.Attachment SET AttachmentFilePath = @newPath WHERE AttachmentPK = @AttachmentPK
GO
