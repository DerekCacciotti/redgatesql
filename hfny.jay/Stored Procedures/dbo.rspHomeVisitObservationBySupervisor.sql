SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE procedure [dbo].[rspHomeVisitObservationBySupervisor]
(
    @programfk varchar(max)    = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','');

	with WorkerCohort
	as (select distinct FSWFK
			from HVLog
				inner join dbo.SplitString(@programfk,',') on HVLog.programfk = listitem
			where datediff(year,VisitStartTime,getdate()) <= 1
	),
	hvlogs (VisitStartTime,hvcasepk,visitType,FSWFK)
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,hvlog.FSWFK
			from hvlog
				left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
				inner join WorkerCohort on hvlog.FSWFK = WorkerCohort.FSWFK
				inner join dbo.SplitString(@programfk,',') on hvlog.programfk = listitem
			where datediff(year,VisitStartTime,getdate()) <= 1
				 and SupervisorObservation = 1
	),
	q
	as (select VisitStartTime
			  ,hvcasepk
			  ,visitType
			  ,FSWFK
			  ,RowNumber = row_number() over (partition by FSWFK order by VisitStartTime desc)
			from hvlogs
	)
	select coalesce(pc1id,'No Home Visit Observations') pc1id
		  ,VisitStartTime
		  ,hvcasepk
		  ,(select min(VisitStartTime) VisitStartTime
				from hvlog
				where FSWFK = worker.WorkerPK
				group by fswfk) hvdate_min
		  ,RTRIM(Worker.FirstName)+' '+RTRIM(Worker.LastName) fsw
		  ,RTRIM(supervisor.FirstName)+' '+RTRIM(supervisor.LastName) supervisor
		  ,case
				when substring(visitType,1,1) = '1' or substring(visitType,2,1) = '1' then
					'Home Visit'
				when substring(visitType,4,1) = '1' then
					'Attempted - Family not home or unable to meet after visit to home'
				else
					''
				end as visitType
		from (select VisitStartTime
					,hvcasepk
					,visitType
					,FSWFK
				  from q
				  where RowNumber <= 5
				  group by FSWFK
						  ,hvcasepk
						  ,VisitStartTime
						  ,visitType) q
			inner join CaseProgram cp on cp.HVCaseFK = hvcasepk
			right join Worker on Worker.WorkerPK = q.FSWFK
			inner join WorkerProgram on WorkerProgram.WorkerFK = Worker.WorkerPK
			inner join Worker supervisor on WorkerProgram.SupervisorFK = supervisor.WorkerPK
			inner join dbo.SplitString(@programfk,',') on WorkerProgram.programfk = listitem
		where Worker.WorkerPK in (select FSWFK
									  from WorkerCohort)
			 and WorkerProgram.TerminationDate is null
		order by supervisor.LastName
				,Worker.LastName
				,VisitStartTime desc
				,hvcasepk

GO
