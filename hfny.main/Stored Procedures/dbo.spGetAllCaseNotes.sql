
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 14, 2015>
-- Description:	<Gets all items for the passed Case FK from the CaseNote table>
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
		 , rtrim(left(CaseNote, 55)) + '...' as CaseNoteExtract
		 , CaseNoteCreateDate
		 , CaseNoteCreator
		 , CaseNoteEditDate
		 , CaseNoteEditor
		 , cn.HVCaseFK
		 , cn.ProgramFK
		 , cp.PC1ID
		 , 'CaseNote.aspx?pc1id=' + PC1ID + '&notepk=' + rtrim(convert(varchar(10), CaseNotePK)) as EditLink
	from CaseNote cn
	inner join CaseProgram cp on cp.HVCaseFK = cn.HVCaseFK
	where cn.ProgramFK = @ProgramFK
			and cn.HVCaseFK = @HVCaseFK
	
END
GO
