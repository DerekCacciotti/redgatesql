
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE procedure [dbo].[rspKempeObservationBySupervisor]
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
	as (select distinct FAWFK
			from Kempe
				inner join dbo.SplitString(@programfk,',') on Kempe.programfk = listitem
			where datediff(year,KempeDate,getdate()) <= 1
	),
	kempes (KempeDate,hvcasepk,FAWFK)
	as (select Kempe.KempeDate
			  ,hvcasepk
			  ,Kempe.FAWFK
			from Kempe
				left join HVCase on HVCase.HVCasePK = Kempe.hvcasefk
				inner join WorkerCohort on Kempe.FAWFK = WorkerCohort.FAWFK
				inner join dbo.SplitString(@programfk,',') on Kempe.programfk = listitem
			where  --datediff(m,Kempe.KempeDate,getdate()) <= 12 and
				  Kempe.SupervisorObservation = 1
	),
	q
	as (select KempeDate
			  ,hvcasepk
			  ,FAWFK
			  ,RowNumber = row_number() over (partition by FAWFK order by KempeDate desc)
			from kempes
	)
	select coalesce(pc1id,'No Kempe Observations') pc1id
		  ,KempeDate
		  ,hvcasepk
		  ,(select min(KempeDate) KempeDate
				from Kempe
				where FAWFK = Worker.WorkerPK) KempeDate_min
		  ,RTRIM(Worker.FirstName)+' '+RTRIM(Worker.LastName) FAW
		  ,RTRIM(supervisor.FirstName)+' '+RTRIM(supervisor.LastName) supervisor
		from (select KempeDate
					,hvcasepk
					,FAWFK
				  from q
				  where RowNumber <= 5
				  group by hvcasepk
						  ,KempeDate
						  ,FAWFK) q
			inner join CaseProgram cp on cp.HVCaseFK = hvcasepk
			right join Worker on Worker.WorkerPK = q.FAWFK
			inner join WorkerProgram on WorkerProgram.WorkerFK = Worker.WorkerPK
			inner join Worker supervisor on WorkerProgram.SupervisorFK = supervisor.WorkerPK
			inner join dbo.SplitString(@programfk,',') on WorkerProgram.programfk = listitem
		where Worker.WorkerPK in (select FAWFK from WorkerCohort)
			 and WorkerProgram.TerminationDate is NULL
			 AND Worker.LastName <> 'Transfer Worker'
		order by supervisor.LastName
				,Worker.LastName
				,KempeDate desc
				,hvcasepk



GO
