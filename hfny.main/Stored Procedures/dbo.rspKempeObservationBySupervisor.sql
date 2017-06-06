SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- Edit date: 5/17/17 Bug fix - Report not displaying FAWs that have Kempes and no supervisor observations (Benjamin Simmons)
-- =============================================
CREATE procedure [dbo].[rspKempeObservationBySupervisor]
(
    @programfk varchar(max)	= null,
    @sitefk		 int		= null
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
	as (select distinct FAWFK, ProgramFK
			from Kempe
				inner join dbo.SplitString(@programfk,',') on Kempe.programfk = listitem
			where datediff(m,KempeDate,getdate()) <= 12
	)
	--select * from cteWorkerCohort inner join dbo.Worker on Worker.WorkerPK = FAWFK order by FAWFK
	,
	
	cteKempes
	as (select Kempe.KempeDate
			  ,hvcasepk
			  ,wc.FAWFK
			from cteWorkerCohort wc
				inner join Kempe on Kempe.FAWFK = wc.FAWFK and SupervisorObservation=1
				inner join HVCase on HVCase.HVCasePK = Kempe.hvcasefk
			where  --datediff(m,Kempe.KempeDate,getdate()) <= 12 and
				SupervisorObservation=1
				  --isnull(SupervisorObservation, 1)=1
				  --or KempePK is null
	)
	
	--select * from cteKempes k inner join dbo.Worker on Worker.WorkerPK = k.FAWFK
	,

	cteKempesNoObservation
	as (select Kempe.KempeDate
			  ,hvcasepk
			  ,wc.FAWFK
			from cteWorkerCohort wc
				inner join Kempe on Kempe.FAWFK = wc.FAWFK and SupervisorObservation=1
				inner join HVCase on HVCase.HVCasePK = Kempe.hvcasefk
			where  --datediff(m,Kempe.KempeDate,getdate()) <= 12 and
				  isnull(SupervisorObservation, 0)=0
				  or KempePK is null
	)
	,
	
	q
	as (select KempeDate
			  ,HVCasePK
			  ,FAWFK
			  ,RowNumber = row_number() over (partition by FAWFK order by KempeDate desc)
			from cteKempes
			union
			select KempeDate
			  ,HVCasePK
			  ,FAWFK
			  ,RowNumber = -1
			from cteKempesNoObservation
	)

	--select * from q inner join dbo.Worker on Worker.WorkerPK = q.FAWFK

	select coalesce(pc1id,'No Kempe Observations') pc1id
		  ,KempeDate
		  ,hvcasepk
		  ,(select min(KempeDate) KempeDate
				from Kempe
				where FAWFK = w.WorkerPK) KempeDate_min
		  ,(select max(KempeDate) KempeDate
				from Kempe
				where FAWFK = w.WorkerPK) KempeDate_max
		  ,RTRIM(w.FirstName)+' '+RTRIM(w.LastName) FAW
		  ,coalesce(rtrim(supervisor.FirstName)+' '+RTRIM(supervisor.LastName), 'None') supervisor
		from (select KempeDate
					,hvcasepk
					,FAWFK
				  from q
				  where RowNumber <= 5 and RowNumber >= 0
				  group by hvcasepk
						  ,KempeDate
						  ,FAWFK) q
			inner join CaseProgram cp on cp.HVCaseFK = hvcasepk
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			
			right join Worker w on w.WorkerPK = q.FAWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = listitem
			left outer join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			--inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
		where w.WorkerPK in (select FAWFK from cteWorkerCohort)
			 and wp.TerminationDate is NULL
			 and w.LastName <> 'Transfer Worker'
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by supervisor.LastName
				,w.LastName
				,KempeDate desc
				,hvcasepk
GO
