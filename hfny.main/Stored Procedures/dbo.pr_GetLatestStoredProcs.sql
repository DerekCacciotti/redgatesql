SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[pr_GetLatestStoredProcs] (@CutoffDays int)
as
begin
	if @CutoffDays is null 
	begin
       set @CutoffDays = -5
    end
	else if @CutoffDays > 0
	begin
		set @CutoffDays = @CutoffDays * -1
	end

	declare @CutoffDate date = DATEADD(dd, @CutoffDays, CURRENT_TIMESTAMP)
	
	select OBJECT_SCHEMA_NAME([object_id])
		  ,name
		  ,create_date
		  ,modify_date
		from sys.procedures
		where modify_date >= @CutoffDate
		order by modify_date desc;


end
GO
