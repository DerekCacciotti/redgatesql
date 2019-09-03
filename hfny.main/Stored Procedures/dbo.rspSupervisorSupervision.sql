SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure: rspSupervisorSupervision
-- Author:      jayrobot
-- Create date: 08/28/2019
-- Description: Credentialing report for Supervisors' Supervisions

-- rspCredentialingSupervisorSupervision 1, '06/01/2013', '08/31/2013', null, 5
-- =============================================
CREATE procedure [dbo].[rspSupervisorSupervision] 
    (@ProgramFK int = null
        , @StartDate datetime = null
        , @EndDate datetime = null
        , @SupervisorFK int = null
        , @SiteFK int = null
    )
as

begin
    set noCount on ;

    if 1 = 0 
        begin
            set fmtOnly off ;
        end ;

    set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end ;

    -- Get list of all Supervisors that belong to the given program
    create table #tblStaff (
                        WorkerName varchar(100)
                    , LastName varchar(50)
                    , FirstName varchar(50)
                    , TerminationDate datetime
                    , WorkerPK int
                    , SortOrder bit
                        ) ;

    insert into #tblStaff
		exec spGetAllWorkersbyProgram @ProgramFK, null, 'SUP', null ;

    -- Exclude Worker who are SUP and PM from the above list of workers
    create table #tblPMWorkers (
                                WorkerName  varchar(100)
                            , LastName varchar(50)
                            , FirstName varchar(50)
                            , TerminationDate datetime
                            , WorkerPK int
                            , SortOrder bit
                                ) ;

    insert into #tblPMWorkers
		exec spGetAllWorkersbyProgram @ProgramFK, null, 'PM', null ;

    -- List of staff with worker/event info
    create table #tblWorkers (
                            WorkerName  varchar(100)
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
                        , StartDate datetime
                        , EndDate datetime
                        , FTE char(2)
                            ) ;

    insert into #tblWorkers (
                                WorkerName
                                , LastName
                                , FirstName
                                , TerminationDate
                                , WorkerPK
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
                                , FirstEvent
                                , SupervisionScheduledDay
                                , ScheduledDayName
                                , StartDate
                                , EndDate
                                , FTE
                            )
    select      w.WorkerName
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
                                                    ,   (isnull(
                                                    wrkr.SupervisionScheduledDay
                                                    , datepart(weekday, @StartDate)
                                                    )-datepart(weekday, @StartDate)
                                                    ), @StartDate
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
            --,dateadd(day,(isnull(wrkr.SupervisionScheduledDay,DATEPART(weekday,@StartDate)) - DATEPART(weekday,@StartDate)), @StartDate) as StartDate
            -- Note: given StartDate = 10/01/13 (i.e. Tuesday)and DayOfWeekSupScheduled = 2 (i.e. Monday) FIND the next monday (10/07/13) which will be in the first week period
            --       else if DayOfWeekSupScheduled >= weekday of StartDate then FIND the date of DayOfWeekSupScheduled from StartDate

            , case when (isnull(wrkr.SupervisionScheduledDay, datepart(weekday, @StartDate))
                        -datepart(weekday, @StartDate)
                        ) < 0 then
                        dateadd(
                                    day, 7
                                , dateadd(
                                            day
                                            ,   (isnull(
                                                wrkr.SupervisionScheduledDay
                                                , datepart(weekday, @StartDate)
                                                )-datepart(weekday, @StartDate)
                                            ), @StartDate
                                        )
                                )
                else
                    dateadd(
                            day
                            ,   (isnull(wrkr.SupervisionScheduledDay, datepart(weekday, @StartDate))
                                -datepart(weekday, @StartDate)
                            ), @StartDate
                        ) end as StartDate
            , @EndDate as EndDate
            , wrkr.FTE
    from        #tblStaff w
    inner join  WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = @ProgramFK
    inner join  dbo.fnGetWorkerEventDatesALL(@ProgramFK, null, null) fn on fn.WorkerPK = w.WorkerPK
    left join   Worker wrkr on w.WorkerPK = wrkr.WorkerPK -- bring in SupervisionScheduledDay
    where       w.WorkerPK not in (select WorkerPK from #tblPMWorkers)
                and fn.FirstEvent <= @EndDate -- exclude workers who have not yet worked with families
                and w.WorkerPK = isnull(@SupervisorFK, wp.WorkerFK)
                and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
                --and wrkr.FTE <> '03'
    order by    w.WorkerName ;
            
    -- select * from #tblWorkers tw

    -- define window for permanent case count status    
    declare @StartWindowDate date
            , @EndWindowDate date
    set @EndWindowDate = @EndDate
    set @StartWindowDate = dateadd(month, -3, @EndWindowDate)
    
    create table #tblCaseStats
            (WorkerPK int
                , CaseCount int
                , MostFrequentVisit numeric(5, 2)
                , RequiredSupervisions int
                , RequiredWeeklyMinutes int
            )
    insert into #tblCaseStats (WorkerPK
                                , CaseCount
                                , MostFrequentVisit
                                , RequiredSupervisions
                                , RequiredWeeklyMinutes
                                )
    select tw.WorkerPK
            , gwcs.CaseCount
            , gwcs.MostFrequentVisitCount
            , round(((datediff(day, @StartDate, @EndDate) + 1) / 7 )
                * gwcs.MostFrequentVisitCount, 0) as RequiredSupervisions
            , case FTE when '01' then 90
                    when '02' then 60
                    when '03' then 15
                    else 90
                end as RequiredWeeklyMinutes
    from #tblWorkers tw
    left outer join dbo.GetWorkerCaseStats(@ProgramFK
                                    , @StartWindowDate
                                    , @EndWindowDate) gwcs
                on gwcs.WorkerPK = tw.WorkerPK
            
    -- select * from #tblCaseStats tcs

    -- RESET the startdate if firstevent date falls between @StartDate and @EndDate
    --declare @FirstEventDate   datetime    
    --set @FirstEventDate = (select * from #tblWorkers)

    --Step#: 2
    -- use a recursive CTE to generate the list of dates  ... Khalsa
    -- Given any startdate, find all week dates starting with that date and less then the end date
    -- We need these dates to figure out if a given worker was supervised in each of the week within startdate and enddate for credentialing purposes
    create table #tblWeekPeriods (WorkerPK int, WeekNumber int, StartDate datetime, EndDate datetime)

    ;
    with cteGenerateWeeks
    as (

        select  WorkerPK
            , 1 as WeekNumber
            , StartDate as StartDate
            , dateadd(d, 6, StartDate) EndDate
        from    #tblWorkers
        union all
        select  WorkerPK
            , WeekNumber+1 as WeekNumber
            , dateadd(d, 7, StartDate) as StartDate
            , dateadd(d, 7, EndDate) as EndDate
        from    cteGenerateWeeks
        where   dateadd(d, 6, StartDate) < @EndDate
    )
    --SELECT * FROM cteGenerateWeeks
    --order by workerpk 

    insert into #tblWeekPeriods select * from cteGenerateWeeks ;

    -- We are only interested in each week's start date
    -- These are all the weeks between start and end date
    -- with one row at the end for @EndDate

    -- insert user's enddate at the end for the last period
    --update #tblWeekPeriods
    --set EndDate = @EndDate
    --where WeekNumber = (select top 1 WeekNumber from #tblWeekPeriods order by WeekNumber desc)
    -- fix jr 2014-10-02 the above update only updated all groups for the highest WeekNumber across all groups
    --                   it needs to grab the highest WeekNumber by worker, which is what this now does
    update      #tblWeekPeriods
    set         EndDate = @EndDate
    from        #tblWeekPeriods wp
    inner join  (
                select      WorkerPK
                        , max(WeekNumber) as LatestWeek
                from        #tblWeekPeriods
                group by    WorkerPK
                ) wp2 on wp2.WorkerPK = wp.WorkerPK and wp.WeekNumber = wp2.LatestWeek ;

    --SELECT * FROM #tblWeekPeriods
    --where workerpk = 152
    --order by workerpk

    -- Make sure that the worker's firstevent date falls between 
    -- start and end dates and then adjust number of weeks for 
    -- that worker. 
    create table #tblWeekPeriodsAdjusted (
                                        WeekNumber  int
                                    , StartDate datetime
                                    , EndDate datetime
                                    , FirstEvent datetime
                                    , WorkerPK int
                                        ) ;

    insert into #tblWeekPeriodsAdjusted
    select      WeekNumber
            , wp.StartDate
            , wp.EndDate
            , FirstEvent
            , wp.WorkerPK
    from        #tblWeekPeriods wp
    inner join  #tblWorkers w on FirstEvent < wp.StartDate and wp.WorkerPK = w.WorkerPK ;

    --SELECT * FROM #tblWeekPeriodsAdjusted
    ----where workerpk = 152
    --order by workerpk      

    ------      --Note: Don't delete the following SELECT
    ------      --SELECT 
    ------      --  WeekNumber
    ------      --  ,StartDate
    ------      --  ,EndDate
    ------      --  ,datediff(day, StartDate,EndDate) as DaysInTheCurrentWeek           
    ------      --FROM #tblWeekPeriods  

    --          max of 2 supervisions per week ... khalsa
    create table #tblMaxOf2SupervisionsPerWeek (WorkerPK int, Duration int, WeekNumber int, rownum int) ;

    with cteWorkersWithSupervisions
    as (
        select      wp.WeekNumber
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
                , isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
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
                , datediff(d, wp.StartDate, wp.EndDate)+1 as DaysInTheCurrentWeek -- null means that there was no supervision record found for that week  ... khalsa          
        --,case when WorkerFK is null and SupervisionPK is null then null else datediff(d, StartDate,EndDate) end as DaysInTheCurrentWeek   -- null means that there was no supervision record found for that week  ... khalsa        

        from        #tblWeekPeriodsAdjusted wp
        --left join #tblWorkers w on 1=1  -- We need to know if supervision event in any week is missing
        left join   #tblWorkers w on w.WorkerPK = wp.WorkerPK -- include only those weeks where worker performed supervisions. 
        left join   Supervision s on s.WorkerFK = w.WorkerPK
                                    and SupervisionDate between wp.StartDate and wp.EndDate
    )

    --SELECT * FROM cteWorkersWithSupervisions
    --order by workername,weeknumber, SupervisionDate

    , cteSupervisors
    as (
        select      ltrim(rtrim(LastName))+', '+ltrim(rtrim(FirstName)) as SupervisorName
                , TerminationDate
                , WorkerPK
                , 'SUP' as workertype
        from        Worker w
        inner join  WorkerProgram wp on wp.WorkerFK = w.WorkerPK
        where       ProgramFK = @ProgramFK
                    and current_Timestamp between SupervisorStartDate and 
                        isnull(SupervisorEndDate, dateadd(dd , 1, datediff(dd, 0, getdate())))
    )

    ,   cteAssignedSupervisorFKS
    as (
        select      tw.WorkerPK
                , wp.SupervisorFK
        from        #tblWorkers tw
        inner join  WorkerProgram wp on wp.WorkerFK = tw.WorkerPK
        where       ProgramFK = @ProgramFK
    )

    ,   cteAssignedSupervisorsName
    as (
        select      SupervisorFK
                , asf.WorkerPK
                , ltrim(rtrim(w.LastName))+', '+ltrim(rtrim(w.FirstName)) as AssignedSupervisorName
        from        cteAssignedSupervisorFKS asf
        left join   Worker w on w.WorkerPK = asf.SupervisorFK
    )

    ------SELECT * FROM cteAssignedSupervisorsName  

    , cteSupervisionReasonsNotTookPlace
    as (
        select      SupervisionPK

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
        from        #tblWorkers w
        left join   Supervision s on s.WorkerFK = w.WorkerPK
        where       s.SupervisionSessionType = '0'
    )

    ,   cteSupervisionReasonsChecked
    as (
        select      SupervisionPK
                , sum(convert(int, ParticipantEmergency)+convert(int, ShortWeek)+convert(int, StaffCourt)
                        +convert(int, StaffFamilyEmergency)+convert(int, StaffForgot)+convert(int, StaffIll)
                        +convert(int, StaffTraining)+convert(int, StaffVacation)
                        +convert(int, StaffOutAllWeek)+convert(int, SupervisorFamilyEmergency)
                        +convert(int, SupervisorForgot)+convert(int, SupervisorHoliday)
                        +convert(int, SupervisorIll)+convert(int, SupervisorTraining)
                        +convert(int, SupervisorVacation)+convert(int, ReasonOther)+convert(int, Weather)
                    ) as ReasonsChecked
        from        #tblWorkers w
        left join   Supervision s on s.WorkerFK = w.WorkerPK
        where       s.SupervisionSessionType = '0'
        group by    SupervisionPK
    )

    --SELECT * FROM cteSupervisionReasonsChecked

    ------------    --SELECT * FROM cteSupervisionReasonsNotTookPlace

    --SELECT * FROM #tblMaxOf2SupervisionsPerWeek
    
    , cteSupervisionDurationsGroupedByWeek
    as (
        select      WorkerPK
                , sum(Duration) as WeeklyDuration
                , WeekNumber

        from        cteWorkersWithSupervisions
        group by    WorkerPK
                , WeekNumber
    )   

    --SELECT * FROM     cteSupervisionDurationsGroupedByWeek
    --  order by WorkerPK, WeekNumber

    , cteSupervisionDurationsGroupedByMonth
    as (
        select WorkerPK
				, sum(Duration) as MonthlyDuration
				, count(WorkerPK) as MonthlySupervisionCount
				, case when WeekNumber in (1, 2, 3, 4) then 1 
						when WeekNumber in (5, 6, 7, 8) then 2
						when WeekNumber in (9, 10, 11, 12, 13) then 3
					end as MonthGroup
        from cteWorkersWithSupervisions
        group by WorkerPK
					, case when WeekNumber in (1, 2, 3, 4) then 1 
                                        when WeekNumber in (5, 6, 7, 8) then 2
                                        when WeekNumber in (9, 10, 11, 12, 13) then 3
                                    end
    )

    , cteSupervisionCountsByQuarter
    as (
        select WorkerPK
				, count(SupervisionDate) as QuarterlySupervisionCount
        from cteWorkersWithSupervisions wws
        group by WorkerPK
    )
--select * from cteSupervisionDurationsGroupedByMonth

    , cteSupervisionEvents
    as (
        select      wws.WorkerPK
                , WorkerName
                , StartDate
                , EndDate
                , case when wws.SupervisionSessionType = '1' then 'Y' else 'N' end as SupervisionTookPlace
                , SupervisionDate
                , SupervisionHours
                , SupervisionMinutes
                , isnull(SupervisionHours * 60, 0)+isnull(SupervisionMinutes, 0) as Duration
                , sdgm.MonthlyDuration
                , sdgm.MonthlySupervisionCount
                , sdgw.WeeklyDuration
                , sdgw.WeekNumber
                , wws.SupervisionSessionType
				, RequiredWeeklyMinutes
                -- meets standard?
      --          , case
      --              -- Form found in period and reason is "Staff out all week"
      --              -- Note: E = Excused
      --              when (wws.SupervisionSessionType = '0') 
      --                      and (StaffOutAllWeek = 1) 
      --                  then 'E'
      --              -- Form found in period and reason is not "Staff out all week"              
      --              when (wws.SupervisionSessionType = '0') 
      --                      and (StaffOutAllWeek <> 1)
      --                      and (sdgw.WeeklyDuration = 0) 
						--then 'N'
      --              -- Form found in period and duration is greater than or equal to required
      --              when sdgw.WeeklyDuration >= RequiredWeeklyMinutes or
						--	sdgm.MonthlyDuration >= RequiredWeeklyMinutes or
						--	scbq.QuarterlySupervisionCount >= RequiredSupervisions
      --                  then 'Y'
      --              -- Form found in period and durations less than required
      --              when (sdgw.WeeklyDuration < RequiredWeeklyMinutes or
						--	sdgm.MonthlyDuration < RequiredWeeklyMinutes)
      --                      and (wws.SupervisionSessionType = '1') 
      --                  then 'N'
      --              -- Form not found in period
      --              when (WorkerFK is null and 
      --                      wws.SupervisionPK is null) 
      --                  then 'N' end as MeetsStandard
                -- reason supervision was not held
                , case
                    -- when (TakePlace = 0) and (StaffOutAllWeek = 1)  then 'Staff out all week'  -- Form found in period and reason is "Staff out all week"
                    -- Note: E = Excused
                    when (wws.SupervisionSessionType = '0') 
                            and (StaffOutAllWeek = 1)
                            and (reasonsChecked.ReasonsChecked >= 1) 
                        then
                            -- need to display more if there is more than one reasons checked
                            case when reasonsChecked.ReasonsChecked > 1 
                                then 'Staff out all week and more'
                            else 'Staff out all week' 
                            end
                    when (wws.SupervisionSessionType = '0') 
                            and (StaffOutAllWeek <> 1)
                            and (reasonsChecked.ReasonsChecked >= 1) 
                        then
                            -- need to display more if there is more than one reasons checked
                            case when reasonsChecked.ReasonsChecked > 1 
                                then reason.ReasonNOSupervision + ' and more'
                            -- Form found in period and reason is not “Staff out all week”
                            else reason.ReasonNOSupervision 
                            end
                    -- Form found in period and duration is 1:30 or greater 
                    when isnull(SupervisionHours * 60, 0) + 
                            isnull(SupervisionMinutes, 0) >= RequiredWeeklyMinutes
                            and wws.SupervisionSessionType in ('1', '2') 
                        then ''
                    -- Form found in period and duration less than 1:30
                    when isnull(SupervisionHours * 60, 0) + 
                            isnull(SupervisionMinutes, 0) < RequiredWeeklyMinutes
                            and (wws.SupervisionSessionType = '1') 
                        then 'Duration less than 1:30'
                    when wws.SupervisionSessionType = '2' 
                        then 'Planning-only'
                    when (WorkerFK is null and wws.SupervisionPK is null) 
                        then 'Unknown/Missing' -- Form not found in period
                    end as ReasonSupervisionNotHeld

                --,reason.ReasonNOSupervision

                , wws.SupervisionPK
                , SupervisorFK
                , sup.SupervisorName
                , wws.WorkerFK
                , wws.WeekNumber as wwsWeekNumber
                , wws.DaysInTheCurrentWeek
                , wws.FirstEvent
                , tcs.CaseCount
                , tcs.MostFrequentVisit
                , tcs.RequiredSupervisions
                , case when wws.WeekNumber in (1, 2, 3, 4) 
                            then 1 
                        when wws.WeekNumber in (5, 6, 7, 8) 
                            then 2
                        when wws.WeekNumber in (9, 10, 11, 12, 13) 
                            then 3
                        else 0
                    end as MonthNumber
        from        cteWorkersWithSupervisions wws
        left join   cteSupervisors sup 
                    on wws.SupervisorFK = sup.WorkerPK -- to fetch in supervisor's name
        left join   cteSupervisionReasonsNotTookPlace reason 
                    on reason.SupervisionPK = wws.SupervisionPK -- to fetch in reasons for supervision not took place
        left join   cteSupervisionReasonsChecked reasonsChecked 
                    on reasonsChecked.SupervisionPK = reason.SupervisionPK
        left join   cteSupervisionDurationsGroupedByWeek sdgw 
                    on sdgw.WorkerPK = wws.WorkerPK
                    and sdgw.WeekNumber = wws.WeekNumber
        left join   cteSupervisionDurationsGroupedByMonth sdgm
                    on sdgm.WorkerPK = wws.WorkerPK
                    and sdgm.MonthGroup = case when wws.WeekNumber in (1, 2, 3, 4) 
                                                    then 1 
                                                when wws.WeekNumber in (5, 6, 7, 8) 
                                                    then 2
                                                when wws.WeekNumber in (9, 10, 11, 12, 13) 
                                                    then 3
                                                else 0
                                            end
		left join	cteSupervisionCountsByQuarter scbq on scbq.WorkerPK = wws.WorkerPK
        left join   Worker w on wws.WorkerFK = w.WorkerPK
        left join   #tblCaseStats tcs on tcs.WorkerPK = wws.WorkerPK
    )

    --select * from cteSupervisionEvents
    --order by workername,weeknumber, SupervisionDate

    , cteReportDetails
    as (
        select  WorkerName
            , StartDate
            , EndDate
            , SupervisionDate
            , SupervisionHours
            , SupervisionMinutes
            , Duration
            , SupervisionSessionType
            --, case when Duration = 0 
            --            and MeetsStandard = 'Y' 
            --            and ReasonSupervisionNotHeld is not null 
            --        then ''
            --        when DaysInTheCurrentWeek is not null 
            --                and DaysInTheCurrentWeek < 7 
            --            then 'Less Than a Week'
            --        else MeetsStandard 
            --    end as MeetsStandard
            , SupervisorName
            , ReasonSupervisionNotHeld
            , DaysInTheCurrentWeek
            , WeekNumber
            , MonthNumber
            , FirstEvent
            , se.WorkerPK
            , tcs.CaseCount
            , tcs.MostFrequentVisit
            , tcs.RequiredSupervisions
        from    cteSupervisionEvents se
        left join   #tblCaseStats tcs on tcs.WorkerPK = se.WorkerPK
    )

    --SELECT * FROM cteReportDetails

    , cteReportDetailsModified
    as (

        select  WorkerName
            , StartDate
            , EndDate
            , SupervisionDate
            , SupervisionHours
            , SupervisionMinutes
            , Duration
            , SupervisionSessionType
            --, MeetsStandard
            --ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
    --        , case when (FirstEvent between @StartDate and @EndDate) then
    --                    case when (FirstEvent <= EndDate) then MeetsStandard else '' end
    --            else
    --                MeetsStandard 
				--end as MeetsStandard1
            , SupervisorName
            , ReasonSupervisionNotHeld
            , DaysInTheCurrentWeek
            , WeekNumber
            , MonthNumber
            , @StartDate as StartDate1
            , @EndDate as EndDate1
            , FirstEvent
            , WorkerPK
            , CaseCount
            , MostFrequentVisit
            , RequiredSupervisions
        from    cteReportDetails
    )

    --SELECT * FROM cteReportDetailsModified
    --order by workername,weeknumber, SupervisionDate
    
    -- need a copy of cteReportDetailsModified later usage
    , cteReport1
    as (

    select  WorkerPK
            , WeekNumber
            , Duration
            , WeeklyDuration
            , MonthlyDuration
            , lag(Duration) over(partition by WorkerFK, WeekNumber order by SupervisionDate) as LagDuration
            , format(SupervisionDate, 'yyyy-MM-dd') as SupervisionDateFormatted
            , sum(Duration) over(partition by WorkerFK, WeekNumber
                                    order by SupervisionDate
                                    rows unbounded preceding) as RunningWeeklyTotal
            , RequiredWeeklyMinutes as FTERequiredWeeklyMinutes
            , WorkerName
            , StartDate
            , EndDate
            , SupervisionTookPlace
            , SupervisionDate
            , SupervisionHours
            , SupervisionMinutes
            , MonthlySupervisionCount
            , SupervisionSessionType
            --, MeetsStandard
            --, case when (FirstEvent between @StartDate and @EndDate) then
            --            case when (FirstEvent <= EndDate) then MeetsStandard else '' end
            --    else MeetsStandard end as MeetsStandard1
            , ReasonSupervisionNotHeld
            , SupervisionPK
            , SupervisorFK
            , SupervisorName
            , WorkerFK
            , wwsWeekNumber
            , DaysInTheCurrentWeek
            , FirstEvent
            , CaseCount as PermanentCaseLoad
            , MostFrequentVisit
            , case when RequiredSupervisions is not null 
                    then RequiredSupervisions 
                    --else round(((datediff(day, @StartDate, @EndDate) + 1) / 7 ), 0)
					else 0
                end 
				+ case when MostFrequentVisit < 1.00 or MostFrequentVisit is null then 3 else 0 end
				as RequiredQuarterlySupervisions
            , MonthNumber
        from cteSupervisionEvents se
        --order by se.WorkerName, se.WeekNumber, se.SupervisionDate

        --select    WorkerName
        --  , StartDate
        --  , EndDate
        --  , SupervisionDate
        --  , SupervisionHours
        --  , SupervisionMinutes
        --  , Duration
        --  , SupervisionSessionType
        --  , MeetsStandard
        --  --ToDo: firstevent date is in the period, but not in the current week then MeetsStandard should be blank
        --  , case when (FirstEvent between @StartDate and @EndDate) then
        --              -- Need JH Help
        --              case when (FirstEvent <= EndDate) then MeetsStandard else '' end
        --      else MeetsStandard end as MeetsStandard1
        --  , SupervisorName
        --  , ReasonSupervisionNotHeld
        --  , DaysInTheCurrentWeek
        --  , WeekNumber
        --  , MonthNumber
        --  , FirstEvent
        --  , WorkerPK
        --  , CaseCount
        --  , MostFrequentVisit
        --  , RequiredSupervisions
        --from  cteReportDetails
    )

    ------SELECT * FROM ctecteReportDetailsModified
    ------          order by workername, weeknumber, SupervisionDate

    --, cteUniqueMeetsStandard
    --as (
    --    select  distinct WorkerName
    --                , MeetsStandard1
    --                , WeekNumber
    --                , MonthNumber
    --                , DaysInTheCurrentWeek
				--	, case when RequiredSupervisions is not null 
				--			then RequiredSupervisions 
				--			--else round(((datediff(day, @StartDate, @EndDate) + 1) / 7 ), 0)
				--			else 0
				--		end 
				--		+ case when MostFrequentVisit < 1.00 then 3 else 0 end
				--		as RequiredQuarterlySupervisions
    --    from    cteReportDetailsModified
    --)

    ---- select * from cteUniqueMeetsStandard

    --,   cteScoreByWorker
    --as (

    --    select      WorkerName
    --            --, sum(  case when DaysInTheCurrentWeek = 7 and  MeetsStandard1 <> ' ' then 1
    --            --        else 0 end
    --            --    ) as ExpectedSessions
				--, avg(case when RequiredQuarterlySupervisions is not null 
				--			then RequiredQuarterlySupervisions 
				--			else 1 
				--		end) as ExpectedSessions
    --            , sum(case when MeetsStandard1 = 'E' then 1 else 0 end) as AllowedExcuses
    --            , sum(case when MeetsStandard1 = 'Y' then 1 else 0 end) as MeetStandardYes
    --    --,weeknumber
    --    --,DaysInTheCurrentWeek
    --    from        cteUniqueMeetsStandard
    --    group by    WorkerName
    --)

    select      cr.WorkerName
            , convert(varchar(12), cr.StartDate, 101) as startdate
            --,enddate
            , convert(varchar(12), SupervisionDate, 101) as SupervisionDate
            --,SupervisionHours
            --,SupervisionMinutes
            , case -- convert to string
                when SupervisionHours > 0 and SupervisionMinutes > 0 
                    then convert(varchar(10), SupervisionHours)+':'
                            + case when SupervisionMinutes < 10 then '0' else '' end
                            + trim(convert(varchar(2), SupervisionMinutes))
                when SupervisionHours > 0 and (SupervisionMinutes = 0 or SupervisionMinutes is null) 
                    then convert(varchar(10), SupervisionHours)+':00'
                when (SupervisionHours = 0 or SupervisionHours is null) and SupervisionMinutes > 0 
                    then '0:' + case when SupervisionMinutes < 10 then '0' else '' end
                            + trim(convert(varchar(2), SupervisionMinutes))
                else ' ' 
                end as Duration
            , case SupervisionSessionType 
                when '1' 
                    then 'Y'
                when '2' 
                    then 'P'
                else 'N' 
                end as TakePlace
            --, MeetsStandard1 as MeetsStandard
            , SupervisorName
            , ReasonSupervisionNotHeld
            , cr.FirstEvent
            , cr.WorkerPK
            , 'Sup' as workerRole
            , DaysInTheCurrentWeek
    --        , ExpectedSessions
    --        , AllowedExcuses
    --        , ExpectedSessions - AllowedExcuses as AdjustedExpectedSupervisions
    --        , case when MeetStandardYes > ExpectedSessions 
				--	then ExpectedSessions 
				--	else MeetStandardYes
				--end as MeetStandardYes
    --        , case when MeetStandardYes > ExpectedSessions 
				--	then convert(varchar, ExpectedSessions) + ' (100%)'
				--	else convert(varchar, MeetStandardYes)+' ('
				--			+ convert(varchar, round(coalesce(cast(MeetStandardYes as float)* 100
				--											/ nullif((ExpectedSessions - AllowedExcuses), 0), 0), 0))
				--			+ '%)'
				--end as PctOfAcceptableSupervisions
    --        , case
    --            --CP 08/14/2014 If allowed excuses is equal to expected sessions (e.g. NO supervisions required) then HFA Rating should be a 3
    --            when ExpectedSessions - AllowedExcuses = 0 then 3
    --            when round(coalesce(cast(MeetStandardYes as float)* 100
    --                                    / nullif((ExpectedSessions - AllowedExcuses), 0), 0), 0)
    --                    >= 90 
    --                then 3
    --            when round(coalesce(cast(MeetStandardYes as float)* 100
    --                                    / nullif((ExpectedSessions - AllowedExcuses), 0), 0), 0)
    --                    between 75 and 90 
    --                then 2
    --            when round(coalesce(cast(MeetStandardYes as float)* 100
    --                                    / nullif((ExpectedSessions - AllowedExcuses), 0), 0), 0)
    --                    < 75 
    --                then 1 
    --        end as HFARating
            , asn.AssignedSupervisorName
            , twrkr.ScheduledDayName as ScheduledDayName
            , twrkr.SupervisionScheduledDay
            , convert(varchar(12), twrkr.StartDate, 101) as AdjustedStartDate
            ----,@DayofWeek as DayNameSelectedByUser
            --, w.FTEFullTime AS FTEFullTime
            , w.FTE as FTE
            , case when w.FTE = '01' 
                        then 'Full time'
                    when w.FTE = '02' 
                        then 'Part Time (.25 thru .75)'
                    when w.FTE = '03' 
                        then 'Part Time (less than .25)'
                    else 'Unknown/Missing' 
                end FTEText
			, RunningWeeklyTotal
            , case when PermanentCaseLoad is null 
					then 'N/A' 
					else convert(char(3), PermanentCaseLoad)
				end as PermanentCaseLoadText
            , MostFrequentVisit
            , RequiredQuarterlySupervisions
            , MonthNumber
    from        cteReport1 cr
    --left join   cteScoreByWorker sw on sw.WorkerName = cr.WorkerName
    left join   Worker w on w.WorkerPK = cr.WorkerPK
    left join   cteAssignedSupervisorsName asn on asn.WorkerPK = cr.WorkerPK
    left join   #tblWorkers twrkr on twrkr.WorkerPK = w.WorkerPK
    --where MeetsStandard <> 'N/A'
    order by    cr.WorkerName
            , cr.WeekNumber
            , cr.SupervisionDate ;

    drop table #tblStaff ;
    drop table #tblPMWorkers ;
    drop table #tblWorkers ;
    drop table #tblCaseStats ;
    drop table #tblWeekPeriods ;
    drop table #tblWeekPeriodsAdjusted ;
    drop table #tblMaxOf2SupervisionsPerWeek ;

end
GO
