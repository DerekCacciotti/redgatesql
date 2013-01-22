SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: Jan 22, 2013
-- Description:	Return workers FSW & FAW workers (specifically for the Service Referral form
-- Test: exec spGetAllFAWFSWWorkersbyProgram 30, '01/15/2013'
-- =============================================
CREATE procedure [dbo].[spGetAllFAWFSWWorkersbyProgram]
	@ProgramFK  int           = null,
    @EventDate  datetime      = null
    
as

set nocount on

	begin
		set @EventDate = isnull(@EventDate, current_timestamp);

		with cteAllWorkers as 
		(
			select LastName, FirstName, TerminationDate, WorkerPK, 'FAW' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and faw = 1
					and @EventDate between FAWStartDate AND isnull(FAWEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
					AND (TerminationDate IS NULL OR TerminationDate>=@EventDate)
			union all
			select LastName, FirstName, TerminationDate, WorkerPK, 'FSW' as workertype
			from worker
			inner join workerprogram on workerpk=workerfk
			where ProgramFK = isnull(@ProgramFK, ProgramFK)
					-- and fsw = 1
					and @EventDate between FSWStartDate AND isnull(FSWEndDate,dateadd(dd,1,datediff(dd,0,getdate())))
					AND (TerminationDate IS NULL OR TerminationDate>=@EventDate)
			)

		select distinct rtrim(LastName) + ', ' + rtrim(FirstName) + case when TerminationDate is not null then ' *' else '' end as WorkerName
						, LastName
						, FirstName
						, TerminationDate
						, WorkerPK 
						, case when TerminationDate is null then 0 else 1 end
		from cteAllWorkers aw
		where (not FirstName like 'Historical%') and LastName <> 'Transfer Worker'
		order by case when TerminationDate is null then 0 else 1 end, LastName, FirstName
	end

GO
