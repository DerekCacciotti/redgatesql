SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 16, 2016>
-- Description:	<Gets all Paper Forms from the Attachment table>
-- =============================================

CREATE procedure [dbo].[spGetAllPaperForms]
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		SELECT DISTINCT	AttachmentPK
			  , AttachmentTitle
			  , AttachmentDescription
			  , convert(varchar(10), FormDate, 126) as FormDate
			  , convert(varchar(10), AttachmentCreateDate, 126) as AttachmentCreateDate
			  , AttachmentCreator,
			  ac.AttachmentCategoryPK,
			  ca.AttachmentCategory
		from	Attachment a 
		LEFT OUTER JOIN dbo.AttachmentCategory ac ON ac.AttachmentFK = a.AttachmentPK
		left JOIN dbo.codeAttachmentCategory ca ON ca.codeAttachmentCategoryPK = ac.AttachmentCategoryFK
		where	FormType = 'PF'
		order by AttachmentCreateDate desc;
	end;
GO
