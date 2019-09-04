SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeAttachmentCategorybyPK]

(@codeAttachmentCategoryPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeAttachmentCategory
WHERE codeAttachmentCategoryPK = @codeAttachmentCategoryPK
GO
