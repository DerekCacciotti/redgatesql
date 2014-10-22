SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAttachment](@AttachmentPK int=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@Attachment varbinary(max)=NULL)
AS
UPDATE Attachment
SET 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
Attachment = @Attachment
WHERE AttachmentPK = @AttachmentPK
GO
