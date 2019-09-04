SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAttachmentCategoryType] @AttachementFK INT AS 

SELECT * FROM dbo.AttachmentCategory WHERE AttachmentFK = @AttachementFK
GO
