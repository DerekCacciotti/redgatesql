SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 5/17/17 Bug fix - Report not displaying FSWs that have Home Visits and no supervisor observations and
-- is showing home visits without observations (Benjamin Simmons)
-- =============================================
CREATE procedure [dbo].[rspHomeVisitObservationBySupervisor]
(
    @programfk varchar(max)    = null,
    @sitefk		 int		   = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;

	with cteWorkerCohort
	as (select distinct FSWFK
			from HVLog
				inner join dbo.SplitString(@programfk,',') on HVLog.programfk = listitem
			where datediff(month,cast(VisitStartTime AS DATE),getdate()) <= 12
	),
	hvlogs (VisitStartTime,hvcasepk,visitType,FSWFK)
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,hvlog.FSWFK
			from hvlog
				left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
				inner join cteWorkerCohort on hvlog.FSWFK = cteWorkerCohort.FSWFK
				inner join dbo.SplitString(@programfk,',') on hvlog.programfk = listitem
			where -- datediff(year,VisitStartTime,getdate()) <= 1 and 
				SupervisorObservation = 1
				--isnull(SupervisorObservation, 1) = 1
				--or HVLogPK = null
	),
	hvlogsNoObservation (VisitStartTime,hvcasepk,visitType,FSWFK)
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,hvlog.FSWFK
			from hvlog
				left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
				inner join cteWorkerCohort on hvlog.FSWFK = cteWorkerCohort.FSWFK
				inner join dbo.SplitString(@programfk,',') on hvlog.programfk = listitem
			where -- datediff(year,VisitStartTime,getdate()) <= 1 and 
				isnull(SupervisorObservation, 0) = 0
				or HVLogPK = null
	),
	q
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,FSWFK
			  ,RowNumber = row_number() over (partition by FSWFK order by VisitStartTime desc)
			from hvlogs
			union
			select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,FSWFK
			  ,RowNumber = -1
			from hvlogsNoObservation
	)
	select coalesce(pc1id,'No Home Visit Observations') pc1id
		  ,VisitStartTime
		  ,hvcasepk
		  ,(select min(VisitStartTime) VisitStartTime
				from hvlog
				where FSWFK = w.WorkerPK
				group by fswfk) hvdate_min
		  ,(select max(VisitStartTime) VisitStartTime
				from hvlog
				where FSWFK = w.WorkerPK
				group by fswfk) hvdate_max
		  ,RTRIM(w.FirstName)+' '+RTRIM(w.LastName) fsw
		  ,RTRIM(supervisor.FirstName)+' '+RTRIM(supervisor.LastName) supervisor
		  ,case
				when substring(visitType,1,1) = '1' or substring(visitType,2,1) = '1' then
					'In Home'
				when substring(visitType,3,1) = '1' then
					'Out of Home'
				when visitType is null then
					''
				else
					'Attempted - Family not home or unable to meet after visit to home'
				end as visitType
		from (select VisitStartTime
					,hvcasepk
					,visitType
					,FSWFK
				  from q
				  where RowNumber <= 7 and RowNumber >= 0
				  group by FSWFK
						  ,hvcasepk
						  ,VisitStartTime
						  ,visitType) q
			inner join CaseProgram cp on cp.HVCaseFK = hvcasepk
			inner join dbo.SplitString(@programfk,',') on cp.ProgramFK = listitem
			
			right join Worker w on w.WorkerPK = q.FSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = ListItem
			left outer join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			--inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
		where w.WorkerPK in (select FSWFK
									  from cteWorkerCohort)
			 and wp.TerminationDate is null
			 and w.LastName <> 'Transfer Worker'
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor.LastName
				,w.LastName
				,VisitStartTime desc
				,hvcasepk

GO
