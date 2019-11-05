SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spUpdateAttachemntLink] @AttachmentPK INT, @newPath VARCHAR(max), @desc VARCHAR(MAX), @newdate datetime as


UPDATE dbo.Attachment SET AttachmentFilePath = @newPath, AttachmentDescription = @desc, FormDate =@newdate 
WHERE AttachmentPK = @AttachmentPK
GO
