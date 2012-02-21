
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 21, 2010
-- Description:	table of hvcasefk that fit the filter passed
-- =============================================
CREATE function [dbo].[udfCaseFilters]
(-- Add the parameters for the function here
    @positiveClause varchar(200)    = null,
    @negativeClause varchar(200)    = null,
    @programfks     varchar(100)
)
returns
@tblCases table
(
	HVCaseFK int
)
as
begin
	declare @HVCasefk int
	---- set up the variables for the filter values
	declare @pospair1 as varchar(100),
            @pospair2 as varchar(100),
            @pospair3 as varchar(100),
            @negpair1 as varchar(100),
            @negpair2 as varchar(100),
            @negpair3 as varchar(100),
            @rownum   as int,
            @listitem as varchar(100)
	--positive clause
	declare pos_cursor cursor for
	select *
		  ,rownum = row_number() over (order by listItem)
		from splitstring(@positiveClause,',')

	open pos_cursor;
	fetch next from pos_cursor into @listitem,@rownum

	if @rownum = 1
		set @pospair1 = @listitem;

	while @@Fetch_status = 0
	begin

		if @rownum = 2
			set @pospair2 = @listitem;

		if @rownum = 3
			set @pospair3 = @listitem;

		fetch next from pos_cursor into @listitem,@rownum
	end
	close pos_cursor
	deallocate pos_cursor
	---negative cursor
	declare neg_cursor cursor for
	select *
		  ,rownum = row_number() over (order by listItem)
		from splitstring(@negativeClause,',')

	open neg_cursor;
	fetch next from neg_cursor into @listitem,@rownum

	if @rownum = 1
		set @negpair1 = @listitem;

	while @@Fetch_status = 0
	begin

		if @rownum = 2
			set @negpair2 = @listitem;

		if @rownum = 3
			set @negpair3 = @listitem;

		fetch next from neg_cursor into @listitem,@rownum
	end
	close neg_cursor
	deallocate neg_cursor
	---
	insert into @tblCases
		select distinct HVCasePK
			from
				(select HVCasePK
					   ,CaseProgram.ProgramFK
					   ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))
						+isnull(UPPER(FilterValue),'') as answers
					 from CaseProgram
						 inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
						 inner join listCaseFilterName cfn on cfn.ProgramFK = CaseProgram.ProgramFK
						 left join CaseFilter on HVCasePK = CaseFilter.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
					 where @programFKS like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
			where (answers = @pospair1
				 or answers = @pospair2
				 or answers = @pospair3)
				 and
				 (answers <> @negpair1
				 or answers <> @negpair2
				 or answers <> @negpair3)

	-- return information to caller- second part of last

	return;
end;
GO
