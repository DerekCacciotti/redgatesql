SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 16, 2016>
-- Description:	<Gets all CA documents from the Attachment table>
-- =============================================

CREATE procedure [dbo].[spGetAllCADocuments]
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		select	AttachmentPK
			  , AttachmentTitle
			  , AttachmentDescription
			  , convert(varchar(10), FormDate, 126) as FormDate
			  , convert(varchar(10), AttachmentCreateDate, 126) as AttachmentCreateDate
			  , AttachmentCreator
		from	Attachment a 
		where	FormType = 'CA'
		order by AttachmentCreateDate desc;
	end;
GO
