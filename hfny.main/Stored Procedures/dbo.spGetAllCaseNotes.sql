SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 14, 2015>
-- Description:	<Gets all items for the passed Case fk from the CaseNote table>
-- =============================================

CREATE procedure [dbo].[spGetAllCaseNotes]
(
    @ProgramFK int = null,
    @HVCaseFK int  = null
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

    -- Insert statements for procedure here
	select CaseNotePK
		 , CaseNote
		 , CaseNoteCreateDate
		 , CaseNoteCreator
		 , CaseNoteEditDate
		 , CaseNoteEditor
		 , HVCaseFK
		 , ProgramFK
	from CaseNote
	where ProgramFK = @ProgramFK
			and HVCaseFK = @HVCaseFK
	
END
GO
