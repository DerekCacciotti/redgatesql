SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeAttachmentCategory](@codeAttachmentCategoryPK int)

AS


DELETE 
FROM codeAttachmentCategory
WHERE codeAttachmentCategoryPK = @codeAttachmentCategoryPK
GO
