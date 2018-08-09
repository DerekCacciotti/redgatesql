SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetAttachmentPK] (@FormType varchar(2)
								, @FormFK int
								, @HVCaseFK int
								, @ProgramFK int
								, @AttachmentPK int output
								)

as
set noCount on ;
	begin

		begin transaction ;
		set transaction isolation level read uncommitted ;

		select	@AttachmentPK = AttachmentPK
		from	dbo.Attachment
		where	FormType = @FormType and FormFK = @FormFK ;
		--AND HVCaseFK = @HVCaseFK
		--AND FormReview.ProgramFK = @ProgramFK

		set @AttachmentPK = isnull(@AttachmentPK, 0) ;

		commit transaction ;

	end ;

return ;


GO
