SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Aug. 28, 2018
-- Description:	Return workers who are working at a specified date from a specified program 
--					for a specified type of worker
--				Null date is set to tomorrow at midnight so difference in computer clocks 
--					doesn't effect enddate.
--				This is a variation of spGetAllWorkersbyProgram which sorts workers 
--					based on role first, then termination status, then last/first name.
--				It sorts roles in this order: PM, SUP, FAW(FRS), FSW(FSS), FAdv
-- Test: exec spGetAllWorkersbyProgramWithGroups 30,null,'FSW,FAW,FAdv,SUP,PM'
--		 exec spGetAllWorkersbyProgramWithGroups 1,'2016-01-01', 'SUP,FAW,FSW'
--		 exec spGetAllWorkersbyProgramWithGroups 2,NULL,NULL,1

-- Edit date: 10/10/2019
-- Edited by: Bill O'Brien
-- Edit Reason: With Worker Redesign, need to account for role end dates and worker leave periods.
-- =============================================
CREATE procedure [dbo].[spGetAllWorkersbyProgramWithGroups]
	@ProgramFK  int           = null,
    @EventDate  datetime      = null,
    @WorkerType varchar(20)   = null,
	@AllWorkers bit			  = null
    
as

set nocount on

if @AllWorkers = 0 or @AllWorkers is null 
	begin
		set @EventDate = isnull(@EventDate, current_timestamp);
		set @WorkerType = case when dbo.IsNullOrEmpty(@WorkerType)=1 or upper(@WorkerType)='ALL' then 'FSW,FAW,PM,FAdv,SUP,' else @WorkerType end;

		with cteAllWorkers as 
		(
			select LastName, FirstName, TerminationDate, WorkerPK, 'FAW' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and faw = 1
					and @EventDate between FAWStartDate AND isnull(FAWEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
			union all
			select LastName, FirstName, TerminationDate, WorkerPK, 'FSW' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and fsw = 1
					and @EventDate between FSWStartDate AND isnull(FAWEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
			union all
			select LastName, FirstName, TerminationDate, WorkerPK, 'FAdv' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and FatherAdvocate = 1
					and @EventDate between FatherAdvocateStartDate AND isnull(FatherAdvocateEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
			union all
			select LastName, FirstName, TerminationDate, WorkerPK, 'SUP' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and supervisor = 1
					and @EventDate between SupervisorStartDate AND isnull(SupervisorEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
			union all
			select LastName, FirstName, TerminationDate, WorkerPK, 'PM' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and programmanager = 1
					and @EventDate between ProgramManagerStartDate AND isnull(ProgramManagerEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
			)

		select rtrim(LastName) + ', ' + rtrim(FirstName) 
					+ case when TerminationDate is not null 
							then ' *' 
							else '' 
						end as WorkerName
				, LastName
				, FirstName
				, convert(varchar(10), TerminationDate, 126) as TerminationDate
				, WorkerPK 
				, case when TerminationDate is null then 0 else 1 end as TerminationStatus
				, workertype
		from cteAllWorkers aw
		inner join dbo.SplitString(@WorkerType,',') on workertype = listitem
		left join fnWorkersOnLeave(@EventDate, @ProgramFK) wol on wol.WorkerFK = WorkerPK
		where (not FirstName like 'Historical%') and LastName <> 'Transfer Worker'
		and wol.WorkerFK is null
		-- where workertype in (select listitem from dbo.SplitString(@WorkerType,','))
		-- inner join Worker w on w.WorkerPK = aw.WorkerPK
		order by case workertype 
						when 'PM' then 1
						when 'SUP' then 2
						when 'FAW' then 3
						when 'FSW' then 4
						else 5
					end, 
					case when TerminationDate is null then 0 else 1 end, 
					LastName, FirstName
	end
else
	begin
		select distinct rtrim(LastName) + ', ' + rtrim(FirstName) + case when TerminationDate is not null then ' *' else '' end as WorkerName
						, LastName
						, FirstName
						, convert(varchar(10), TerminationDate, 126) as TerminationDate
						, WorkerPK 
						, case when TerminationDate is null then 0 else 1 end
		from WorkerProgram wp
		inner join Worker w on w.WorkerPK = wp.WorkerFK
		left join fnWorkersOnLeave(@EventDate, @ProgramFK) wol on wol.WorkerFK = WorkerPK
		where ProgramFK = isnull(@ProgramFK, ProgramFK)
				and (not FirstName like 'Historical%') 
				and LastName <> 'Transfer Worker'
				and wol.WorkerFK is null
		order by case when TerminationDate is null then 0 else 1 end, LastName, FirstName
	end
GO
