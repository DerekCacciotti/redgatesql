
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Dorothy Baum
-- Create date: July 8, 2009
-- Modified: July 28, 2010: changed the null replacement value with tomorrow at midnight.
-- Description:	Return FSW workers, who are working at a specified date from a specified program
-- =============================================

CREATE PROCEDURE [dbo].[spGetAllFSWsbyProgram]
@ProgramFK int = NULL,
@EventDate datetime = NULL


AS
BEGIN
SET NOCOUNT ON;


create table #workerinProgram(workerfk int)

insert into #WorkerinProgram(WorkerFK)
Select workerfk 
from workerprogram 
where programfk=@ProgramFK and 
@EventDate BETWEEN FSWStartDate AND isnull(FSWEndDAte,dateadd(dd,270,datediff(dd,0,getdate())))

select * from worker 
where workerpk in
(select workerfk from #WorkerinProgram)
ORDER BY LastName 
drop table #WorkerinProgram
END






GO
