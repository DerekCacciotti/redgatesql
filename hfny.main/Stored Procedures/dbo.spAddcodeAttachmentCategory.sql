SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeAttachmentCategory](@AttachmentCategory varchar(50)=NULL)
AS
INSERT INTO codeAttachmentCategory(
AttachmentCategory
)
VALUES(
@AttachmentCategory
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
