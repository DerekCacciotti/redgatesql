SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetLastAttachmentEntered] @Username VARCHAR(MAX), @AttachmentTitle VARCHAR(255) AS


SELECT dbo.Attachment.AttachmentPK FROM dbo.Attachment WHERE AttachmentCreator = @Username AND AttachmentTitle = @AttachmentTitle
ORDER BY AttachmentCreateDate DESC 
GO
