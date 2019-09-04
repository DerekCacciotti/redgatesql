SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelAttachmentCategory](@AttachmentCategoryPK int)

AS


DELETE 
FROM AttachmentCategory
WHERE AttachmentCategoryPK = @AttachmentCategoryPK
GO
