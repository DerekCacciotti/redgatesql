SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeAttachmentCategory](@codeAttachmentCategoryPK int=NULL,
@AttachmentCategory varchar(50)=NULL)
AS
UPDATE codeAttachmentCategory
SET 
AttachmentCategory = @AttachmentCategory
WHERE codeAttachmentCategoryPK = @codeAttachmentCategoryPK
GO
