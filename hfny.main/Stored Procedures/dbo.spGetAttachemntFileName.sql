SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAttachemntFileName] @AttachemntPK INT AS

SELECT AttachmentTitle FROM dbo.Attachment WHERE AttachmentPK = @AttachemntPK
GO
