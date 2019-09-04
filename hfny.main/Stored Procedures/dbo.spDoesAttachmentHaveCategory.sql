SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spDoesAttachmentHaveCategory] @attachmentPK INT AS 


SELECT TOP 1 * FROM dbo.AttachmentCategory WHERE AttachmentFK = @attachmentPK
GO
