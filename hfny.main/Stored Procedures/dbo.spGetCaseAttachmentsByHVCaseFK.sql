SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/06/18
-- Description:	Get all case-related attachment rows from the database
-- =============================================
CREATE PROCEDURE [dbo].[spGetCaseAttachmentsByHVCaseFK]
	-- Add the parameters for the stored procedure here
	@HVCaseFK INT,
	@ProgramFK INT
AS
BEGIN
	SELECT	AttachmentPK,
			Attachment,
			AttachmentCreateDate,
			AttachmentCreator,
			AttachmentDescription,
			AttachmentFilePath,
			AttachmentTitle,
			FormDate,
			FormFK,
			FormType,
			HVCaseFK,
			ProgramFK
	FROM	dbo.Attachment a
	WHERE a.HVCaseFK = @HVCaseFK
		AND a.ProgramFK = @ProgramFK;
END;
GO
