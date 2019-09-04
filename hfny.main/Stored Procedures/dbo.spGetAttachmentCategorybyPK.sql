SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetAttachmentCategorybyPK]

(@AttachmentCategoryPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM AttachmentCategory
WHERE AttachmentCategoryPK = @AttachmentCategoryPK
GO
