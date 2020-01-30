SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure:	rspCredentialingSupervisionSummary
-- Author:		Devinder Singh Khalsa
-- Create date: September 16th, 2013
-- Description:	Credentialing report for Supervisions Summary

-- rspCredentialingSupervisionSummary 1, '10/01/2013', '12/31/2013'
-- rspCredentialingSupervisionSummary 4, '06/01/2013', '08/31/2013'
-- rspCredentialingSupervisionSummary 1, '06/01/2013', '08/31/2013',null,152,null
-- rspCredentialingSupervisionSummary 1, '06/01/2013', '08/31/2013',null,null,5
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

-- Fix: replace the start date of the report with worker's scheduled date of supervision  ... Khalsa 01/13/2013
-- rspCredentialingSupervisionSummary 11, '10/01/2013', '12/31/2013',null,673,null,2
-- rspCredentialingSupervisionSummary 19, '07/01/2014', '09/30/2014',null,null,null

-- max of 2 supervisions per week ... khalsa 1/29/2014

-- =============================================
CREATE PROC [dbo].[rspCredentialingSupervisionSummary] @ProgramFK int = null
												, @sDate datetime = null
												, @eDate datetime = null
												, @supervisorfk int = null
												, @workerfk int = null
												, @sitefk int = null

as


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
											wrkr.SupervisionScheduledDay, datepart(weekday, @sDate)
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
where		w.WorkerPK not in (select WorkerPK from #tblSUPPMWorkers) and 
			fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa
			and w.WorkerPK = isnull(@workerfk, w.WorkerPK)
			and wp.SupervisorFK = isnull(@supervisorfk, wp.SupervisorFK)
			--and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
			and (case when @sitefk = 0 then 1 when wp.SiteFK = @sitefk then 1 else 0 end = 1)
			--and wrkr.FTE <> '03'
order by	w.WorkerName ;

-- rspCredentialingSupervisionSummary 1, '01/06/2013', '02/02/2013'		
-- rspCredentialingSupervisionSummary 1, '03/01/2013', '03/31/2013'		

--Step#: 2
-- use a recursive CTE to generate the list of dates  ... Khalsa
-- Given any startdate, find all week dates starting with that date and less then the end date
-- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes

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

insert into #tblWeekPeriods select * from cteGenerateWeeksGiven2Dates
option (maxRecursion 0) ; --CP 9-8-2017 fixes error SQL Server : the maximum recursion 100 has been exhausted before statement completion

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
	select

				wp.WeekNumber
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
			, TerminationDateFn
			, HireDate
			, SupervisorFirstEvent
			, FirstASQDate
			, FirstHomeVisitDate
			, FirstKempeDate
			--, FirstEvent
			, SupervisionPK
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
			, s.ParticipantEmergency
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
			, s.ReasonOther
			, s.ReasonOtherSpecify
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
			, s.ShortWeek
			, s.SiteDocumentation
			, s.SiteDocumentationComments
			, s.SiteDocumentationStatus
			, s.StaffCourt
			, s.StaffFamilyEmergency
			, s.StaffForgot
			, s.StaffIll
			, s.StaffOnLeave
			, s.StaffOutAllWeek
			, s.StaffTraining
			, s.StaffVacation
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
			, s.SupervisorFamilyEmergency
			, s.SupervisorFK
			, s.SupervisorForgot
			, s.SupervisorHoliday
			, s.SupervisorIll
			, s.SupervisorObservationAssessment
			, s.SupervisorObservationAssessmentComments
			, s.SupervisorObservationAssessmentStatus
			, s.SupervisorObservationHomeVisit
			, s.SupervisorObservationHomeVisitComments
			, s.SupervisorObservationHomeVisitStatus
			, s.SupervisorObservationSupervision
			, s.SupervisorObservationSupervisionComments
			, s.SupervisorObservationSupervisionStatus
			, s.SupervisorTraining
			, s.SupervisorVacation
			, s.SupportHFAModel
			, s.SupportHFAModelComments
			, s.SupportHFAModelStatus
			, s.TeamDevelopment
			, s.TeamDevelopmentComments
			, s.TeamDevelopmentStatus
			, s.Weather
			, s.WorkerFK
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
	select

				wp.WeekNumber
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
			, TerminationDateFn
			, HireDate
			, SupervisorFirstEvent
			, FirstASQDate
			, FirstHomeVisitDate
			, FirstKempeDate
			--, FirstEvent			





			, SupervisionPK
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
			, s.ParticipantEmergency
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
			, s.ReasonOther
			, s.ReasonOtherSpecify
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
			, s.ShortWeek
			, s.SiteDocumentation
			, s.SiteDocumentationComments
			, s.SiteDocumentationStatus
			, s.StaffCourt
			, s.StaffFamilyEmergency
			, s.StaffForgot
			, s.StaffIll
			, s.StaffOnLeave
			, s.StaffOutAllWeek
			, s.StaffTraining
			, s.StaffVacation
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
			, s.SupervisorFamilyEmergency
			, s.SupervisorFK
			, s.SupervisorForgot
			, s.SupervisorHoliday
			, s.SupervisorIll
			, s.SupervisorObservationAssessment
			, s.SupervisorObservationAssessmentComments
			, s.SupervisorObservationAssessmentStatus
			, s.SupervisorObservationHomeVisit
			, s.SupervisorObservationHomeVisitComments
			, s.SupervisorObservationHomeVisitStatus
			, s.SupervisorObservationSupervision
			, s.SupervisorObservationSupervisionComments
			, s.SupervisorObservationSupervisionStatus
			, s.SupervisorTraining
			, s.SupervisorVacation
			, s.SupportHFAModel
			, s.SupportHFAModelComments
			, s.SupportHFAModelStatus
			, s.TeamDevelopment
			, s.TeamDevelopmentComments
			, s.TeamDevelopmentStatus
			, s.Weather
			, s.WorkerFK
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
	inner join	WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = @ProgramFK
	where		ProgramFK = @ProgramFK
				and current_Timestamp between SupervisorStartDate and isnull(
																	SupervisorEndDate
																	, dateadd(
																			dd , 1
																			, datediff(
																						dd, 0
																						, getdate()
																						)
																			)
																	)

)

,	cteAssignedSupervisorFKS
as (
	select		tw.WorkerPK
			, wp.SupervisorFK
	from		#tblWorkers tw
	inner join	WorkerProgram wp on wp.WorkerFK = tw.WorkerPK and wp.ProgramFK = @ProgramFK
)

,	cteAssignedSupervisorsName
as (
	select		SupervisorFK
			, asf.WorkerPK
			, ltrim(rtrim(w.LastName))+', '+ltrim(rtrim(w.FirstName)) as AssignedSupervisorName
	from		cteAssignedSupervisorFKS asf
	left join	Worker w on w.WorkerPK = asf.SupervisorFK
)


-- rspCredentialingSupervisionSummary 1, '06/01/2013', '08/31/2013'

--SELECT * FROM cteAssignedSupervisorsName	

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
	where		SupervisionSessionType = '0'
	)

,	cteSupervisionDurationsGroupedByWeek
as (
	select		WorkerPK
			, sum(Duration) as WeeklyDuration
			, WeekNumber

	from		#tblMaxOf2SupvisionPerWeekToBeConsidered sd
	group by	WorkerPK
			, WeekNumber
)

,	cteSupervisionEvents
as (

	select		wws.WorkerPK
			, WorkerName
			, StartDate
			, EndDate
			, case when SupervisionSessionType = '1' then 'Y' else 'N' end as SupervisionTookPlace
			, SupervisionDate
			, SupervisionHours
			, SupervisionMinutes
			, isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
			, sdg.WeeklyDuration
			, SupervisionSessionType
			, case

				when (SupervisionSessionType = '0') and (StaffOutAllWeek = 1) then 'E' -- Form found in period and reason is “Staff out all week” Note: E = Excused
				when (SupervisionSessionType = '0') and (StaffOutAllWeek <> 1) and (sdg.WeeklyDuration = 0) then 'N' -- Form found in period and reason is not “Staff out all week”				

				when (sdg.WeeklyDuration >= (case when w.FTE = '01' then 90
											when w.FTE = '02' then 60
											when w.FTE = '03' then 15
											else 90 end
											)
					--(case when w.FTEFullTime = null then 90 when w.FTEFullTime = 1 then 90 else 60 end)
					) then 'Y' -- Form found in period and duration is 1:30 or greater 

				when (sdg.WeeklyDuration < (case when w.FTE = '01' then 90
											when w.FTE = '02' then 60
											when w.FTE = '03' then 15
											else 90 end
										)
					--(case when w.FTEFullTime = NULL then 90 when w.FTEFullTime = 1 then 90 else 60 end)
					) and (SupervisionSessionType = '1') then 'N' -- Form found in period and duration less than 1:30

				when (wws.WorkerFK is null and wws.SupervisionPK is NULL AND wl.WorkerLeavePK IS NULL) then 'N' -- Form not found in period
				WHEN wl.WorkerLeavePK IS NOT NULL THEN 'E' -- Form not found in period, but worker was on leave during the period
				end as MeetsStandard

			, case when (SupervisionSessionType = '0') and (StaffOutAllWeek = 1) then 'Staff out all week' -- Form found in period and reason is “Staff out all week” Note: E = Excused
				when (SupervisionSessionType = '0') and (StaffOutAllWeek <> 1) then reason.ReasonNOSupervision -- Form found in period and reason is not “Staff out all week”
				when (isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) >= 90)
					and (SupervisionSessionType = '1') then '' -- Form found in period and duration is 1:30 or greater 
				when (isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) < 90)
					and (SupervisionSessionType = '1') then '' -- Form found in period and duration less than 1:30
				when (wws.WorkerFK is null and wws.SupervisionPK is NULL AND wl.WorkerLeavePK IS NULL) then 'Unknown' -- Form not found in period
				WHEN wl.WorkerLeavePK IS NOT NULL THEN 'Staff on leave' -- Form not found in period, but worker was on leave during the period
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
	left join	cteSupervisionDurationsGroupedByWeek sdg on sdg.WorkerPK = wws.WorkerPK
															and sdg.WeekNumber = wws.WeekNumber
	LEFT JOIN dbo.WorkerLeave wl ON wws.WorkerPK = wl.WorkerFK        -- To fetch the leave records for the worker
					AND (wws.StartDate BETWEEN wl.LeaveStartDate AND wl.LeaveEndDate 
							OR wws.EndDate BETWEEN wl.LeaveStartDate AND wl.LeaveEndDate)
	left join	Worker w on wws.WorkerFK = w.WorkerPK
)


--SELECT * FROM cteSupervisionEvents
--order by workername,weeknumber, SupervisionDate

--	rspCredentialingSupervisionSummary 1, '01/06/2013', '02/02/2013'			

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
		, case when Duration = 0 and MeetsStandard = 'Y' and ReasonSupeVisionNotHeld is not null then
					''
			when DaysInTheCurrentWeek is not null and DaysInTheCurrentWeek < 7 then 'Less Than a Week'
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


,	cteReportDetailsModified
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
			else MeetsStandard end as MeetsStandard1
		, SupervisorName
		, ReasonSupeVisionNotHeld
		, DaysInTheCurrentWeek
		, WeekNumber
		, FirstEvent
		, WorkerPK
	from	cteReportDetails
)

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
,	cteUniqueMeetsStandard
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

,	cteSubSummary
as (
	select		distinct cr.WorkerPK
					, cr.WorkerName
					, asn.AssignedSupervisorName
					, NumOfExpectedSessions
					, NumOfAllowedExecuses
					, NumOfExpectedSessions-NumOfAllowedExecuses as NumOfAdjExptdSupervisions
					, NumOfMeetStandardYes as NumOfAcceptableSupervisions
					, convert(varchar, NumOfMeetStandardYes)+' ('
						+convert(
									varchar
									, round(
											coalesce(
														cast(NumOfMeetStandardYes as float)* 100
														/ nullif((NumOfExpectedSessions
															-NumOfAllowedExecuses
															), 0), 0
													), 0
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
															/ nullif((NumOfExpectedSessions
															-NumOfAllowedExecuses
															), 0), 0
														), 0
											)
									) >= 90 then 3
						when convert(
										varchar
									, round(
												coalesce(
															cast(NumOfMeetStandardYes as float)* 100
															/ nullif((NumOfExpectedSessions
															-NumOfAllowedExecuses
															), 0), 0
														), 0
											)
									) between 75 and 90 then 2
						when convert(
										varchar
									, round(
												coalesce(
															cast(NumOfMeetStandardYes as float)* 100
															/ nullif((NumOfExpectedSessions
															-NumOfAllowedExecuses
															), 0), 0
														), 0
											)
									) < 75 then 1 end as HFARating
	from		cteReport1 cr
	left join	cteScoreByWorker sw on sw.WorkerName = cr.WorkerName
	left join	Worker w on w.WorkerPK = cr.WorkerPK
	left join	cteAssignedSupervisorsName asn on asn.WorkerPK = cr.WorkerPK

)

,	cteCalculateHFABPSRating
as (

	select	case when min(HFARating) = 3 then 3 -- All staff receives 90% or above of expected supervision sessions
			when min(HFARating) = 2 then 2 -- All staff receives 75% or above of expected supervision sessions
			when min(HFARating) = 1 then 1 -- Some staff receives less than 75% of expected supervision sessions
			end as HFABPSRating
	from	cteSubSummary
)

select		ss.WorkerPK
		, ss.WorkerName
		, ss.AssignedSupervisorName
		, ss.NumOfExpectedSessions
		, ss.NumOfAllowedExecuses
		, ss.NumOfAdjExptdSupervisions
		, ss.NumOfAcceptableSupervisions
		, ss.PerctOfAccptbleSupervisions
		, ss.HFARating
		, cc.HFABPSRating
		, twrkr.ScheduledDayName as ScheduledDayName
		, convert(varchar(12), twrkr.sdate, 101) as AdjustedStartDate

		--, w.FTEFullTime AS FTEFullTime
		--, CASE WHEN w.FTEFullTime = 1 THEN 'Full time' ELSE 'Part time' END FTEText

		, w.FTE as FTE
		, case when w.FTE = '01' then 'Full time'
			when w.FTE = '02' then 'Part time (0.25 thru .75)'
			else 'Part time (less than .25)' end FTEText

--, w.FTE AS FTE
--, CASE WHEN w.FTE = '01' THEN 'Full time' 
--	WHEN w.FTE = '02' THEN 'Part Time (.25 thru .75)'
--	WHEN w.FTE = '03' THEN 'Part Time (less than .25)'
--	ELSE 'Unknown' END FTEText



from		cteSubSummary ss
left join	#tblWorkers twrkr on twrkr.WorkerPK = ss.WorkerPK
left join	Worker w on w.WorkerPK = ss.WorkerPK
inner join	cteCalculateHFABPSRating cc on 1 = 1
order by	WorkerName ;

-- rspCredentialingSupervisionSummary 4, '06/01/2013', '08/31/2013'					
-- rspCredentialingSupervisionSummary 1, '07/01/2013', '08/31/2013'		

-- rspCredentialingSupervisionSummary 11, '10/01/2013', '12/31/2013',null,673,null,null
drop table #tblStaff;
drop table #tblSUPPMWorkers ;
drop table #tblWorkers ;
drop table #tblWeekPeriods ;
GO
