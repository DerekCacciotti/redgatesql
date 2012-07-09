SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 21, 2010
-- Description:	table of hvcasefk that fit the filter passed
-- moved into HFNY 2012-07-07
-- =============================================
CREATE function [dbo].[udfCaseFilters2]
(-- Add the parameters for the function here
    @positiveClause varchar(max)    = null,
    @negativeClause varchar(max)    = null,
    @programfks     varchar(100)
)
returns
@tblCases table
(
	HVCaseFK int
)
as
begin

	-- positiveClause and negativeClause both not null
	if @positiveClause is not null and @negativeClause is not null
		insert into @tblCases
			select pos.hvcasepk
				from
					(select distinct HVCasePK
						 from
							 (select HVCasePK
									,CaseProgram.ProgramFK
									,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
										isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
								  from CaseProgram
									  inner join HVCase	on CaseProgram.HVCaseFK = HVCasePK
									  inner join listCaseFilterName cfn on cfn.ProgramFK = CaseProgram.ProgramFK
									  left join CaseFilter on HVCasePK = CaseFilter.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
								  where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
							 inner join splitstring(@positiveClause,',') d
									   on d.listitem = a.answers) pos
					inner join
							  (select distinct HVCasePK
								   from
									   (select HVCasePK
											  ,CaseProgram.ProgramFK
											  ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
												isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
											from CaseProgram
												inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
												inner join listCaseFilterName lfn on lfn.ProgramFK = CaseProgram.ProgramFK
												left join CaseFilter on HVCasePK = CaseFilter.HVCaseFK and CaseFilterNameFK = lfn.listCaseFilterNamePK
											where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
									   inner join splitstring(@negativeClause,',') d
												 on d.listitem = a.answers) neg
							  on neg.hvcasepk = pos.hvcasepk


	--negativeClause null and positiveClause not null
	if @positiveClause is not null and @negativeClause is null
		insert into @tblCases
			select distinct HVCasePK
				from
					(select HVCasePK
						   ,CaseProgram.ProgramFK
						   ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
							isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
						 from CaseProgram
							 inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
							 inner join listCaseFilterName cfn on cfn.ProgramFK = CaseProgram.ProgramFK
							 left join CaseFilter on HVCasePK = CaseFilter.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
						 where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
					inner join splitstring(@positiveClause,',') d
							  on d.listitem = a.answers
	--negativeClause not null and positiveClause is null
	if @positiveClause is null and @negativeClause is not null
		insert into @tblCases
			select pos.hvcasefk
				from
					(select distinct HVCasefK
						 from CaseProgram
						 where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) pos
					left outer join
								   (select distinct HVCasePK
										from
											(select HVCasePK
												   ,CaseProgram.ProgramFK
												   ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
												   isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
												 from CaseProgram
													 inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
													 inner join listCaseFilterName cfn on cfn.ProgramFK = CaseProgram.ProgramFK
													 left join CaseFilter on HVCasePK = CaseFilter.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
												 where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
											inner join splitstring(@negativeClause,',') d
													  on d.listitem = a.answers) neg
								   on neg.hvcasepk = pos.hvcasefk
				where neg.hvcasepk is null

	--both clauses null
	if @positiveClause is null and @negativeClause is null
		insert into @tblCases
			select hvcasefk
				from caseprogram
				where @programfks like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')

	return;
end;
GO
