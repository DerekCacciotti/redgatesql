SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2019-01-07
-- Description:	Deletes complete supervision session
-- =============================================
CREATE procedure [dbo].[spDeleteSupervisionSession]
	-- Add the parameters for the stored procedure here
	@SupervisionPK as int
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	begin try
		begin transaction ;
		delete from SupervisionHomeVisitCase where SupervisionFK = @SupervisionPK ;
		delete from SupervisionParentSurveyCase where SupervisionFK = @SupervisionPK ;
		delete from Supervision where SupervisionPK = @SupervisionPK ;
		commit transaction ;
	end try

	begin catch
		rollback transaction ;
	end catch ;
	
end ;
GO
