
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
    @ProgramFK as int = null
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select listCaseFilterNamePK
		  ,FieldTitle
		  ,FilterType
		  ,case
			   when FilterType = 1 then 'Yes/No option'
			   when FilterType = 2 then 'Defined options'
			   when FilterType = 3 then 'Free form'
		   end as FilterTypeText
		  ,Hint
		  ,ProgramFK
		  ,OptionsList = SUBSTRING ((SELECT ',' + FilterOption from listCaseFilterNameOption cfno WHERE cfno.CaseFilterNameFK = cfn.listCaseFilterNamePK FOR XML PATH ( '' )), 2, 1000)
		from listCaseFilterName cfn
		--inner join (select substring((select ','+LTRIM(RTRIM(STR(FilterOption))) as OptionList, CaseFilterNameFK
		--					  from listCaseFilterNameOption cfno
		--					  for xml path ('')),2,8000)) opt on opt.CaseFilterNameFK = cfn.listCaseFilterNamePK
		where ProgramFK = isnull(@ProgramFK,ProgramFK)
		order by FieldTitle
end
GO
