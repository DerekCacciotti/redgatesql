SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 16, 2016>
-- Description:	<Gets all Program documents from the Attachment table for a specific program>
-- =============================================

CREATE procedure [dbo].[spGetAllProgramDocuments]
	@programFK INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AttachmentPK
	, replace(AttachmentTitle, '.pdf', '') as AttachmentTitle
	, AttachmentDescription
	, convert(varchar(10), FormDate, 126) as FormDate
	, convert(varchar(10), AttachmentCreateDate, 126) as AttachmentCreateDate
	, AttachmentCreator
	FROM Attachment
	WHERE FormType = 'AD' AND ProgramFK = @programFK
	ORDER BY AttachmentCreateDate DESC;
END
GO
