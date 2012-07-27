
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: July 18, 2012
-- Description:	Return workers who are working at a specified date from a specified program for a specified type of worker
--				null date is set to tomorrow at midnight so difference in computer clocks doesn't effect enddate.
--				This is a complete re-write of the old stored proc
-- Test: exec spGetAllWorkersbyProgram 30,null,'FSW,FAW,FAdv,SUP,PM'
-- =============================================
CREATE procedure [dbo].[spGetAllWorkersbyProgram]
    @ProgramFK  int           = null,
    @EventDate  datetime      = null,
    @WorkerType varchar(20)   = null

as

set nocount on

set @EventDate = isnull(@EventDate, current_timestamp);
set @WorkerType = case when dbo.IsNullOrEmpty(@WorkerType)=1 or upper(@WorkerType)='ALL' then 'FSW,FAW,PM,FAdv,SUP,' else @WorkerType end;

with cteAllWorkers as 
(
	select LastName, FirstName, WorkerPK, 'FAW' as workertype
	from worker
	inner join workerprogram
	on workerpk=workerfk
	where programfk=@ProgramFK
			and faw = 1
			and @EventDate between FAWStartDate AND isnull(FAWEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	union all
	select LastName, FirstName, WorkerPK, 'FSW' as workertype
	from worker
	inner join workerprogram
	on workerpk=workerfk
	where programfk=@ProgramFK 
			and fsw = 1
			and @EventDate between FSWStartDate AND isnull(FSWEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	union all
	select LastName, FirstName, WorkerPK, 'FAdv' as workertype
	from worker
	inner join workerprogram
	on workerpk=workerfk
	where programfk=@ProgramFK 
			and FatherAdvocate = 1
			-- and @EventDate between FatherAdvocateStartDate AND isnull(FatherAdvocateEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	union all
	select LastName, FirstName, WorkerPK, 'SUP' as workertype
	from worker
	inner join workerprogram
	on workerpk=workerfk
	where programfk=@ProgramFK 
			and supervisor = 1
			and @EventDate between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	union all
	select LastName, FirstName, WorkerPK, 'PM' as workertype
	from worker
	inner join workerprogram
	on workerpk=workerfk
	where programfk=@ProgramFK 
			and programmanager = 1
			and @EventDate between ProgramManagerStartDate AND isnull(ProgramManagerEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	)

select distinct rtrim(LastName) + ', ' + rtrim(FirstName) as WorkerName
				, LastName
				, FirstName
				, WorkerPK 
from cteAllWorkers
inner join dbo.SplitString(@WorkerType,',') on workertype = listitem
-- where workertype in (select listitem from dbo.SplitString(@WorkerType,','))
order by LastName, FirstName
GO
