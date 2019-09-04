SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAttachmentCategory](@AttachmentCategoryPK int=NULL,
@AttachmentFK int=NULL,
@AttachmentCategoryFK int=NULL)
AS
UPDATE AttachmentCategory
SET 
AttachmentFK = @AttachmentFK, 
AttachmentCategoryFK = @AttachmentCategoryFK
WHERE AttachmentCategoryPK = @AttachmentCategoryPK
GO
