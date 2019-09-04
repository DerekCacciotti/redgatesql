SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAttachmentCategory](@AttachmentFK int=NULL,
@AttachmentCategoryFK int=NULL)
AS
INSERT INTO AttachmentCategory(
AttachmentFK,
AttachmentCategoryFK
)
VALUES(
@AttachmentFK,
@AttachmentCategoryFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
