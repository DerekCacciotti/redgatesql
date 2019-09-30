SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAttachmentCategory](@AttachmentCategoryPK int=NULL,
@AttachmentFK int=NULL,
@AttachmentCategoryFK int=NULL,
@AttachmentCategoryEditor varchar(max)=NULL,
@AttachmentType varchar(10)=NULL)
AS
UPDATE AttachmentCategory
SET 
AttachmentFK = @AttachmentFK, 
AttachmentCategoryFK = @AttachmentCategoryFK, 
AttachmentCategoryEditor = @AttachmentCategoryEditor, 
AttachmentType = @AttachmentType
WHERE AttachmentCategoryPK = @AttachmentCategoryPK
GO
