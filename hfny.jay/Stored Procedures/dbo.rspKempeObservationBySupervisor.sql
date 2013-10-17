
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspKempeObservationBySupervisor]
(
    @programfk varchar(max)	= null,
    @sitefk		 int		= null,
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
	as (select distinct FAWFK
			from Kempe
				inner join dbo.SplitString(@programfk,',') on Kempe.programfk = listitem
			where datediff(m,KempeDate,getdate()) <= 12
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
				where FAWFK = w.WorkerPK) KempeDate_min
		  ,RTRIM(w.FirstName)+' '+RTRIM(w.LastName) FAW
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
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			
			right join Worker w on w.WorkerPK = q.FAWFK
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
			inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			--inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = hvcasepk
		where w.WorkerPK in (select FAWFK from WorkerCohort)
			 and wp.TerminationDate is NULL
			 and w.LastName <> 'Transfer Worker'
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor.LastName
				,w.LastName
				,KempeDate desc
				,hvcasepk
GO
