
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Nov. 12, 2011
-- Modified: 
-- Description:	CaseFilter (Xtra-flds) by ProgramFK
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllCaseFilterByHVCaseFK]  (@HVCaseFK int)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	select listCaseFilterNamePK
          ,FieldTitle
          ,FilterType
          ,Hint
          ,FilterValue
          ,CaseFilterPK
          ,HVCaseFK
          ,cfn.ProgramFK
	from listCaseFilterName cfn
	LEFT OUTER JOIN 
	(Select CaseFilterNameFK,FilterValue,CaseFilterPK,HVCaseFK,ProgramFK from CaseFilter 
	 Where HVCaseFK=@HVCaseFK) a
	 ON cfn.ProgramFK=a.ProgramFK and 
		listCaseFilterNamePK= a.CaseFilterNameFK
	ORDER BY FieldTitle

END











GO
