SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <Apr 21, 2010>
-- Description:	<Get all the listCaseCriteria by ProgramFK>
-- =============================================
CREATE procedure [dbo].[spGetAllCaseFilterNamebyProgramFK]
	@ProgramFK as int = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM listCaseFilterName cfn
	WHERE ProgramFK=isnull(@ProgramFK,ProgramFK)
	ORDER BY FieldTitle
END
GO
