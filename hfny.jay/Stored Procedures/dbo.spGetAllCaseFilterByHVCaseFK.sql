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
create PROCEDURE [dbo].[spGetAllCaseFilterByHVCaseFK]  (@HVCaseFK int)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT FieldTitle, Hint, listCaseCriteriaPK as CaseCriteriaFK, FilterValue, CaseFilterPK, HVCaseFK, 
		   listCaseCriteria.ProgramFK 
	FROM listCaseCriteria 
	LEFT OUTER JOIN 
	(Select CaseCriteriaFK, FilterValue,CaseFilterPK,HVCaseFK,ProgramFK from CaseFilter 
	 Where HVCaseFK=@HVCaseFK) a
	 ON listCaseCriteria.ProgramFK= a.ProgramFK and 
		listCaseCriteria.listCaseCriteriaPK= a.CaseCriteriaFK
	ORDER BY FieldTitle
	
END











GO
