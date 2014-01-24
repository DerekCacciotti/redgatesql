SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: January 9th, 2014
-- Description:	Credentialing report for Supervisions Activities Summary
-- Supervision sessions that took place with a reason
-- to show list of the other activities

-- rspCredentialingSupervisionActivitiesSummary_PartI 1, '06/01/2013', '08/31/2013',null,152,null,2

-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervisionActivitiesSummary_PartI]
	@ProgramFK  int           = null,
    @sDate  datetime      =   null,
    @eDate  datetime      =  null,
    @supervisorfk int             = null,
    @workerfk     int             = null,
	@sitefk		 int			 = null
    
as


set nocount on

IF 1=0 BEGIN
    SET FMTONLY OFF
END


	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end	
	
	
	--Step#: 1
	-- Get list of all FAW and FSW that belong to the given program
	create table #tblFAWFSWWorkers(
			WorkerName varchar(100)
			,LastName		varchar(50)
			,FirstName		varchar(50)
			,TerminationDate datetime
			,WorkerPK int
			,SortOrder int
		
		)
		
	insert into #tblFAWFSWWorkers
			exec spGetAllWorkersbyProgram @ProgramFK,null,'FAW,FSW', null
	
	-- Exclude Worker who are SUP and PM from the above list of workers
		create table #tblSUPPMWorkers(
			WorkerName varchar(100)
			,LastName		varchar(50)
			,FirstName		varchar(50)
			,TerminationDate datetime
			,WorkerPK int
			,SortOrder int
		
		)
		
	insert into #tblSUPPMWorkers
			exec spGetAllWorkersbyProgram @ProgramFK,null,'SUP,PM', null		


		-- List of workers i.e. FAW, FSW minus 	SUP,PM
		-- List of workers who are not supervisor or program manager
		create table #tblWorkers(
			 WorkerName varchar(100)
			 , LastName		varchar(50)
			 , FirstName		varchar(50)
			 , TerminationDate datetime
			 , WorkerPK int
			 , SortOrder int
			
			 , WorkerFKFn int
			 , WrkrLName varchar(50)
			 , FAWInitialStart datetime
			 , SupervisorInitialStart datetime
			 , FSWInitialStart datetime
			 , TerminationDateFn datetime
			 , HireDate datetime
			 , SupervisorFirstEvent datetime
			 , FirstASQDate datetime
			 , FirstHomeVisitDate datetime
			 , FirstKempeDate datetime
			 , FirstEvent	datetime		
			 , SupervisorFK int
		
		)	
	
	insert into #tblWorkers	
	SELECT 
			 w.WorkerName
			 , w.LastName
			 , w.FirstName
			 , w.TerminationDate
			 , w.WorkerPK
			 , w.SortOrder
			 
			 , fn.WorkerPK
			 , WrkrLName
			 , FAWInitialStart
			 , SupervisorInitialStart
			 , FSWInitialStart
			 , fn.TerminationDate 
			 , fn.HireDate
			 , SupervisorFirstEvent
			 , FirstASQDate
			 , FirstHomeVisitDate
			 , FirstKempeDate
		     , fn.FirstEvent
		     , wp.SupervisorFK
		  
		   FROM #tblFAWFSWWorkers w 
		   inner join workerprogram wp on wp.workerfk = w.workerpk 
		   --AND wp.programfk = @ProgramFK
	INNER JOIN dbo.fnGetWorkerEventDatesALL(@ProgramFK, NULL, NULL) fn ON fn.workerpk = w.workerpk
	where 
	w.workerpk not in (SELECT workerpk FROM #tblSUPPMWorkers)
	and
	fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa
	
	and  w.workerpk = isnull(@workerfk,w.workerpk)
    and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
    --and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
    and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)	
	
	
	order by w.workername	
	
	
	--SELECT * FROM #tblWorkers
	
	-- rspCredentialingSupervisionActivitiesSummary_PartI 1, '06/01/2013', '08/31/2013',15,132,null

	
	
-- getting workername and supervisorname
-- we need them for the report	
declare @WorkerName varchar(100) = null 
declare @SupervisorName varchar(100) = null

set @WorkerName = (SELECT WorkerName FROM #tblWorkers where WorkerPK = @workerfk)
set @SupervisorName = (select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as SupervisorName 
		from Worker w
		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK 
				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
	and	WorkerPK = @supervisorfk)	
	
	
	create table #tblWorkerAndSupName(
			WorkerName varchar(100)
			,SupervisorName varchar(100)
		
		)
			
insert into #tblWorkerAndSupName	
		SELECT  @WorkerName, @SupervisorName	
	
	--SELECT workerpk FROM #tblSUPPMWorkers
	--SELECT * FROM #tblWorkers
	

	-- rspCredentialingSupervisionActivitiesSummary_PartI 1, '01/06/2013', '02/02/2013',15,152		
	-- rspCredentialingSupervisionActivitiesSummary_PartI 1, '03/01/2013', '03/31/2013'		
			
	--Step#: 2
	-- use a recursive CTE to generate the list of dates  ... Khalsa
	-- Given any startdate, find all week dates starting with that date and less then the end date
	-- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes

	
	create table #tblWeekPeriods(
			WeekNumber int			
			,StartDate datetime
			,EndDate datetime
		
		)	
	
	
	;with cteGenerateWeeksGiven2Dates as
	(
	  select 1 as WeekNumber,
	    @sDate StartDate, 
		dateadd(d,6,@sDate) EndDate
		
	  union all
	  
	  select 
	  WeekNumber + 1 as WeekNumber,
	   dateadd(d,7, StartDate) as StartDate,
	   dateadd(d,7, EndDate) as EndDate
	   
	   
	  from cteGenerateWeeksGiven2Dates
	  
	  
	  where dateadd(d,6, StartDate)<=  @eDate	  
	  
	)	
	
	
	
	insert into #tblWeekPeriods	
		select *
		from cteGenerateWeeksGiven2Dates
	

	
	------ We are only interested in each week's start date
	------ These are all the weeks between given two dates but at the end we added user given @eDate ... khalsa
		
	
	-- insert user's enddate at the end for the last period
		update #tblWeekPeriods
		set EndDate = @eDate
		where WeekNumber = (select top 1 WeekNumber from #tblWeekPeriods order by WeekNumber desc)


		--Note: Don't delete the following SELECT
		--SELECT 
		--	WeekNumber
		--	,StartDate
		--	,EndDate
		--	,datediff(day, StartDate,EndDate) as DaysInTheCurrentWeek			
		--FROM #tblWeekPeriods	

	

--	 rspCredentialingSupervisionActivitiesSummary_PartI 1, '04/01/2013', '04/30/2013'		
		
--		SELECT * FROM #tblWorkers
--		where WorkerPK = 152  -- worker: Burdick, Catherine


	-- Let us make sure that if a worker's firstevent date falls between @sdate and @edate then 
	-- adjust number of weeks for that worker. It will be less because he did not do anything till firstevent
	create table #tblWeekPeriodsAdjusted(
			WeekNumber int			
			,StartDate datetime
			,EndDate datetime
			,FirstEvent datetime
			,WorkerPK int	
		)	
	

	insert into #tblWeekPeriodsAdjusted	
		SELECT 
			WeekNumber
			,StartDate
			,EndDate		
			,FirstEvent
			,WorkerPK
		 FROM #tblWeekPeriods
		 inner join #tblWorkers w on FirstEvent < StartDate



----		-- Step#: 3
----		-- Now let us develop the report. We will use the above 2 temp tables now
		
		;

-- Supervision sessions that took place with a reason
	-- to show list of the other activities
	with cteSupervisionsThatTookPlaceActivitiesOther
	as
	(
				SELECT 

					ActivitiesOtherSpecify 				
				
			  
			   FROM #tblWeekPeriodsAdjusted wp 		
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join #tblWorkers w on w.workerpk = wp.workerpk  -- include only those weeks where worker performed supervisions. 
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		where SupervisionPK is not null
		and TakePlace = 1
		and ActivitiesOther = 1
	)
	


SELECT * FROM cteSupervisionsThatTookPlaceActivitiesOther

--ToDo: Also print out the other activities and reasons ... Khalsa

---- rspCredentialingSupervisionActivitiesSummary_PartI 1, '06/01/2013', '08/31/2013',15,null,null
---- rspCredentialingSupervisionActivitiesSummary_PartI 31, '06/01/2013', '08/31/2013'

---- rspCredentialingSupervisionActivitiesSummary_PartI 11, '10/01/2013', '12/31/2013',null,152,null,2


	drop table #tblFAWFSWWorkers
	drop table #tblSUPPMWorkers
	drop table #tblWorkers
	drop table #tblWeekPeriods
	drop table #tblWorkerAndSupName
GO
