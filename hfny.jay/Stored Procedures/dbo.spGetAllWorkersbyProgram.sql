SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dorothy Baum
-- Create date: July 20, 2009
-- Description:	Return workers, who are working at a specified date from a specified program for a specified type of worker
--null date is set to tomorrow at midnight so difference in computer clocks doesn't effect enddate.
-- =============================================

CREATE PROCEDURE [dbo].[spGetAllWorkersbyProgram]
@ProgramFK int = NULL,
@EventDate datetime = NULL,
@WorkerType varchar(3)= NULL


AS
BEGIN
SET NOCOUNT ON;

DECLARE @SelectStatement nVarchar(250);
	

create table #workerinProgram(workerfk int)


set @SelectStatement = N'insert into #WorkerinProgram(WorkerFK) 
Select WorkerFK 
from WorkerProgram 
where ProgramFK=@lProgramFK and @lEventDate BETWEEN '+ @WorkerType+'StartDate AND isnull('+@WorkerType+'EndDate,dateadd(dd,1,datediff(dd,0,getdate())))'

SET NOCOUNT ON;

EXEC  sp_Executesql @SelectStatement, 
					N'@lProgramFk int, @lEventDate datetime',
					@lProgramFK=@ProgramFK,@lEventDate=@EventDate;

select * from worker 
where workerpk in
(select workerfk from #WorkerinProgram)

drop table #WorkerinProgram

END



GO
