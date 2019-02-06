SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure: rspCredentialingSupervisionActivitiesSummary
-- Author:		Devinder Singh Khalsa
-- Create date: January 9th, 2014
-- Description:	Credentialing report for Supervisions Activities Summary

-- All --  rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013'
-- By worker -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,152,null
-- By Supervisor -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,null,null
-- By Supervisor and worker -- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,132,null

-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,152,null,2
-- rspCredentialingSupervisionActivitiesSummary 1, '10/01/2018', '12/31/2018',null,null,null


-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',null,null,5
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervisionActivitiesSummary] @ProgramFK int = null
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


set @sitefk = case when dbo.IsNullOrEmpty(@sitefk) = 1 then 0 else @sitefk end ;


--Step#: 1
-- Get list of all FAW and FSW that belong to the given program
create table #tblStaff (
					WorkerName varchar(100)
				, LastName varchar(50)
				, FirstName varchar(50)
				, TerminationDate datetime
				, WorkerPK int
				, SortOrder int

					) ;

insert into #tblStaff
exec spGetAllWorkersbyProgram @ProgramFK, null, 'FAW,FSW,SUP,PM', null ;

---- Exclude Worker who are SUP and PM from the above list of workers
--	create table #tblSUPPMWorkers(
--		WorkerName varchar(100)
--		,LastName		varchar(50)
--		,FirstName		varchar(50)
--		,TerminationDate datetime
--		,WorkerPK int
--		,SortOrder int

--	)

--insert into #tblSUPPMWorkers
--		exec spGetAllWorkersbyProgram @ProgramFK,null,'SUP,PM', null		


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
					, SupervisorFK int

						) ;

insert into #tblWorkers
select		w.WorkerName
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

from		#tblStaff w
inner join	WorkerProgram wp on wp.WorkerFK = w.WorkerPK
--AND wp.programfk = @ProgramFK
inner join	dbo.fnGetWorkerEventDatesALL(@ProgramFK, null, null) fn on fn.WorkerPK = w.WorkerPK
where
	--w.workerpk not in (SELECT workerpk FROM #tblSUPPMWorkers)
	--and
			fn.FirstEvent <= @eDate -- exclude workers who are probably new and have not activity (visits) yet ... khalsa

			and w.WorkerPK = isnull(@workerfk, w.WorkerPK)
			and wp.SupervisorFK = isnull(@supervisorfk, wp.SupervisorFK)
			--and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
			and (case when @sitefk = 0 then 1 when wp.SiteFK = @sitefk then 1 else 0 end = 1)


order by	w.WorkerName ;


--SELECT * FROM #tblWorkers

-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,132,null



-- getting workername and supervisorname
-- we need them for the report	
declare @WorkerName varchar(100) = null ;
declare @SupervisorName varchar(100) = null ;

set @WorkerName = (select WorkerName from #tblWorkers where WorkerPK = @workerfk) ;
set @SupervisorName = (
					select		ltrim(rtrim(LastName))+', '+ltrim(rtrim(FirstName)) as SupervisorName
					from		Worker w
					inner join	WorkerProgram wp on wp.WorkerFK = w.WorkerPK
					where		ProgramFK = @ProgramFK
								and current_Timestamp between SupervisorStartDate and isnull(
																					SupervisorEndDate
																					, dateadd(
																							dd
																							, 1
																							, datediff (
																										dd
																										, 0
																										, getdate()
																										)
																							)
																					)
								and WorkerPK = @supervisorfk
					) ;

--if (@SupervisorName is null and @workerfk is not null)

--begin
--set @SupervisorName = (select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as SupervisorName 
--		from Worker w
--		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
--		where programfk = @ProgramFK 
--				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
--	and	WorkerPK = (select SupervisorFK from WorkerProgram where WorkerFK = @workerfk))	
--end

--select @SupervisorName, @WorkerName

-- set them blank if null ( our report ui does like nulls)	
if @SupervisorName is null begin
set @SupervisorName = '' ;
end ;
else begin
	set @SupervisorName = 'Supervisor Name: '+@SupervisorName ;
end ;



if @WorkerName is null begin
set @WorkerName = '' ;
end ;
else begin
	set @WorkerName = 'Worker Name: '+@WorkerName ;
	set @SupervisorName = '' ; -- There may be more than one supervisor for a worker, so no sup name
end ;


-- for display in the same field, @SupervisorName and @WorkerName are Mutually Exclusive
if @SupervisorName = '' and @WorkerName <> '' begin
	set @SupervisorName = @WorkerName ;
	set @WorkerName = '' ;
end ;





create table #tblWorkerAndSupName (WorkerName varchar(100), SupervisorName varchar(100)

) ;

insert into #tblWorkerAndSupName select @WorkerName, @SupervisorName ;

--SELECT workerpk FROM #tblSUPPMWorkers
--SELECT * FROM #tblWorkers


-- rspCredentialingSupervisionActivitiesSummary 1, '01/06/2013', '02/02/2013',15,152		
-- rspCredentialingSupervisionActivitiesSummary 1, '03/01/2013', '03/31/2013'		

--Step#: 2
-- use a recursive CTE to generate the list of dates  ... Khalsa
-- Given any startdate, find all week dates starting with that date and less then the end date
-- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes


create table #tblWeekPeriods (WeekNumber int, StartDate datetime, EndDate datetime

)


;
with cteGenerateWeeksGiven2Dates
as (
	select 1 as WeekNumber, @sDate StartDate, dateadd(d, 6, @sDate) EndDate

	union all

	select	WeekNumber+1 as WeekNumber
		, dateadd(d, 7, StartDate) as StartDate
		, dateadd(d, 7, EndDate) as EndDate


	from	cteGenerateWeeksGiven2Dates


	where	dateadd(d, 6, StartDate) <= @eDate

)



insert into #tblWeekPeriods select * from cteGenerateWeeksGiven2Dates ;



------ We are only interested in each week's start date
------ These are all the weeks between given two dates but at the end we added user given @eDate ... khalsa


-- insert user's enddate at the end for the last period
update	#tblWeekPeriods
set		EndDate = @eDate
where	WeekNumber = (select top 1 WeekNumber from #tblWeekPeriods order by WeekNumber desc) ;


--Note: Don't delete the following SELECT
--SELECT 
--	WeekNumber
--	,StartDate
--	,EndDate
--	,datediff(day, StartDate,EndDate) as DaysInTheCurrentWeek			
--FROM #tblWeekPeriods	



--	 rspCredentialingSupervisionActivitiesSummary 1, '04/01/2013', '04/30/2013'		

--		SELECT * FROM #tblWorkers
--		where WorkerPK = 152  -- worker: Burdick, Catherine


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
		, WorkerPK
from		#tblWeekPeriods
inner join	#tblWorkers w on FirstEvent < StartDate



----		-- Step#: 3
----		-- Now let us develop the report. We will use the above 2 temp tables now

;

-- Part 1: Supervision sessions that did not take place with a reason	

-- Supervision sessions that took place
with cteSupervisionsThatTookPlace
as (
	select

				wp.WeekNumber
			, wp.StartDate
			, wp.EndDate
			, wp.FirstEvent
			, wp.WorkerPK

			, isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
			, case when (isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0)) >= 90 then 1
				else 0 end as SupTimeGreaterThan90Mins




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
			, ParticipantEmergency
			, ReasonOther
			, ReasonOtherSpecify
			, ShortWeek
			, StaffCourt
			, StaffFamilyEmergency
			, StaffForgot
			, StaffIll
			, StaffTraining
			, StaffVacation
			, StaffOutAllWeek
			, SupervisionCreateDate
			, SupervisionCreator
			, SupervisionDate
			, SupervisionEditDate
			, SupervisionEditor
			, SupervisionEndTime
			, SupervisionHours
			, SupervisionMinutes
			, SupervisionNotes
			, SupervisionStartTime
			, SupervisorFamilyEmergency
			, SupervisorForgot
			, SupervisorHoliday
			, SupervisorIll
			, SupervisorTraining
			, SupervisorVacation
			, SupervisionSessionType
			--,TechniquesApproaches
			--,Tools
			--,TrainingNeeds
			, Weather
			, WorkerFK
			-- note: we added 1 in datediff(d, StartDate,EndDate) because substraction gives one day less. e.g. 7-1 = 6			
			, datediff(d, StartDate, EndDate)+1 as DaysInTheCurrentWeek -- null means that there was no supervision record found for that week  ... khalsa		  
	--,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek	-- null means that there was no supervision record found for that week  ... khalsa		  

	from		#tblWeekPeriodsAdjusted wp
	--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
	left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
	left join	Supervision s on s.WorkerFK = w.WorkerPK
								and SupervisionDate between StartDate and EndDate
	where		SupervisionPK is not null and s.SupervisionSessionType = '1'
)



--SELECT * FROM cteSupervisionsThatTookPlace
--SELECT * FROM cteSupervisionsThatDidNotTakePlace

-- Supervision sessions that took place
, cteSupervisionsThatTookPlaceActivities
as (
	select

				count(*) as NumOfTotalSupervisions
			, sum(convert(int, s.Boundaries)) as Boundaries
			, sum(convert(int, s.Caseload)) as Caseload
			, sum(convert(int, s.Coaching)) as Coaching
			, sum(convert(int, s.CPS)) as CPS
			, sum(convert(int, s.Curriculum)) as Curriculum
			, sum(convert(int, s.FamilyReview)) as FamilyReview
			, sum(convert(int, s.ImpactOfWork)) as ImpactOfWork
			, sum(convert(int, s.ImplementTraining)) as ImplementTraining
			, sum(convert(int, s.Outreach)) as Outreach
			, sum(convert(int, s.Personnel)) as Personnel
			, sum(convert(int, s.PIP)) as PIP
			, sum(convert(int, s.ProfessionalGrowth)) as ProfessionalGrowth
			, sum(convert(int, s.RecordDocumentation)) as RecordDocumentation
			, sum(convert(int, s.Retention)) as Retention
			, sum(convert(int, s.RolePlaying)) as RolePlaying
			, sum(convert(int, s.Safety)) as Safety
			, sum(convert(int, s.SiteDocumentation)) as SiteDocumentation
			, sum(convert(int, s.Strengths)) as Strengths
			, sum(convert(int, s.SupervisorObservationAssessment)) as SupervisorObservationAssessment
			, sum(convert(int, s.SupervisorObservationHomeVisit)) as SupervisorObservationHomeVisit
			, sum(convert(int, s.SupervisorObservationSupervision)) as SupervisorObservationSupervision
			, sum(convert(int, s.SupportHFAModel)) as SupportHFAModel
			, sum(convert(int, s.TeamDevelopment)) as TeamDevelopment
			, sum(convert(int, s.WorkplaceEnvironment)) as WorkplaceEnvironment


	--, sum(convert(int, AssessmentIssues)) as AssessmentIssues
	--, sum(convert(int, IFSP)) as IFSP
	--, sum(convert(int, FamilyProgress)) as FamilyProgress
	--, sum(convert(int, Tools)) as Tools
	--, sum(convert(int, Referrals)) as Referrals
	--, sum(convert(int, CommunityResources)) as CommunityResources
	--, sum(convert(int, Coaching)) as Coaching
	--, sum(convert(int, StrengthBasedApproach)) as StrengthBasedApproach
	--, sum(convert(int, LevelChange)) as LevelChange
	--, sum(convert(int, Caseload)) as Caseload
	--, sum(convert(int, HomeVisitRate)) as HomeVisitRate
	--, sum(convert(int, AssessmentRate)) as AssessmentRate
	--, sum(convert(int, Retention)) as Retention
	--, sum(convert(int, HomeVisitLogActivities)) as HomeVisitLogActivities
	--, sum(convert(int, RecordDocumentation)) as RecordDocumentation
	--, sum(convert(int, Outreach)) as Outreach
	--, sum(convert(int, Safety)) as Safety
	--, sum(convert(int, SupervisorObservationHomeVisit)) as SupervisorObservationHomeVisit
	--, sum(convert(int, SupervisorObservationAssessment)) as SupervisorObservationAssessment
	--, sum(convert(int, ImplementTraining)) as ImplementTraining
	--, sum(convert(int, CulturalSensitivity)) as CulturalSensitivity
	--, sum(convert(int, Curriculum)) as Curriculum
	--, sum(convert(int, TechniquesApproaches)) as TechniquesApproaches
	--, sum(convert(int, AreasGrowth)) as AreasGrowth
	--, sum(convert(int, Strengths)) as Strengths
	--, sum(convert(int, Boundaries)) as Boundaries
	--, sum(convert(int, ProfessionalGrowth)) as ProfessionalGrowth
	--, sum(convert(int, PersonalGrowth)) as PersonalGrowth
	--, sum(convert(int, TrainingNeeds)) as TrainingNeeds
	--, sum(convert(int, RolePlaying)) as RolePlaying
	--, sum(convert(int, ActivitiesOther)) as ActivitiesOther


	from		#tblWeekPeriodsAdjusted wp
	--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
	left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
	left join	Supervision s on s.WorkerFK = w.WorkerPK
								and SupervisionDate between StartDate and EndDate
	where		SupervisionPK is not null and SupervisionSessionType = '1'
)


,	cteSupervisionsThatTookPlacePercActivities
as (
	select	NumOfTotalSupervisions
		, convert(varchar, Boundaries)+' (' +
			convert(varchar, round(coalesce(cast(Boundaries as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfBoundaries
		, convert(varchar, Caseload)+' (' +
			convert(varchar, round(coalesce(cast(Caseload as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) + 
			'%)' as PercOfCaseload
		, convert(varchar(12), Coaching) + ' (' +
			convert(varchar(12), round(coalesce(cast(Coaching as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfCoaching
		, convert(varchar(12), CPS) + ' (' +
			convert(varchar(12), round(coalesce(cast(CPS as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfCPS
		, convert(varchar(12), Curriculum) + ' (' +
			convert(varchar(12), round(coalesce(cast(Curriculum as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfCurriculum
		, convert(varchar(12), FamilyReview) + ' (' +
			convert(varchar(12), round(coalesce(cast(FamilyReview as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfFamilyReview
		, convert(varchar(12), ImpactOfWork) + ' (' +
			convert(varchar(12), round(coalesce(cast(ImpactOfWork as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfImpactOfWork
		, convert(varchar(12), ImplementTraining) + ' (' +
			convert(varchar(12), round(coalesce(cast(ImplementTraining as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfImplementTraining
		, convert(varchar(12), Outreach) + ' (' +
			convert(varchar(12), round(coalesce(cast(Outreach as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfOutreach
		, convert(varchar(12), Personnel) + ' (' +
			convert(varchar(12), round(coalesce(cast(Personnel as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfPersonnel
		, convert(varchar(12), PIP) + ' (' +
			convert(varchar(12), round(coalesce(cast(PIP as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfPIP
		, convert(varchar(12), ProfessionalGrowth) + ' (' +
			convert(varchar(12), round(coalesce(cast(ProfessionalGrowth as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfProfessionalGrowth
		, convert(varchar(12), RecordDocumentation) + ' (' +
			convert(varchar(12), round(coalesce(cast(RecordDocumentation as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfRecordDocumentation
		, convert(varchar(12), Retention) + ' (' +
			convert(varchar(12), round(coalesce(cast(Retention as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfRetention
		, convert(varchar(12), RolePlaying) + ' (' +
			convert(varchar(12), round(coalesce(cast(RolePlaying as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfRolePlaying
		, convert(varchar(12), Safety) + ' (' +
			convert(varchar(12), round(coalesce(cast(Safety as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSafety
		, convert(varchar(12), SiteDocumentation) + ' (' +
			convert(varchar(12), round(coalesce(cast(SiteDocumentation as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSiteDocumentation
		, convert(varchar(12), Strengths) + ' (' +
			convert(varchar(12), round(coalesce(cast(Strengths as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfStrengths
		, convert(varchar(12), SupervisorObservationAssessment) + ' (' +
			convert(varchar(12), round(coalesce(cast(SupervisorObservationAssessment as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSupervisorObservationAssessment
		, convert(varchar(12), SupervisorObservationHomeVisit) + ' (' +
			convert(varchar(12), round(coalesce(cast(SupervisorObservationHomeVisit as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSupervisorObservationHomeVisit
		, convert(varchar(12), SupervisorObservationSupervision) + ' (' +
			convert(varchar(12), round(coalesce(cast(SupervisorObservationSupervision as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSupervisorObservationSupervision
		, convert(varchar(12), SupportHFAModel) + ' (' +
			convert(varchar(12), round(coalesce(cast(SupportHFAModel as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfSupportHFAModel
		, convert(varchar(12), TeamDevelopment) + ' (' +
			convert(varchar(12), round(coalesce(cast(TeamDevelopment as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfTeamDevelopment
		, convert(varchar(12), WorkplaceEnvironment) + ' (' +
			convert(varchar(12), round(coalesce(cast(WorkplaceEnvironment as float) * 100
									/ nullif(NumOfTotalSupervisions, 0), 0), 0)) +
			'%)' as PercOfWorkplaceEnvironment

	--, convert(varchar, AssessmentIssues)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(AssessmentIssues as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfAssessmentIssues
	--, convert(varchar, IFSP)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(IFSP as float)* 100 / nullif(NumOfTotalSupervisions, 0)
	--							, 0
	--							)	, 0
	--					)
	--			)+'%)' as PercOfIFSP
	--, convert(varchar, FamilyProgress)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(FamilyProgress as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfFamilyProgress
	--, convert(varchar, Tools)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Tools as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfTools
	--, convert(varchar, Referrals)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Referrals as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfReferrals
	--, convert(varchar, CommunityResources)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(CommunityResources as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfCommunityResources
	--, convert(varchar, Coaching)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Coaching as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfCoaching
	--, convert(varchar, StrengthBasedApproach)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(StrengthBasedApproach as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfStrengthBasedApproach
	--, convert(varchar, LevelChange)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(LevelChange as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfLevelChange
	--, convert(varchar, Caseload)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Caseload as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfCaseload
	--, convert(varchar, HomeVisitRate)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(HomeVisitRate as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfHomeVisitRate
	--, convert(varchar, AssessmentRate)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(AssessmentRate as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfAssessmentRate
	--, convert(varchar, Retention)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Retention as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfRetention
	--, convert(varchar, HomeVisitLogActivities)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(HomeVisitLogActivities as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfHomeVisitLogActivities
	--, convert(varchar, RecordDocumentation)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(RecordDocumentation as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfRecordDocumentation
	--, convert(varchar, Outreach)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Outreach as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfOutreach

	--, convert(varchar, Safety)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Safety as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfSafety
	--, convert(varchar, SupervisorObservationHomeVisit)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(SupervisorObservationHomeVisit as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfSupervisorObservationHomeVisit
	--, convert(varchar, SupervisorObservationAssessment)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(SupervisorObservationAssessment as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfSupervisorObservationAssessment
	--, convert(varchar, ImplementTraining)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(ImplementTraining as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfImplementTraining
	--, convert(varchar, CulturalSensitivity)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(CulturalSensitivity as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfCulturalSensitivity
	--, convert(varchar, Curriculum)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Curriculum as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfCurriculum
	--, convert(varchar, TechniquesApproaches)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(TechniquesApproaches as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfTechniquesApproaches
	--, convert(varchar, AreasGrowth)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(AreasGrowth as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfAreasGrowth
	--, convert(varchar, Strengths)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Strengths as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfStrengths
	--, convert(varchar, Boundaries)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(Boundaries as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfBoundaries
	--, convert(varchar, ProfessionalGrowth)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(ProfessionalGrowth as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfProfessionalGrowth
	--, convert(varchar, PersonalGrowth)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(PersonalGrowth as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfPersonalGrowth
	--, convert(varchar, TrainingNeeds)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(TrainingNeeds as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfTrainingNeeds
	--, convert(varchar, RolePlaying)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--							cast(RolePlaying as float)* 100
	--							/ nullif(NumOfTotalSupervisions, 0), 0
	--							), 0
	--					)
	--			)+'%)' as PercOfRolePlaying
	--, convert(varchar, ActivitiesOther)+' ('
	--	+convert(
	--				varchar
	--			, round(
	--						coalesce(
	--									cast(ActivitiesOther as float)* 100
	--									/ nullif(NumOfTotalSupervisions, 0), 0
	--								), 0
	--					)
	--			)+'%)' as PercOfActivitiesOther




	from	cteSupervisionsThatTookPlaceActivities

)

---- to show list of the other activities
--, cteSupervisionsThatTookPlaceActivitiesOther
--as (
--	select

--				ActivitiesOtherSpecify


--	from		#tblWeekPeriodsAdjusted wp
--	--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
--	left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
--	left join	Supervision s on s.WorkerFK = w.WorkerPK
--								and SupervisionDate between StartDate and EndDate
--	where		SupervisionPK is not null and SupervisionSessionType = '1' and ActivitiesOther = 1
--)


--SELECT * FROM cteSupervisionsThatTookPlaceActivitiesOther


, cteReportHeaderStatistics
as (
	select

			convert(varchar, sum(SupTimeGreaterThan90Mins))+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(sum(SupTimeGreaterThan90Mins) as float)* 100
											/ nullif(count(*), 0), 0
										), 0
							)
					)+'%)' as PerCOfSupGreaterThanEQTo90Mins
		, convert(varchar, count(*)-sum(SupTimeGreaterThan90Mins))+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(count(*)-sum(SupTimeGreaterThan90Mins) as float)* 100
											/ nullif(count(*), 0), 0
										), 0
							)
					)+'%)' as PerCOfSupLessThan90Mins


		--,sum(Duration) / count(*)  as AverageDuration
		, cast(((sum(Duration)/ count(*)) / 60) as varchar(8))+':'
			+right('0'+cast(((sum(Duration)/ count(*)) % 60) as varchar(2)), 2) as AverageLenOfSupervision
		--, case -- convert to string
		--	when SupervisionHours > 0 and SupervisionMinutes > 0 then
		--		convert(varchar(10), SupervisionHours) + 
		--		':' + 
		--		case when SupervisionMinutes < 10
		--				then '0' 
		--				else ''
		--		end + trim(convert(varchar(2), SupervisionMinutes))
		--	when SupervisionHours > 0 and (SupervisionMinutes = 0 or 
		--			SupervisionMinutes is null) then
		--		convert(varchar(10), SupervisionHours)+':00'
		--	when (SupervisionHours = 0 or SupervisionHours is null) and 
		--			SupervisionMinutes > 0 then
		--		'0:' + 
		--		case when SupervisionMinutes < 10
		--				then '0' 
		--				else ''
		--		end + trim(convert(varchar(2), SupervisionMinutes))			
		--	else ' ' 
		--end 
		--as AverageLenOfSupervision


	from	cteSupervisionsThatTookPlace s
)

--SELECT * FROM cteReportHeaderStatistics, cteSupervisionsThatTookPlacePercActivities
--SELECT * FROM cteSupervisionsThatTookPlacePercActivities


-- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013'


-- Part 2: Supervision sessions that did not take place with a reason	

-- Supervision sessions that did not take place with a reason
, cteSupervisionsThatDidNotTakePlace
as (
	select

				wp.WeekNumber
			, wp.StartDate
			, wp.EndDate
			, wp.FirstEvent
			, wp.WorkerPK

			, isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
			, case when (isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0)) >= 90 then 1
				else 0 end as SupTimeGreaterThan90Mins

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
	where		SupervisionPK is not null and SupervisionSessionType = '0'
)



-- Supervision sessions that took place
, cteSupervisionsThatDidNotTakePlaceWithReason
as (
	select

				count(*) as NumOfTotalSupervisionsNotTookPlace



			, sum(convert(int, ParticipantEmergency)) as ParticipantEmergency
			, sum(convert(int, ShortWeek)) as ShortWeek
			, sum(convert(int, StaffCourt)) as StaffCourt
			, sum(convert(int, StaffFamilyEmergency)) as StaffFamilyEmergency
			, sum(convert(int, StaffForgot)) as StaffForgot
			, sum(convert(int, StaffIll)) as StaffIll
			, sum(convert(int, StaffTraining)) as StaffTraining
			, sum(convert(int, StaffVacation)) as StaffVacation
			, sum(convert(int, StaffOutAllWeek)) as StaffOutAllWeek
			, sum(convert(int, SupervisorFamilyEmergency)) as SupervisorFamilyEmergency
			, sum(convert(int, SupervisorForgot)) as SupervisorForgot
			, sum(convert(int, SupervisorHoliday)) as SupervisorHoliday
			, sum(convert(int, SupervisorIll)) as SupervisorIll
			, sum(convert(int, SupervisorTraining)) as SupervisorTraining
			, sum(convert(int, SupervisorVacation)) as SupervisorVacation
			, sum(convert(int, ReasonOther)) as ReasonOther
			, sum(convert(int, Weather)) as Weather


	from		#tblWeekPeriodsAdjusted wp
	--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
	left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
	left join	Supervision s on s.WorkerFK = w.WorkerPK
								and SupervisionDate between StartDate and EndDate
	where		SupervisionPK is not null and SupervisionSessionType = '0'
)


,	cteSupervisionsThatDidNotTakePlacePercActivities
as (
	select	NumOfTotalSupervisionsNotTookPlace as OtherNumOfTotalSupervisionsNotTookPlace
		, convert(varchar, ParticipantEmergency)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(ParticipantEmergency as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfParticipantEmergency
		, convert(varchar, ShortWeek)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(ShortWeek as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfShortWeek
		, convert(varchar, StaffCourt)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffCourt as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffCourt
		, convert(varchar, StaffFamilyEmergency)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffFamilyEmergency as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffFamilyEmergency
		, convert(varchar, StaffForgot)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffForgot as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffForgot
		, convert(varchar, StaffIll)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffIll as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffIll
		, convert(varchar, StaffTraining)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffTraining as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffTraining
		, convert(varchar, StaffVacation)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffVacation as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffVacation
		, convert(varchar, StaffOutAllWeek)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(StaffOutAllWeek as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfStaffOutAllWeek
		, convert(varchar, SupervisorFamilyEmergency)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorFamilyEmergency as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorFamilyEmergency
		, convert(varchar, SupervisorForgot)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorForgot as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorForgot
		, convert(varchar, SupervisorHoliday)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorHoliday as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorHoliday
		, convert(varchar, SupervisorIll)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorIll as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorIll
		, convert(varchar, SupervisorTraining)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorTraining as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorTraining
		, convert(varchar, SupervisorVacation)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(SupervisorVacation as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfSupervisorVacation
		, convert(varchar, ReasonOther)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(ReasonOther as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfReasonOther
		, convert(varchar, Weather)+' ('
			+convert(
						varchar
					, round(
								coalesce(
											cast(Weather as float)* 100
											/ nullif(NumOfTotalSupervisionsNotTookPlace, 0), 0
										), 0
							)
					)+'%)' as OtherPercOfWeather



	from	cteSupervisionsThatDidNotTakePlaceWithReason

)


-- to show list of the other reasons
, cteSupervisionsThatDidNotTakePlaceWithReasonOther
as (
	select

				ReasonOtherSpecify


	from		#tblWeekPeriodsAdjusted wp
	--left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
	left join	#tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
	left join	Supervision s on s.WorkerFK = w.WorkerPK
								and SupervisionDate between StartDate and EndDate
	where		SupervisionPK is not null and SupervisionSessionType = '0' and ReasonOther = 1
)


--SELECT * FROM cteSupervisionsThatDidNotTakePlaceWithReasonOther


----SELECT * FROM cteSupervisionsThatDidNotTakePlacePercActivities
----SELECT workerpk FROM #tblSUPPMWorkers


select	PercOfSupGreaterThanEQTo90Mins
		, PercOfSupLessThan90Mins
		, AverageLenOfSupervision
		, NumOfTotalSupervisions
		, PercOfBoundaries
		, PercOfCaseload
		, PercOfCoaching
		, PercOfCPS
		, PercOfCurriculum
		, PercOfFamilyReview
		, PercOfImpactOfWork
		, PercOfImplementTraining
		, PercOfOutreach
		, PercOfPersonnel
		, PercOfPIP
		, PercOfProfessionalGrowth
		, PercOfRecordDocumentation
		, PercOfRetention
		, PercOfRolePlaying
		, PercOfSafety
		, PercOfSiteDocumentation
		, PercOfStrengths
		, PercOfSupervisorObservationAssessment
		, PercOfSupervisorObservationHomeVisit
		, PercOfSupervisorObservationSupervision
		, PercOfSupportHFAModel
		, PercOfTeamDevelopment
		, PercOfWorkplaceEnvironment
		, OtherNumOfTotalSupervisionsNotTookPlace
		, OtherPercOfParticipantEmergency
		, OtherPercOfShortWeek
		, OtherPercOfStaffCourt
		, OtherPercOfStaffFamilyEmergency
		, OtherPercOfStaffForgot
		, OtherPercOfStaffIll
		, OtherPercOfStaffTraining
		, OtherPercOfStaffVacation
		, OtherPercOfStaffOutAllWeek
		, OtherPercOfSupervisorFamilyEmergency
		, OtherPercOfSupervisorForgot
		, OtherPercOfSupervisorHoliday
		, OtherPercOfSupervisorIll
		, OtherPercOfSupervisorTraining
		, OtherPercOfSupervisorVacation
		, OtherPercOfReasonOther
		, OtherPercOfWeather
		, WorkerName
		, SupervisorName
from	cteReportHeaderStatistics
	, cteSupervisionsThatTookPlacePercActivities
	, cteSupervisionsThatDidNotTakePlacePercActivities
	, #tblWorkerAndSupName ;
--left join cteSupervisionsThatTookPlaceActivitiesOther ss on 1=1

--SELECT * FROM cteSupervisionsThatDidNotTakePlacePercActivities

--ToDo: Also print out the other activities and reasons ... Khalsa

---- rspCredentialingSupervisionActivitiesSummary 1, '06/01/2013', '08/31/2013',15,null,null
---- rspCredentialingSupervisionActivitiesSummary 31, '06/01/2013', '08/31/2013'

---- rspCredentialingSupervisionActivitiesSummary 1, '10/01/2013', '12/31/2013',null,152,null,2


drop table #tblStaff ;
--drop table #tblSUPPMWorkers
drop table #tblWorkers ;
drop table #tblWeekPeriods ;
drop table #tblWorkerAndSupName ;
GO
