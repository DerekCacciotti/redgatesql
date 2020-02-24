SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spIsAttachmentCategoryUsed] @AttachmentCategoryFK INT AS 

SELECT * FROM AttachmentCategory ac WHERE ac.AttachmentCategoryFK = @AttachmentCategoryFK
GO
