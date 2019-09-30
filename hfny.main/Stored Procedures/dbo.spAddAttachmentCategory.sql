SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAttachmentCategory](@AttachmentFK int=NULL,
@AttachmentCategoryFK int=NULL,
@AttachmentCategoryCreator varchar(max)=NULL,
@AttachmentType varchar(10)=NULL)
AS
INSERT INTO AttachmentCategory(
AttachmentFK,
AttachmentCategoryFK,
AttachmentCategoryCreator,
AttachmentType
)
VALUES(
@AttachmentFK,
@AttachmentCategoryFK,
@AttachmentCategoryCreator,
@AttachmentType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
