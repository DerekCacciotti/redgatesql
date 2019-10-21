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

	
		SELECT DISTINCT	AttachmentPK
			  , AttachmentTitle
			  , AttachmentDescription
			  , convert(varchar(10), FormDate, 126) as FormDate
			  , convert(varchar(10), AttachmentCreateDate, 126) as AttachmentCreateDate
			  , AttachmentCreator,
			  ac.AttachmentCategoryPK,
			  ca.AttachmentCategory,
			  ca.codeAttachmentCategoryPK,
			  a.AttachmentFilePath
		from	Attachment a 
		LEFT OUTER JOIN dbo.AttachmentCategory ac ON ac.AttachmentFK = a.AttachmentPK
		left JOIN dbo.codeAttachmentCategory ca ON ca.codeAttachmentCategoryPK = ac.AttachmentCategoryFK
		where	FormType = 'AD'
		AND a.ProgramFK = @programFK
		order by AttachmentCreateDate desc;
	
END
GO
