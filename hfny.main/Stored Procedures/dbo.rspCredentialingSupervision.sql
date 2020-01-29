SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure: rspCredentialingSupervision
-- Author:		Devinder Singh Khalsa
-- Create date: August 8, 2013
-- Description:	Credentialing report for Supervisions

-- rspCredentialingSupervision 1, '10/01/2013', '12/31/2013'
-- rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'
-- rspCredentialingSupervision 1, '06/01/2013', '08/31/2013',null,152,null
-- rspCredentialingSupervision 1, '06/01/2013', '08/31/2013',null,null,5


-- Fix: replace the start date of the report with worker's scheduled date of supervision  ... Khalsa 01/13/2013
-- rspCredentialingSupervision 11, '10/01/2013', '12/31/2013',null,673,null,2
-- rspCredentialingSupervision 11, '10/01/2013', '12/31/2013',null,673,null,null

-- max of 2 supervisions per week ... khalsa 1/29/2014

-- =============================================
CREATE PROC [dbo].[rspCredentialingSupervision] @ProgramFK int = null
										, @sDate datetime = null
										, @eDate datetime = null
										, @supervisorfk int = null
										, @workerfk int = null
										, @sitefk int = null
as

begin
	set noCount on ;

	if 1 = 0 begin
set fmtOnly off ;
	end ;


	--if @programfk is null
	--begin
	--	select @programfk =
	--		   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
	--						  from HVProgram
	--						  for xml path ('')),2,8000)
	--end

	set @sitefk = case when dbo.IsNullOrEmpty(@sitefk) = 1 then 0 else @sitefk end ;


	-- replace the start date of the report with worker's scheduled date of supervision	
	--Note: DayOfWeekSupScheduled and sDate are now required dates
	--set @sDate = dateadd(day,(isnull(@DayOfWeekSupScheduled,DATEPART(weekday,@sDate)) - DATEPART(weekday,@sDate)), @sDate)

	-- Get name of the day of week that user selected
	-- Need to show it back to the user in the report
	--DECLARE @DayofWeek VARCHAR(10)
	--SELECT @DayofWeek = CASE isnull(@DayOfWeekSupScheduled,DATEPART(weekday,@sDate))
	--WHEN 1 THEN 'Sunday'
	--WHEN 2 THEN 'Monday'
	--WHEN 3 THEN 'Tuesday'
	--WHEN 4 THEN 'Wednesday'
	--WHEN 5 THEN 'Thursday'
	--WHEN 6 THEN 'Friday'
	--WHEN 7 THEN 'Saturday'
	--END	

	--print @rtDayofWeek
	--select @sDate


	--Step#: 1
	-- Get list of all FAW and FSW that belong to the given program
	create table #tblStaff (
								WorkerName varchar(100)
							, LastName varchar(50)
							, FirstName varchar(50)
							, TerminationDate datetime
							, WorkerPK int
							, UserName varchar(50)
							, SortOrder int

								) ;

	insert into #tblStaff
	exec spGetAllWorkersbyProgram @ProgramFK, null, 'FAW,FSW,SUP,PM', null ;

	-- Exclude Worker who are SUP and PM from the above list of workers
	create table #tblSUPPMWorkers (
								WorkerName	varchar(100)
							, LastName varchar(50)
							, FirstName varchar(50)
							, TerminationDate datetime
							, WorkerPK int
							, UserName varchar(50)
							, SortOrder int

								) ;

	insert into #tblSUPPMWorkers
	exec spGetAllWorkersbyProgram @ProgramFK, null, 'Sup,PM', null ;


	-- CP 12-21-2017 we have no way of removing a Supervisor from this report based on the current system.  
	-- Lillian Caban is no longer a supervisor, but does not appear on this report since there is no END DATE for supervisors
	delete from #tblSUPPMWorkers
	where	LastName = 'Caban' and FirstName = 'Lillian' ;

	--CP 10-12-2018 per ticket #5212 These Supervisors are dual role so keep them in the report
	delete from #tblSUPPMWorkers
	where	LastName = 'Drenth' and FirstName = 'Patricia' ;
	delete from #tblSUPPMWorkers
	where	LastName = 'Wolosonowich' and FirstName = 'Ashley' ;
	delete from #tblSUPPMWorkers
	where	LastName = 'Reynolds' and FirstName = 'Ashley' ;
	delete from #tblSUPPMWorkers
	where	LastName = 'Lieberman' and FirstName = 'Bethany' ;
	delete from #tblSUPPMWorkers
	where	LastName = 'Southerton' and FirstName = 'Amber' ;

	
	-- List of workers i.e. FAW, FSW minus 	SUP,PM
	-- List of workers who are not supervisor or program manager
	create table #tblWorkers (
							WorkerName	varchar(100)
						, LastName varchar(50)
						, FirstName varchar(50)
						, TerminationDate datetime
						, WorkerPK int
						, SortOrder int
						, WorkerFKFn int
						, WrkrLName varchar(50)
						, FAWInitialStart datetime
						, SupervisorInitialStart datetime
						, FSWInitialStart datetime
						, ProgramManagerStartDate datetime
						, TerminationDateFn datetime
						, HireDate datetime
						, SupervisorFirstEvent datetime
						, FirstASQDate datetime
						, FirstHomeVisitDate datetime
						, FirstKempeDate datetime
						, FirstEvent datetime
						, SupervisionScheduledDay int
						, ScheduledDayName varchar(10)
						, sdate datetime
						, edate datetime
							) ;

	insert into #tblWorkers
	select		w.WorkerName
			, w.LastName
			, w.FirstName
			, w.TerminationDate
			, w.WorkerPK
			, w.SortOrder
			, fn.WorkerPK
			, fn.WrkrLName
			, fn.FAWInitialStart
			, fn.SupervisorInitialStart
			, fn.FSWInitialStart
			, fn.ProgramManagerStartDate
			, fn.TerminationDate
			, fn.HireDate
			, fn.SupervisorFirstEvent
			, FirstASQDate
			, FirstHomeVisitDate
			, FirstKempeDate
			, fn.FirstEvent
			, wrkr.SupervisionScheduledDay
			, case isnull(
							SupervisionScheduledDay
							, datepart(
										weekday
										, dateadd(
													day
													,	(isnull(
													wrkr.SupervisionScheduledDay
													, datepart(weekday, @sDate)
													)-datepart(weekday, @sDate)
													), @sDate
												)
									)
						)when 1 then 'Sunday'
				when 2 then 'Monday'
				when 3 then 'Tuesday'
				when 4 then 'Wednesday'
				when 5 then 'Thursday'
				when 6 then 'Friday'
				when 7 then 'Saturday'
				else 'Monday' -- Default value
				end as ScheduledDayName

			-- let us adjust the startdate for the worker (depends on SupervisionScheduledDay)
			-- replace the start date of the report with worker's scheduled date of supervision	
			--,dateadd(day,(isnull(wrkr.SupervisionScheduledDay,DATEPART(weekday,@sDate)) - DATEPART(weekday,@sDate)), @sDate) as sdate
			-- Note: given sdate = 10/01/13 (i.e. Tuesday)and DayOfWeekSupScheduled = 2 (i.e. Monday) FIND the next monday (10/07/13) which will be in the first week period
			--       else if DayOfWeekSupScheduled >= weekday of sDate then FIND the date of DayOfWeekSupScheduled from sDate
			, case when (isnull(wrkr.SupervisionScheduledDay, datepart(weekday, @sDate))
						-datepart(weekday, @sDate)
						) < 0 then
						dateadd(
									day, 7
								, dateadd(
											day
											,	(isnull(
												wrkr.SupervisionScheduledDay
												, datepart(weekday, @sDate)
												)-datepart(weekday, @sDate)
											), @sDate
										)
								)
				else
					dateadd(
							day
							,	(isnull(wrkr.SupervisionScheduledDay, datepart(weekday, @sDate))
								-datepart(weekday, @sDate)
							), @sDate
						)end as sdate


			, @eDate as edate

	from		#tblStaff w
	inner join	WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = @ProgramFK
	inner join	dbo.fnGetWorkerEventDatesALL(@ProgramFK, null, null) fn on fn.WorkerPK = w.WorkerPK
	left join	Worker wrkr on w.WorkerPK = wrkr.WorkerPK -- bring in SupervisionScheduledDay
	where		w.WorkerPK not in (select WorkerPK from #tblSUPPMWorkers)
				 and 
				fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa

				and w.WorkerPK = isnull(@workerfk, w.WorkerPK)
				and wp.SupervisorFK = isnull(@supervisorfk, wp.SupervisorFK)
				--and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
				and (case when @sitefk = 0 then 1 when wp.SiteFK = @sitefk then 1 else 0 end = 1)
				--and wrkr.FTE <> '03'
	order by	w.WorkerName ;


	--SELECT * FROM 	#tblWorkers
	--	----- RESET the startdate if firstevent date falls between @sdate and @edate
	--	--declare @FirstEventDate	datetime	
	--	--set @FirstEventDate = (select * from #tblWorkers)

	--	-- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'		
	--	-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'		

	--	--Step#: 2
	--	-- use a recursive CTE to generate the list of dates  ... Khalsa
	--	-- Given any startdate, find all week dates starting with that date and less then the end date
	--	-- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes


	create table #tblWeekPeriods (WorkerPK int, WeekNumber int, StartDate datetime, EndDate datetime)

	;
	with cteGenerateWeeksGiven2Dates
	as (

		select	WorkerPK
			, 1 as WeekNumber
			, sdate as StartDate
			, dateadd(d, 6, sdate) EndDate
		from	#tblWorkers
		union all

		select	WorkerPK
			, WeekNumber+1 as WeekNumber
			, dateadd(d, 7, StartDate) as StartDate
			, dateadd(d, 7, EndDate) as EndDate


		from	cteGenerateWeeksGiven2Dates

		where	dateadd(d, 6, StartDate) < @eDate ---  @eDate date entered by the user from UI

	)


	--SELECT * FROM cteGenerateWeeksGiven2Dates
	--order by workerpk	

	-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'		

	insert into #tblWeekPeriods select * from cteGenerateWeeksGiven2Dates ;

	------ We are only interested in each week's start date
	------ These are all the weeks between given two dates but at the end we added user given @eDate ... khalsa

	-- insert user's enddate at the end for the last period
	--update #tblWeekPeriods
	--set EndDate = @eDate
	--where WeekNumber = (select top 1 WeekNumber from #tblWeekPeriods order by WeekNumber desc)
	-- fix jr 2014-10-02 the above update only updated all groups for the highest WeekNumber across all groups
	--					 it needs to grab the highest WeekNumber by worker, which is what this now does
	update		#tblWeekPeriods
	set			EndDate = @eDate
	from		#tblWeekPeriods wp
	inner join	(
				select		WorkerPK
						, max(WeekNumber) as LatestWeek
				from		#tblWeekPeriods
				group by	WorkerPK
				) wp2 on wp2.WorkerPK = wp.WorkerPK and wp.WeekNumber = wp2.LatestWeek ;

	--SELECT * FROM #tblWeekPeriods
	--where workerpk = 152
	--order by workerpk

	-- Let us make sure that if a worker's firstevent date falls between @sdate and @edate then 
	-- adjust number of weeks for that worker. It will be less because he did not do anything till firstevent
	create table #tblWeekPeriodsAdjusted (
										WeekNumber	int
									, StartDate datetime
									, EndDate datetime
									, FirstEvent datetime
									, WorkerPK int
										) ;

	insert into #tblWeekPeriodsAdjusted
	select		WeekNumber
			, StartDate
			, EndDate
			, FirstEvent
			, wp.WorkerPK
	from		#tblWeekPeriods wp
	inner join	#tblWorkers w on FirstEvent < StartDate and wp.WorkerPK = w.WorkerPK ;

	--SELECT * FROM #tblWeekPeriodsAdjusted
	----where workerpk = 152
	--order by workerpk		 

	-- rspCredentialingSupervision 1, '10/01/2013', '12/31/2013'

	------		--Note: Don't delete the following SELECT
	------		--SELECT 
	------		--	WeekNumber
	------		--	,StartDate
	------		--	,EndDate
	------		--	,datediff(day, StartDate,EndDate) as DaysInTheCurrentWeek			
	------		--FROM #tblWeekPeriods	

	--			max of 2 supervisions per week ... khalsa
	create table #tblMaxOf2SupvisionPerWeekToBeConsidered (WorkerPK int, Duration int, WeekNumber int, rownum int)

	-- Step#: 3
	-- Now let us develop the report. We will use the above 2 temp tables now

	;
	with cteWorkersWithSupervisionsII
	as (
		select		wp.WeekNumber
				, wp.StartDate
				, wp.EndDate
				, wp.FirstEvent
				, wp.WorkerPK
				, WorkerName
				, LastName
				, FirstName
				, TerminationDate
				--, WorkerPK
				, SortOrder
				, WorkerFKFn
				, WrkrLName
				, FAWInitialStart
				, SupervisorInitialStart
				, FSWInitialStart
				, ProgramManagerStartDate
				, TerminationDateFn
				, HireDate
				, SupervisorFirstEvent
				, FirstASQDate
				, FirstHomeVisitDate
				, FirstKempeDate
				--, FirstEvent			
				, s.SupervisionPK
				, s.Boundaries
				, s.BoundariesComments
				, s.BoundariesStatus
				, s.Caseload
				, s.CaseloadComments
				, s.CaseloadStatus
				, s.Coaching
				, s.CoachingComments
				, s.CoachingStatus
				, s.CPS
				, s.CPSComments
				, s.CPSStatus
				, s.Curriculum
				, s.CurriculumComments
				, s.CurriculumStatus
				, s.FamilyReview
				, s.FamilyReviewComments
				, s.FamilyReviewStatus
				, s.FormComplete
				, s.ImpactOfWork
				, s.ImpactOfWorkComments
				, s.ImpactOfWorkStatus
				, s.ImplementTraining
				, s.ImplementTrainingComments
				, s.ImplementTrainingStatus
				, s.Outreach
				, s.OutreachComments
				, s.OutreachStatus
				, s.Personnel
				, s.PersonnelComments
				, s.PersonnelStatus
				, s.PIP
				, s.PIPComments
				, s.PIPStatus
				, s.ProfessionalGrowth
				, s.ProfessionalGrowthComments
				, s.ProfessionalGrowthStatus
				, s.ProgramFK
				, s.RecordDocumentation
				, s.RecordDocumentationComments
				, s.RecordDocumentationStatus
				, s.Retention
				, s.RetentionComments
				, s.RetentionStatus
				, s.RolePlaying
				, s.RolePlayingComments
				, s.RolePlayingStatus
				, s.Safety
				, s.SafetyComments
				, s.SafetyStatus
				, s.SiteDocumentation
				, s.SiteDocumentationComments
				, s.SiteDocumentationStatus
				, s.Strengths
				, s.StrengthsComments
				, s.StrengthsStatus
				, s.SupervisionCreateDate
				, s.SupervisionCreator
				, s.SupervisionDate
				, s.SupervisionEditDate
				, s.SupervisionEditor
				, s.SupervisionEndTime
				, s.SupervisionHours
				, s.SupervisionMinutes
				, s.SupervisionNotes
				, s.SupervisionSessionType
				, s.SupervisionStartTime
				, s.SupervisorFK
				, s.SupervisorObservationAssessment
				, s.SupervisorObservationAssessmentComments
				, s.SupervisorObservationAssessmentStatus
				, s.SupervisorObservationHomeVisit
				, s.SupervisorObservationHomeVisitComments
				, s.SupervisorObservationHomeVisitStatus
				, s.SupervisorObservationSupervision
				, s.SupervisorObservationSupervisionComments
				, s.SupervisorObservationSupervisionStatus
				, s.SupportHFAModel
				, s.SupportHFAModelComments
				, s.SupportHFAModelStatus
				, s.TeamDevelopment
				, s.TeamDevelopmentComments
				, s.TeamDevelopmentStatus
				, s.WorkerFK
				, s.ParticipantEmergency
				, s.ReasonOther
				, s.ReasonOtherSpecify
				, s.ShortWeek
				, s.StaffCourt
				, s.StaffFamilyEmergency
				, s.StaffForgot
				, s.StaffIll
				, s.StaffOnLeave
				, s.StaffTraining
				, s.StaffVacation
				, s.StaffOutAllWeek
				, s.SupervisorFamilyEmergency
				, s.SupervisorForgot
				, s.SupervisorHoliday
				, s.SupervisorIll
				, s.SupervisorTraining
				, s.SupervisorVacation
				, s.Weather
				-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
				, datediff(d, StartDate, EndDate)+1 as DaysInTheCurrentWeek -- null means that there was no supervision record found for that week  ... khalsa		  
		--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  

		from		#tblWeekPeriodsAdjusted wp
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
		left join	Supervision s on s.WorkerFK = w.WorkerPK
									and SupervisionDate between StartDate and EndDate
	)

	,	cteSupervisionDurations
	as (
		select	WorkerPK
			, isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration1
			, WeekNumber

		from	cteWorkersWithSupervisionsII
	)
	,	cteSupervisionsPerWorkerPerWeek
	as (
		select	WorkerPK
			, Duration1
			--,sum(Duration) as WeeklyDuration
			, WeekNumber
			, rownum = row_number() over (partition by WorkerPK
													, WeekNumber
											order by WorkerPK
												, WeekNumber
												, Duration1 desc
										)
		from	cteSupervisionDurations sd
	)

	-- Now take the top 2 supervisions, if any
	insert into #tblMaxOf2SupvisionPerWeekToBeConsidered
	select		*
	from		cteSupervisionsPerWorkerPerWeek
	where		rownum <= 2
	order by	WorkerPK
			, WeekNumber
			, Duration1 desc

	--SELECT * FROM #tblMaxOf2SupvisionPerWeekToBeConsidered

	;
	with cteWorkersWithSupervisions
	as (
		select		wp.WeekNumber
				, wp.StartDate
				, wp.EndDate
				, wp.FirstEvent
				, wp.WorkerPK
				, WorkerName
				, LastName
				, FirstName
				, TerminationDate
				--, WorkerPK
				, SortOrder
				, WorkerFKFn
				, WrkrLName
				, FAWInitialStart
				, SupervisorInitialStart
				, FSWInitialStart
				, ProgramManagerStartDate
				, TerminationDateFn
				, HireDate
				, SupervisorFirstEvent
				, FirstASQDate
				, FirstHomeVisitDate
				, FirstKempeDate
				--, FirstEvent			
				, s.SupervisionPK
				, s.Boundaries
				, s.BoundariesComments
				, s.BoundariesStatus
				, s.Caseload
				, s.CaseloadComments
				, s.CaseloadStatus
				, s.Coaching
				, s.CoachingComments
				, s.CoachingStatus
				, s.CPS
				, s.CPSComments
				, s.CPSStatus
				, s.Curriculum
				, s.CurriculumComments
				, s.CurriculumStatus
				, s.FamilyReview
				, s.FamilyReviewComments
				, s.FamilyReviewStatus
				, s.FormComplete
				, s.ImpactOfWork
				, s.ImpactOfWorkComments
				, s.ImpactOfWorkStatus
				, s.ImplementTraining
				, s.ImplementTrainingComments
				, s.ImplementTrainingStatus
				, s.Outreach
				, s.OutreachComments
				, s.OutreachStatus
				, s.Personnel
				, s.PersonnelComments
				, s.PersonnelStatus
				, s.PIP
				, s.PIPComments
				, s.PIPStatus
				, s.ProfessionalGrowth
				, s.ProfessionalGrowthComments
				, s.ProfessionalGrowthStatus
				, s.ProgramFK
				, s.RecordDocumentation
				, s.RecordDocumentationComments
				, s.RecordDocumentationStatus
				, s.Retention
				, s.RetentionComments
				, s.RetentionStatus
				, s.RolePlaying
				, s.RolePlayingComments
				, s.RolePlayingStatus
				, s.Safety
				, s.SafetyComments
				, s.SafetyStatus
				, s.SiteDocumentation
				, s.SiteDocumentationComments
				, s.SiteDocumentationStatus
				, s.Strengths
				, s.StrengthsComments
				, s.StrengthsStatus
				, s.SupervisionCreateDate
				, s.SupervisionCreator
				, s.SupervisionDate
				, s.SupervisionEditDate
				, s.SupervisionEditor
				, s.SupervisionEndTime
				, s.SupervisionHours
				, s.SupervisionMinutes
				, s.SupervisionNotes
				, s.SupervisionSessionType
				, s.SupervisionStartTime
				, s.SupervisorFK
				, s.SupervisorObservationAssessment
				, s.SupervisorObservationAssessmentComments
				, s.SupervisorObservationAssessmentStatus
				, s.SupervisorObservationHomeVisit
				, s.SupervisorObservationHomeVisitComments
				, s.SupervisorObservationHomeVisitStatus
				, s.SupervisorObservationSupervision
				, s.SupervisorObservationSupervisionComments
				, s.SupervisorObservationSupervisionStatus
				, s.SupportHFAModel
				, s.SupportHFAModelComments
				, s.SupportHFAModelStatus
				, s.TeamDevelopment
				, s.TeamDevelopmentComments
				, s.TeamDevelopmentStatus
				, s.WorkerFK
				, s.ParticipantEmergency
				, s.ReasonOther
				, s.ReasonOtherSpecify
				, s.ShortWeek
				, s.StaffCourt
				, s.StaffFamilyEmergency
				, s.StaffForgot
				, s.StaffIll
				, s.StaffOnLeave
				, s.StaffTraining
				, s.StaffVacation
				, s.StaffOutAllWeek
				, s.SupervisorFamilyEmergency
				, s.SupervisorForgot
				, s.SupervisorHoliday
				, s.SupervisorIll
				, s.SupervisorTraining
				, s.SupervisorVacation
				, s.Weather
				-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
				, datediff(d, StartDate, EndDate)+1 as DaysInTheCurrentWeek -- null means that there was no supervision record found for that week  ... khalsa		  
		--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  

		from		#tblWeekPeriodsAdjusted wp
		--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
		left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
		left join	Supervision s on s.WorkerFK = w.WorkerPK
									and SupervisionDate between StartDate and EndDate
	)

	--------select datediff(d, '01/06/2013', '01/13/2013')		
	--------select datediff(d, '01/20/2013', '01/27/2013')	

	--SELECT * FROM cteWorkersWithSupervisions
	--order by workername,weeknumber, SupervisionDate

	-------- rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'		
	-------- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'					

	, cteSupervisors
	as (
		select		ltrim(rtrim(LastName))+', '+ltrim(rtrim(FirstName)) as SupervisorName
				, TerminationDate
				, WorkerPK
				, 'SUP' as workertype
		from		Worker w
		inner join	WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where		ProgramFK = @ProgramFK
					and current_Timestamp 
						between SupervisorStartDate and 
								isnull(SupervisorEndDate
										, dateadd(dd , 1, 
												datediff(dd, 0, getdate())))
	)

	,	cteAssignedSupervisorFKS
	as (
		select		tw.WorkerPK
				, wp.SupervisorFK
		from		#tblWorkers tw
		inner join	WorkerProgram wp on wp.WorkerFK = tw.WorkerPK
		where		ProgramFK = @ProgramFK
	)

	,	cteAssignedSupervisorsName
	as (
		select		SupervisorFK
				, asf.WorkerPK
				, ltrim(rtrim(w.LastName))+', '+ltrim(rtrim(w.FirstName)) as AssignedSupervisorName
		from		cteAssignedSupervisorFKS asf
		left join	Worker w on w.WorkerPK = asf.SupervisorFK
	)


	------ rspCredentialingSupervision 1, '06/01/2013', '08/31/2013'

	------SELECT * FROM cteAssignedSupervisorsName	

	, cteSupervisionReasonsNotTookPlace
	as (
		select		SupervisionPK

				, case when ParticipantEmergency = 1 then 'Participant emergency'
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
					when ReasonOther = 1 then ReasonOtherSpecify
					when Weather = 1 then 'Inclement weather'
					else '' end as ReasonNOSupervision
		from		#tblWorkers w
		left join	Supervision s on s.WorkerFK = w.WorkerPK
		where		s.SupervisionSessionType = '0'
	)

	,	cteSupervisionReasonsChecked
	as (
		select		SupervisionPK
				, sum(convert(int, ParticipantEmergency)+convert(int, ShortWeek)
						+convert(int, StaffCourt)+convert(int, StaffFamilyEmergency)
						+convert(int, StaffForgot)+convert(int, StaffIll)+convert(int, StaffTraining)
						+convert(int, StaffVacation)+convert(int, StaffOutAllWeek)
						+convert(int, SupervisorFamilyEmergency)+convert(int, SupervisorForgot)
						+convert(int, SupervisorHoliday)+convert(int, SupervisorIll)
						+convert(int, SupervisorTraining)+convert(int, SupervisorVacation)
						+convert(int, ReasonOther)+convert(int, Weather)
					) as NumOfReasonsChecked
		from		#tblWorkers w
		left join	Supervision s on s.WorkerFK = w.WorkerPK
		where		s.SupervisionSessionType = '0'
		group by	SupervisionPK
	)

	-- rspCredentialingSupervision 1, '10/01/2013', '12/31/2013'

	--SELECT * FROM cteSupervisionReasonsChecked

	------------	--SELECT * FROM cteSupervisionReasonsNotTookPlace

	-------------- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'		



	--SELECT * FROM #tblMaxOf2SupvisionPerWeekToBeConsidered



	------ rspCredentialingSupervision 1, '10/01/2013', '12/31/2013'


	, cteSupervisionDurationsGroupedByWeek
	as (
		select		WorkerPK
				, sum(Duration) as WeeklyDuration
				, WeekNumber

		from		#tblMaxOf2SupvisionPerWeekToBeConsidered sd
		group by	WorkerPK
				, WeekNumber
	)

	--SELECT * FROM 	cteSupervisionDurationsGroupedByWeek
	--	order by WorkerPK, WeekNumber



	, cteSupervisionEvents
	as (

		select		wws.WorkerPK
				, WorkerName
				, StartDate
				, EndDate				
				, case when wws.SupervisionSessionType = '1' 
						then 'Y'
						else 'N' 
					end as SupervisionTookPlace
				, SupervisionDate
				, SupervisionHours
				, SupervisionMinutes
				, isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
				, sdg.WeeklyDuration
				, wws.SupervisionSessionType
				, case

					-- Form found in period and reason is "Staff out all week"
					-- Note: E = Excused
					when (wws.SupervisionSessionType = '0') and 
							(StaffOutAllWeek = 1) then 'E' 
					-- Form found in period and reason is not "Staff out all week"				
					when (wws.SupervisionSessionType = '0') and 
							(StaffOutAllWeek <> 1) and 
							(sdg.WeeklyDuration = 0) then 'N' 

					-- Form found in period and duration is 1:30 or greater 
 					when (sdg.WeeklyDuration >= (case when w.FTE = '01' then 90
												when w.FTE = '02' then 60
												when w.FTE = '03' then 15
												else 90 end
												)
						--90
						) then 'Y'
					-- Form found in period and duration less than 1:30
					when (sdg.WeeklyDuration < (case when w.FTE = '01' then 90
												when w.FTE = '02' then 60
												when w.FTE = '03' then 15
												else 90 end
											)
						--90
						) and (wws.SupervisionSessionType = '1') then 'N' 
					-- Form not found in period
					when (wws.WorkerFK is null and wws.SupervisionPK is NULL AND wl.WorkerLeavePK IS NULL) then 'N'
					WHEN wl.WorkerLeavePK IS NOT NULL THEN 'E' -- Form not found in period, but worker was on leave during the period
					end as MeetsStandard
				, case
					-- when (TakePlace = 0) and (StaffOutAllWeek = 1)  then 'Staff out all week'  -- Form found in period and reason is "Staff out all week"
					-- Note: E = Excused
					when (wws.SupervisionSessionType = '0') and (StaffOutAllWeek = 1)
						and (reasonsChecked.NumOfReasonsChecked >= 1) then
						-- need to display more if there is more than one reasons checked
						case when reasonsChecked.NumOfReasonsChecked > 1 
								then 'Staff out all week and more'
								else 'Staff out all week' 
						end
					when (wws.SupervisionSessionType = '0') and (StaffOutAllWeek <> 1)
						and (reasonsChecked.NumOfReasonsChecked >= 1) then
						-- need to display more if there is more than one reasons checked
						case when reasonsChecked.NumOfReasonsChecked > 1 then
								reason.ReasonNOSupervision+' and more'
						else reason.ReasonNOSupervision -- Form found in period and reason is not “Staff out all week”
						end
					-- Form found in period and duration is 1:30 or greater 
					when (isnull(SupervisionHours * 60, 0) + 
							isnull(SupervisionMinutes, 0) >=
							(case when w.FTE = '01' then 90
								when w.FTE = '02' then 60
								when w.FTE = '03' then 15
								else 90 end
							)
						-- 90
						) and (wws.SupervisionSessionType in ('1', '2')) then '' 
					-- Form found in period and duration less than 1:30
					when (isnull(SupervisionHours * 60, 0) + 
							isnull(SupervisionMinutes, 0) <
							(case when w.FTE = '01' then 90
									when w.FTE = '02' then 60
									when w.FTE = '03' then 15
									else 90 end
								)
						-- 90
						) and (wws.SupervisionSessionType = '1') then 'Duration less than 1:30'
					when wws.SupervisionSessionType = '2' then 'Planning-only'
					when (wws.WorkerFK is null and wws.SupervisionPK is NULL AND wl.WorkerLeavePK IS NULL) then 'Unknown/Missing' -- Form not found in period
					WHEN wl.WorkerLeavePK IS NOT NULL THEN 'Worker on leave' -- Form not found in period, but worker was on leave during the period
					end as ReasonSupeVisionNotHeld

				--,reason.ReasonNOSupervision

				, wws.SupervisionPK
				, SupervisorFK
				, sup.SupervisorName
				, wws.WorkerFK
				, wws.WeekNumber
				, wws.DaysInTheCurrentWeek
				, wws.FirstEvent

		from		cteWorkersWithSupervisions wws
		left join	cteSupervisors sup on wws.SupervisorFK = sup.WorkerPK -- to fetch in supervisor's name
		left join	cteSupervisionReasonsNotTookPlace reason on reason.SupervisionPK = wws.SupervisionPK -- to fetch in reasons for supervision not took place
		left join	cteSupervisionReasonsChecked reasonsChecked on reasonsChecked.SupervisionPK = reason.SupervisionPK
		left join	cteSupervisionDurationsGroupedByWeek sdg on sdg.WorkerPK = wws.WorkerPK
																and sdg.WeekNumber = wws.WeekNumber
		LEFT JOIN dbo.WorkerLeave wl ON wws.WorkerPK = wl.WorkerFK -- To fetch the leave records for the worker
						AND (wws.StartDate BETWEEN wl.LeaveStartDate AND wl.LeaveEndDate 
								OR wws.EndDate BETWEEN wl.LeaveStartDate AND wl.LeaveEndDate)
		left join	Worker w on wws.WorkerFK = w.WorkerPK

	)


	----SELECT * FROM cteSupervisionEvents
	----order by workername,weeknumber, SupervisionDate

	--------	rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'

	, cteReportDetails
	as (
		select	WorkerName
			, StartDate
			, EndDate
			--,SupervisionTookPlace
			, SupervisionDate
			, SupervisionHours
			, SupervisionMinutes
			, Duration
			--,WeeklyDuration
			, SupervisionSessionType
			, case when Duration = 0 and MeetsStandard = 'Y'
						and ReasonSupeVisionNotHeld is not null then ''
				when DaysInTheCurrentWeek is not null and DaysInTheCurrentWeek < 7 then
					'Less Than a Week'
				else MeetsStandard end as MeetsStandard

			--,MeetsStandard		  
			--,SupervisionPK
			--,SupervisorFK
			, SupervisorName
			, ReasonSupeVisionNotHeld
			--,WorkerFK
			, DaysInTheCurrentWeek
			, WeekNumber
			, FirstEvent
			, WorkerPK
		from	cteSupervisionEvents
	)

	--SELECT * FROM cteReportDetails
	-- rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'	


	, cteReportDetailsModified
	as (

		select	WorkerName
			, StartDate
			, EndDate
			, SupervisionDate
			, SupervisionHours
			, SupervisionMinutes
			, Duration
			, SupervisionSessionType
			, MeetsStandard
			--ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
			, case when (FirstEvent between @sDate and @eDate) then

						case when (FirstEvent <= EndDate) then MeetsStandard else '' end


				else

					MeetsStandard end

			as MeetsStandard1
			, SupervisorName
			, ReasonSupeVisionNotHeld
			, DaysInTheCurrentWeek
			, WeekNumber
			, @sDate as sdate1
			, @eDate as edate1
			, FirstEvent
			, WorkerPK
		from	cteReportDetails
	)


	--SELECT * FROM cteReportDetailsModified
	--order by workername,weeknumber, SupervisionDate
	-- rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'	



	-- need a copy of cteReportDetailsModified later usuage
	, cteReport1
	as (

		select	WorkerName
			, StartDate
			, EndDate
			, SupervisionDate
			, SupervisionHours
			, SupervisionMinutes
			, Duration
			, SupervisionSessionType
			, MeetsStandard
			--ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
			, case when (FirstEvent between @sDate and @eDate) then
						-- Need JH Help
						case when (FirstEvent <= EndDate) then MeetsStandard else '' end
				else MeetsStandard end as MeetsStandard1
			, SupervisorName
			, ReasonSupeVisionNotHeld
			, DaysInTheCurrentWeek
			, WeekNumber
			, FirstEvent
			, WorkerPK
		from	cteReportDetails
	)

	------SELECT * FROM ctecteReportDetailsModified
	------			order by workername, weeknumber, SupervisionDate

	------ rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'	

	, cteUniqueMeetsStandard
	as (
		select	distinct WorkerName
					, MeetsStandard1
					, WeekNumber
					, DaysInTheCurrentWeek

		from	cteReportDetailsModified
	)

	,	cteScoreByWorker
	as (

		select		WorkerName
				, sum(	case when DaysInTheCurrentWeek = 7 and	MeetsStandard1 <> ' ' then 1
						else 0 end
					) as NumOfExpectedSessions
				, sum(case when MeetsStandard1 = 'E' then 1 else 0 end) as NumOfAllowedExecuses
				, sum(case when MeetsStandard1 = 'Y' then 1 else 0 end) as NumOfMeetStandardYes
		--,weeknumber
		--,DaysInTheCurrentWeek
		from		cteUniqueMeetsStandard
		group by	WorkerName
	)


	select		cr.WorkerName
			, convert(varchar(12), StartDate, 101) as startdate
			--,enddate
			, convert(varchar(12), SupervisionDate, 101) as SupervisionDate
			--,SupervisionHours
			--,SupervisionMinutes
			, case -- convert to string
				when SupervisionHours > 0 and SupervisionMinutes > 0 then
					convert(varchar(10), SupervisionHours) + 
					':' + 
					case when SupervisionMinutes < 10
							then '0' 
							else ''
					end + trim(convert(varchar(2), SupervisionMinutes))
				when SupervisionHours > 0 and (SupervisionMinutes = 0 or 
						SupervisionMinutes is null) then
					convert(varchar(10), SupervisionHours)+':00'
				when (SupervisionHours = 0 or SupervisionHours is null) and 
						SupervisionMinutes > 0 then
					'0:' + 
					case when SupervisionMinutes < 10
							then '0' 
							else ''
					end + trim(convert(varchar(2), SupervisionMinutes))			
				else ' ' 
			end 
			as Duration
			, case SupervisionSessionType 
					when '1' then 'Y' 
					when '2' then 'P' 
					else 'N' end as TakePlace
			, MeetsStandard1 as MeetsStandard
			, SupervisorName
			, ReasonSupeVisionNotHeld
			, cr.FirstEvent
			, cr.WorkerPK
			, case when w.FAWInitialStart is not null and 
					w.FSWInitialStart is not null and
					w.SupervisorInitialStart is not null and 
					twrkr.ProgramManagerStartDate is not null
					 then 'FRS, FSS, Sup, PM'
				when w.FAWInitialStart is not null and 
					w.FSWInitialStart is not null and
					w.SupervisorInitialStart is not null 
					then 'FRS, FSS, Sup'
				when w.FAWInitialStart is not null and 
					w.FSWInitialStart is not null
					then 'FRS, FSS'
				when w.FAWInitialStart is not null then 'FRS'
				when w.FSWInitialStart is not null then 'FSS'
				else '' end as workerRole

			, DaysInTheCurrentWeek
			, NumOfExpectedSessions
			, NumOfAllowedExecuses
			, NumOfExpectedSessions-NumOfAllowedExecuses as NumOfAdjExptdSupervisions
			, NumOfMeetStandardYes
			, convert(varchar, NumOfMeetStandardYes)+' ('
				+convert(
							varchar
						, round(
									coalesce(
												cast(NumOfMeetStandardYes as float)* 100
												/ nullif((NumOfExpectedSessions-NumOfAllowedExecuses), 0)
											, 0
											)	, 0
								)
						)+'%)' as PerctOfAccptbleSupervisions
			, case
				--CP 08/14/2014 If numb of allowed excuses is equal to num of exprected sessions (e.g. NO supervisions required) then HFA Rating should be a 3
				when NumOfExpectedSessions-NumOfAllowedExecuses = 0 then 3
				when convert(
								varchar
							, round(
										coalesce(
													cast(NumOfMeetStandardYes as float)* 100
													/ nullif((NumOfExpectedSessions-NumOfAllowedExecuses), 0)
												, 0
												)	, 0
									)
							) >= 90 then 3
				when convert(
								varchar
							, round(
										coalesce(
													cast(NumOfMeetStandardYes as float)* 100
													/ nullif((NumOfExpectedSessions-NumOfAllowedExecuses), 0)
												, 0
												)	, 0
									)
							) between 75 and 90 then 2
				when convert(
								varchar
							, round(
										coalesce(
													cast(NumOfMeetStandardYes as float)* 100
													/ nullif((NumOfExpectedSessions-NumOfAllowedExecuses), 0)
												, 0
												)	, 0
									)
							) < 75 then 1 end as HFARating
			, asn.AssignedSupervisorName

			, twrkr.ScheduledDayName as ScheduledDayName
			, twrkr.SupervisionScheduledDay
			, convert(varchar(12), twrkr.sdate, 101) as AdjustedStartDate
			----,@DayofWeek as DayNameSelectedByUser
			--, w.FTEFullTime AS FTEFullTime
			, w.FTE as FTE
			, case when w.FTE = '01' then 'Full time'
				when w.FTE = '02' then 'Part Time (.25 thru .75)'
				when w.FTE = '03' then 'Part Time (less than .25)'
				else 'Unknown/Missing' end FTEText
	from		cteReport1 cr
	left join	cteScoreByWorker sw on sw.WorkerName = cr.WorkerName
	left join	Worker w on w.WorkerPK = cr.WorkerPK
	left join	cteAssignedSupervisorsName asn on asn.WorkerPK = cr.WorkerPK
	left join	#tblWorkers twrkr on twrkr.WorkerPK = w.WorkerPK
	--where MeetsStandard <> 'N/A'
	order by	cr.WorkerName
			, cr.WeekNumber
			, cr.SupervisionDate ;

	-- rspCredentialingSupervision 31, '07/01/2013', '09/30/2013'	
	-- rspCredentialingSupervision 1, '01/06/2013', '02/02/2013'			
	-- rspCredentialingSupervision 1, '04/01/2013', '04/30/2013'		
	-- rspCredentialingSupervision 1, '03/01/2013', '03/31/2013'		

	drop table #tblStaff ;
	drop table #tblSUPPMWorkers ;
	drop table #tblWorkers ;
	drop table #tblWeekPeriods ;
	drop table #tblMaxOf2SupvisionPerWeekToBeConsidered ;
end ;
GO
