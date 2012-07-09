
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
CREATE PROCEDURE [dbo].[spGetAllCaseFilterByHVCaseFK]  (@HVCaseFK int, @ProgramFK int)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	with cteCaseFilters
	as
	(select CaseFilterNameFK
			,CaseFilterNameChoice
			,CaseFilterNameOptionFK
			,CaseFilterValue
			,CaseFilterPK
			,HVCaseFK
			,ProgramFK 
		from CaseFilter 
	 Where HVCaseFK=@HVCaseFK) 
	select listCaseFilterNamePK
          ,FieldTitle
          ,FilterType
          ,Hint
		  ,CaseFilterNameChoice
		  ,CaseFilterNameOptionFK
		  ,CaseFilterValue
          ,CaseFilterPK
          ,HVCaseFK
          ,cfn.ProgramFK
	from listCaseFilterName cfn
	LEFT OUTER JOIN cteCaseFilters CF on cfn.ProgramFK=CF.ProgramFK and 
										 listCaseFilterNamePK= CF.CaseFilterNameFK
	where CF.ProgramFK = isnull(@ProgramFK,CF.ProgramFK)
	ORDER BY FieldTitle

END











GO
