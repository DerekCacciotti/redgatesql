
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
    @programfk varchar(max)    = null,
    @sitefk		 int		   = null,
    @posclause	 varchar(200), 
    @negclause	 varchar(200)

)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','');
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @posclause = case when @posclause = '' then null else @posclause end;

	with WorkerCohort
	as (select distinct FSWFK
			from HVLog
				inner join dbo.SplitString(@programfk,',') on HVLog.programfk = listitem
			where datediff(m,VisitStartTime,getdate()) <= 12
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
			where -- datediff(year,VisitStartTime,getdate()) <= 1 and
				 SupervisorObservation = 1
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
				where FSWFK = w.WorkerPK
				group by fswfk) hvdate_min
		  ,RTRIM(w.FirstName)+' '+RTRIM(w.LastName) fsw
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
			right join Worker w on w.WorkerPK = q.FSWFK
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
			inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = hvcasepk
		where w.WorkerPK in (select FSWFK
									  from WorkerCohort)
			 and wp.TerminationDate is null
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor.LastName
				,w.LastName
				,VisitStartTime desc
				,hvcasepk

GO
