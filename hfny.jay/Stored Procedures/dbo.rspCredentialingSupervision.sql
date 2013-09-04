SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: August 8, 2013
-- Description:	Credentialing report for Supervisions

-- rspCredentialingSupervision 1, '06/01/2013', '08/31/2013'
-- rspCredentialingSupervision 1, '06/01/2013', '08/31/2013',null,152,null
-- rspCredentialingSupervision 1, '06/01/2013', '08/31/2013',null,null,5

-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervision]
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

	
	--if @programfk is null
	--begin
	--	select @programfk =
	--		   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
	--						  from HVProgram
	--						  for xml path ('')),2,8000)
	--end

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
		  
		   FROM #tblFAWFSWWorkers w 
		   inner join workerprogram wp on wp.workerfk = w.workerpk
	INNER JOIN dbo.fnGetWorkerEventDatesALL(@ProgramFK, NULL, NULL) fn ON fn.workerpk = w.workerpk
	where w.workerpk not in (SELECT workerpk FROM #tblSUPPMWorkers)
	and
	fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa
	
	and  w.workerpk = isnull(@workerfk,w.workerpk)
    and wp.supervisorfk = isnull(@supervisorfk,wp.supervisorfk)
    --and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
    and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)	
	
	
	order by w.workername
	
	
	
	
	
	
	
	
	

	-- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'		
	-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'		
			
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
		dateadd(d,7,@sDate) EndDate
		
	  union all
	  
	  select 
	  WeekNumber + 1 as WeekNumber,
	   dateadd(d,7, StartDate) as StartDate,
	   dateadd(d,7, EndDate) as EndDate
	   
	   
	  from cteGenerateWeeksGiven2Dates
	  
	  
	  where dateadd(d,7, StartDate)<=  @eDate	  
	  
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

	

--	 rspCredentialingSupervision 1, '04/01/2013', '04/30/2013'		
		
--		SELECT * FROM #tblWorkers
--		where WorkerPK = 152  -- worker: Burdick, Catherine

		-- Step#: 3
		-- Now let us develop the report. We will use the above 2 temp tables now
		
		;
		
		with cteWorkersWithSupervisions
		as
		(
		SELECT *
			-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
			, datediff(d, StartDate,EndDate) as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			  
			   FROM #tblWeekPeriods wp 		
		left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		)

--select datediff(d, '01/06/2013', '01/13/2013')		
--select datediff(d, '01/20/2013', '01/27/2013')	
		
	--SELECT * FROM cteWorkersWithSupervisions
	--order by workername,weeknumber, SupervisionDate
		
-- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'					
		
		
		,cteWorkersWithSupervisionsII
		as
		(
		SELECT *			
			,datediff(d, StartDate,EndDate) as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  
			
			  
			   FROM #tblWeekPeriods wp 		
		left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join Supervision s on s.WorkerFK = w.WorkerPK and SupervisionDate between StartDate and EndDate
		)
				
		
	,cteSupervisors	as 
	(
		select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as SupervisorName
				, TerminationDate
				, WorkerPK
				, 'SUP' as workertype
		from Worker w
		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK 
				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))

	)
	
	,cteSupervisionReasonsNotTookPlace	as 
	(
		SELECT SupervisionPK
		
			,case
				when ParticipantEmergency = 1 then 'Participant emergency'				
				when ShortWeek = 1 then 'Short week-home visits take priority'
				when StaffCourt = 1 then 'Staff in court'
				when StaffFamilyEmergency = 1 then 'Staff has family emergency'
				when StaffForgot = 1 then 'Staff forgot'
				when StaffIll = 1 then 'Staff ill'
				when StaffTraining = 1 then 'Staff in training'
				when StaffVacation = 1 then 'Staff on vacation'
				when StaffOutAllWeek = 1 then 'Staff out all week'
				when SupervisorFamilyEmergency = 1 then 'Supervisor has family emergency'
				when SupervisorForgot = 1 then 'Supervisor forgot'
				when SupervisorHoliday = 1 then 'Supervisor off for holiday'
				when SupervisorIll = 1 then 'Supervisor ill'
				when SupervisorTraining = 1 then 'Supervisor in training'
				when SupervisorVacation = 1 then 'Supervisor on vacation'
				when ReasonOther  = 1 then ReasonOtherSpecify
				when Weather = 1 then 'Inclement weather'				
				else
				''
				end as ReasonNOSupervision		
		
			  --,ParticipantEmergency			  
			  --,ShortWeek
			  --,StaffCourt
			  --,StaffFamilyEmergency
			  --,StaffForgot
			  --,StaffIll
			  --,StaffTraining
			  --,StaffVacation
			  
			  --,StaffOutAllWeek
			  

			  --,SupervisorFamilyEmergency
			 
			  --,SupervisorForgot
			  --,SupervisorHoliday
			  --,SupervisorIll

			  --,SupervisorTraining
			  --,SupervisorVacation
			  --,ReasonOther
			  --,ReasonOtherSpecify
			  --,Weather
			  --,TakePlace			  
			  --,WorkerFK		
			  
			  
			   FROM #tblWorkers w 
				left join Supervision s on s.WorkerFK = w.WorkerPK
				where TakePlace = 0

	)	
	
	
--	--SELECT * FROM cteSupervisionReasonsNotTookPlace
	
---- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'		

	,cteSupervisionDurations
	as
	(
		SELECT 
			WorkerPK 
			,isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) as Duration
			,WeekNumber 
		
		FROM cteWorkersWithSupervisionsII
	)	
	
	,cteSupervisionDurationsGroupedByWeek
	as
	(
		SELECT 
			WorkerPK 
			,sum(Duration) as WeeklyDuration
			,WeekNumber 
		
		FROM cteSupervisionDurations sd		
		group by WorkerPK, WeekNumber
	)				
		
	,cteSupervisionEvents
	as
	(	
		
		SELECT 
			 wws.workerpk
			, WorkerName
			,startdate
			,enddate
			,case when TakePlace = 1 then 'Y' else 'N' end as SupervisionTookPlace
			,SupervisionDate
			,SupervisionHours,SupervisionMinutes
			,isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) as Duration
			,sdg.WeeklyDuration
			,TakePlace
			,case
			
				when (TakePlace = 0) and (StaffOutAllWeek = 1)  then 'E'  -- Form found in period and reason is “Staff out all week” Note: E = Excused
				when (TakePlace = 0) and (StaffOutAllWeek <> 1) and (sdg.WeeklyDuration = 0)  then 'N'  -- Form found in period and reason is not “Staff out all week”				

				when (sdg.WeeklyDuration >= 90) then 'Y' -- Form found in period and duration is 1:30 or greater 
				when (sdg.WeeklyDuration < 90) and (TakePlace = 1) then 'N'  -- Form found in period and duration less than 1:30
				
				when (WorkerFK is null and wws.SupervisionPK is null) then 'N'  -- Form not found in period
				end
				as MeetsStandard

			,case
				when (TakePlace = 0) and (StaffOutAllWeek = 1)  then 'Staff out all week'  -- Form found in period and reason is “Staff out all week” Note: E = Excused
				when (TakePlace = 0) and (StaffOutAllWeek <> 1)  then reason.ReasonNOSupervision  -- Form found in period and reason is not “Staff out all week”
				when (isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) >= 90) and (TakePlace = 1) then '' -- Form found in period and duration is 1:30 or greater 
				when (isnull(SupervisionHours * 60,0) + isnull(SupervisionMinutes,0) < 90) and (TakePlace = 1) then ''  -- Form found in period and duration less than 1:30
				when (WorkerFK is null and wws.SupervisionPK is null) then 'Unknown'  -- Form not found in period
				end
				as ReasonSupeVisionNotHeld
			
			--,reason.ReasonNOSupervision
			
			,wws.SupervisionPK
			,SupervisorFK
			,sup.SupervisorName
			,wws.WorkerFK 
			,wws.WeekNumber
			,wws.DaysInTheCurrentWeek
			,wws.FirstEvent
		
		 FROM cteWorkersWithSupervisions wws
		 left join cteSupervisors sup on wws.SupervisorFK = sup.WorkerPK  -- to fetch in supervisor's name
		 left join  cteSupervisionReasonsNotTookPlace reason on reason.SupervisionPK = wws.SupervisionPK -- to fetch in reasons for supervision not took place
		 left join cteSupervisionDurationsGroupedByWeek sdg on sdg.WorkerPK = wws.WorkerPK and sdg.WeekNumber = wws.WeekNumber
		)
		
	
	--SELECT * FROM cteSupervisionEvents
	--order by workername,weeknumber, SupervisionDate
	
--	rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'			

	, cteReportDetails
		as
		(		
			SELECT WorkerName
				  ,startdate
				  ,enddate
				  --,SupervisionTookPlace
				  ,SupervisionDate
				  ,SupervisionHours
				  ,SupervisionMinutes
				  ,Duration
				  --,WeeklyDuration
				  ,TakePlace
				  ,case when Duration = 0 and MeetsStandard = 'Y' and ReasonSupeVisionNotHeld is not null then ''
						when DaysInTheCurrentWeek is not null and DaysInTheCurrentWeek < 7 then 'Less Than a Week'		  
				   else MeetsStandard end as MeetsStandard
				   
				  --,MeetsStandard		  
				  --,SupervisionPK
				  --,SupervisorFK
				  ,SupervisorName
				  ,ReasonSupeVisionNotHeld
				  --,WorkerFK
				  ,DaysInTheCurrentWeek,weeknumber
				  ,firstevent
				  ,workerpk
			 FROM cteSupervisionEvents	
		 )
	

,cteReportDetailsModified
as
(

			SELECT WorkerName
				  ,startdate
				  ,enddate
				  ,SupervisionDate
				  ,SupervisionHours
				  ,SupervisionMinutes
				  ,Duration
				  ,TakePlace
				  ,MeetsStandard
				  --ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
				  , case when (firstevent between @sdate and @edate) then				  
				  
						case when (firstevent <= enddate) then MeetsStandard
							else ''
							end
						
						
						else
						
							MeetsStandard
						end	
						
						as MeetsStandard1
						
				  ,SupervisorName
				  ,ReasonSupeVisionNotHeld
				  ,DaysInTheCurrentWeek
				  ,weeknumber
				  ,firstevent
				  ,workerpk
			 FROM cteReportDetails	
)			 

-- need a copy of cteReportDetailsModified later usuage
,cteReport1
as
(

			SELECT WorkerName
				  ,startdate
				  ,enddate
				  ,SupervisionDate
				  ,SupervisionHours
				  ,SupervisionMinutes
				  ,Duration
				  ,TakePlace
				  ,MeetsStandard
				  --ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
				  , case when (firstevent between @sdate and @edate) then
				  
				  -- Need JH Help
						case when (firstevent <= enddate) then MeetsStandard
							else ''
							end
						
						
						else
						
							MeetsStandard
						end	
						
						as MeetsStandard1
						
				  ,SupervisorName
				  ,ReasonSupeVisionNotHeld
				  ,DaysInTheCurrentWeek
				  ,weeknumber
				  ,firstevent
				  ,workerpk
				  
			 FROM cteReportDetails	
)			 

--SELECT * FROM ctecteReportDetailsModified
--			order by workername, weeknumber, SupervisionDate

-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'	


	
	,cteUniqueMeetsStandard
	as
	(
	select distinct WorkerName		  
		  ,MeetsStandard1		  
		  ,weeknumber
		  ,DaysInTheCurrentWeek	 
	
	FROM cteReportDetailsModified
	)
	
 ,cteScoreByWorker
 as
 (		
	
SELECT WorkerName
		,sum(case when DaysInTheCurrentWeek = 7 then 1 else 0 end) as NumOfExpectedSessions
		,sum(case when MeetsStandard1 = 'E' then 1 else 0 end) as NumOfAllowedExecuses
		,sum(case when MeetsStandard1 = 'Y' then 1 else 0 end) as NumOfMeetStandardYes
	  --,weeknumber
	  --,DaysInTheCurrentWeek
 FROM cteUniqueMeetsStandard
 group by WorkerName
 )
 
		 
		SELECT cr.WorkerName	
		  ,convert(varchar(12),startdate,101) as startdate
		  --,enddate
		  ,convert(varchar(12),SupervisionDate,101) as SupervisionDate
		  --,SupervisionHours
		  --,SupervisionMinutes
		  ,CASE -- convert into to string
				WHEN SupervisionHours > 0 AND SupervisionMinutes > 0 THEN CONVERT(varchar(10),SupervisionHours) + ':' + CONVERT(varchar(10),SupervisionMinutes)
				WHEN SupervisionHours > 0 AND (SupervisionMinutes = 0 OR SupervisionMinutes IS NULL) THEN CONVERT(varchar(10),SupervisionHours) + ':00'
				WHEN (SupervisionHours = 0 OR SupervisionHours  IS NULL) AND SupervisionMinutes > 0 THEN '00:' + CONVERT(varchar(10),SupervisionMinutes)
				--WHEN (SupervisionHours = 0 OR SupervisionHours  IS NULL) AND (SupervisionMinutes = 0 OR SupervisionMinutes IS NULL) THEN '00:00'
				ELSE ' ' END

			as Duration  
		  ,case when TakePlace = 1 then 'Y' else 'N' end as TakePlace		  
		  ,MeetsStandard1 as MeetsStandard
		  ,SupervisorName
		  ,ReasonSupeVisionNotHeld
		  ,firstevent
		  ,cr.workerpk
		  ,case when FAWInitialStart is not null then 'FAW'
			    when FSWInitialStart is not null then 'FSW'
			    else
			    ''
			    end as workerRole
		  
		  ,DaysInTheCurrentWeek
		  ,NumOfExpectedSessions
		  ,NumOfAllowedExecuses
		  ,NumOfExpectedSessions - NumOfAllowedExecuses as NumOfAdjExptdSupervisions
		  ,NumOfMeetStandardYes
		  ,CONVERT(VARCHAR,NumOfMeetStandardYes) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(NumOfMeetStandardYes AS FLOAT) * 100/ NULLIF((NumOfExpectedSessions - NumOfAllowedExecuses),0), 0), 0))  + '%)'	AS PerctOfAccptbleSupervisions
		  ,
		  case 
			  when CONVERT(VARCHAR, round(COALESCE(cast(NumOfMeetStandardYes AS FLOAT) * 100/ NULLIF((NumOfExpectedSessions - NumOfAllowedExecuses),0), 0), 0)) >= 90 then 3
			  when CONVERT(VARCHAR, round(COALESCE(cast(NumOfMeetStandardYes AS FLOAT) * 100/ NULLIF((NumOfExpectedSessions - NumOfAllowedExecuses),0), 0), 0)) between 75 and 90 then 2
			  when CONVERT(VARCHAR, round(COALESCE(cast(NumOfMeetStandardYes AS FLOAT) * 100/ NULLIF((NumOfExpectedSessions - NumOfAllowedExecuses),0), 0), 0)) < 75 then 1
		  end as HFARating
		  
		  
	FROM cteReport1 cr
	left join cteScoreByWorker sw on sw.WorkerName = cr.WorkerName 
	left join Worker w on w.WorkerPK = cr.WorkerPK
	--where MeetsStandard <> 'N/A'
	order by cr.workername,cr.weeknumber, cr.SupervisionDate
	
				
	
-- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'			
-- rspCredentialingSupervision 1, '04/01/2013', '04/30/2013'		
-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'		

	drop table #tblFAWFSWWorkers
	drop table #tblSUPPMWorkers
	drop table #tblWorkers
	drop table #tblWeekPeriods
GO
