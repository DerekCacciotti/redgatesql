SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 21, 2010
-- Description:	table of hvcasefk that fit the filter passed
-- =============================================
create FUNCTION [dbo].[udfCaseFilters]
(
	-- Add the parameters for the function here
	@positiveClause varchar(200) = null, 
	@negativeClause varchar(200) = null,
	@programfks varchar(100)
)
RETURNS 
@tblCases TABLE 
(
	HVCaseFK int
)
AS
BEGIN
	declare @HVCasefk int
---- set up the variables for the filter values
declare @pospair1 as varchar(100), @pospair2 as varchar(100), @pospair3 as varchar(100), 
		@negpair1 as varchar(100), @negpair2 as varchar(100), @negpair3 as varchar(100),
		@rownum as int, @listitem as varchar(100)
--positive clause
	DECLARE pos_cursor CURSOR FOR
		select * , rownum=row_number() over (order by listItem) from splitstring(@positiveClause,',')

	open pos_cursor;
	Fetch Next from pos_cursor into @listitem, @rownum

	if @rownum=1
		set @pospair1=@listitem;

	While @@Fetch_status = 0
	Begin
		
	if @rownum=2
		set @pospair2=@listitem;

	if @rownum=3
		set @pospair3=@listitem;

	Fetch Next from pos_cursor INTO @listitem, @rownum	
	End
close pos_cursor
deallocate pos_cursor
---negative cursor
DECLARE neg_cursor CURSOR FOR
	select * , rownum=row_number() over (order by listItem) from splitstring(@negativeClause,',')

	open neg_cursor;
	Fetch Next from neg_cursor into @listitem, @rownum

	if @rownum=1
		set @negpair1=@listitem;

	While @@Fetch_status = 0
	Begin

	if @rownum=2
		set @negpair2=@listitem;

	if @rownum=3
		set @negpair3=@listitem;

	Fetch Next from neg_cursor INTO @listitem, @rownum	
	End
close neg_cursor
deallocate neg_cursor
---
	insert into @tblCases SELECT DISTINCT HVCasePK FROM 
(SELECT HVCasePK,CaseProgram.ProgramFK,CAST(ISNULL(CaseCriteriaFK,listCaseCriteriaPK) as varchar(10)) + ISNULL(UPPER(filtervalue),'') as answers
 from CaseProgram
	inner join HVCase
	on CaseProgram.HVCaseFK=HVCasePK
	inner join listCaseCriteria lc
	on lc.ProgramFK=CaseProgram.ProgramFK
	left join CaseFilter
	on HVCasePK=CaseFilter.HVCaseFK and CaseCriteriaFK=lc.listCaseCriteriapk
where @programFKS  Like('%,'+ Cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
where (answers =@pospair1 or answers=@pospair2 or answers=@pospair3) and
	  (answers <> @negpair1 or answers<> @negpair2 or answers <> @negpair3)

-- return information to caller- second part of last
	
    RETURN;
END;
GO
