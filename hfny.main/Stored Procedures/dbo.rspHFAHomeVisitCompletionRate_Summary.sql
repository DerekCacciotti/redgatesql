SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating transferred workers - YEAH!

-- =============================================
CREATE PROCEDURE [dbo].[rspHFAHomeVisitCompletionRate_Summary](@programfk    varchar(max)    = null,
                                                       @sdate        datetime,
                                                       @edate        datetime,
                                                       @supervisorfk int             = null,
                                                       @workerfk     int             = null,
                                                       @sitefk		 int			 = null,
                                                       @posclause	 varchar(200), 
                                                       @negclause	 varchar(200)
                                                       )

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @posclause = case when @posclause = '' then null else @posclause end;
	set @negclause = case when @negclause = '' then null else @negclause end;

	declare @cteHVRecords table (
		workername char(50)
		,workerfk int
		,casecount int
		,pc1id char(15)
		,startdate datetime
		,enddate datetime
		,levelname char(50)
		,levelstart datetime
		,expvisitcount int
		,actvisitcount int
		,inhomevisitcount int
		,attvisitcount int
		,DirectServiceTime datetime
		,visitlengthminute int
		,visitlengthhour int
		,dischargedate datetime
		,pc1wrkfk char(25)
		,casefk int
	)
	insert into @cteHVRecords
	select distinct rtrim(firstname)+' '+rtrim(lastname)
					,hvr.workerfk
					,count(distinct casefk)
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk)
					,floor(reqvisit) as expvisitcount
					,sum(case
							 when SUBSTRING(VisitType, 4, 1) <> '1' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' or substring(visittype,3,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when SUBSTRING(VisitType, 4, 1) = '1' then
								 1
							 else
								 0
						 end)
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001')))
					,sum(visitlengthminute)+sum(visitlengthhour)*60
					,sum(visitlengthhour)
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk)  --use for a distinct unique field for the OVER(PARTITION BY) above	
					 ,hvr.casefk
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			 inner join worker on workerpk = hvr.workerfk
			 inner join workerprogram wp on wp.workerfk = workerpk
			 inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			 inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = hvr.casefk
		 where workerpk = isnull(@workerfk,workerpk)
			  and supervisorfk = isnull(@supervisorfk,supervisorfk)
			  and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
			  and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		 group by firstname
				 ,lastname
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	
	declare @cteLevelChanges table (
		casefk int
		,LevelChanges int
	)
	insert into @cteLevelChanges 
	select casefk
		   ,count(casefk)-1 as LevelChanges
		 from @cteHVRecords
		 group by casefk
	
	declare @cteSummary table (
		workername char(50)
		,workerfk int
		,pc1id char(15)
		,casecount int
		,[Minutes] int
		,expvisitcount int
		,startdate datetime
		,enddate datetime
		,levelname char(50)
		,levelstart datetime
		,actvisitcount int
		,inhomevisitcount int
		,attvisitcount int
		,dischargedate datetime
		,IntakeDate datetime
		,TCDOB datetime
		,LevelChanges int
	)
	insert into @cteSummary
	select distinct workername
					,workerfk
					,pc1id
					,casecount
					,sum(visitlengthminute) over (partition by pc1wrkfk)
					,sum(expvisitcount) over (partition by pc1wrkfk)
					,min(startdate) over (partition by pc1wrkfk)
					,max(enddate) over (partition by pc1wrkfk)
					,levelname
					,max(levelstart) over (partition by pc1wrkfk)
					,sum(actvisitcount) over (partition by pc1wrkfk)
					,sum(inhomevisitcount) over (partition by pc1wrkfk)
					,sum(attvisitcount) over (partition by pc1wrkfk)
					,max(dischargedate) over (partition by pc1wrkfk)
					,IntakeDate
					,case when TCDOB is null
							then EDC
						  else TCDOB
					end as TCDOB
					,LevelChanges
		 from @cteHVRecords hvr
			 inner join @cteLevelChanges lc on lc.casefk = hvr.casefk
			 inner join HVCase c on hvr.casefk = c.HVCasePK

	declare @cteMain table (
		workername char(50)
		,workerfk int
		,pc1id char(15)
		,casecount int
		,DirectServiceTime datetime
		,expvisitcount int
		,startdate datetime
		,enddate datetime
		,levelname char(50)
		,levelstart datetime
		,actvisitcount int
		,inhomevisitcount int
		,attvisitcount int
		,VisitRate float
		,InHomeRate float
		,dischargedate datetime
		,IntakeDate datetime
		,TCDOB datetime
		,LevelChanges int
	)
	-- make the aggregate table
	insert into @cteMain
	select distinct workername
					,workerfk
					,pc1id
					,casecount
					,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) 
					,expvisitcount
					,startdate
					,enddate
					,max(levelname) over (partition by pc1id)
					--CHRIS PAPAS - below line was bringing in duplicates (ex. AL8713016704 for July 2010 - June 2011)
					 --, (SELECT TOP 1 levelname ORDER BY enddate) AS levelname
					 ,levelstart
					,actvisitcount
					,inhomevisitcount
					,attvisitcount
					,case
						 when actvisitcount is null or actvisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (actvisitcount/(expvisitcount*1.000)) > 1
									 then
									 1
								 else
									 actvisitcount/(expvisitcount*1.000)
							 end
					 end
					,case
						 when inhomevisitcount is null or inhomevisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)) > 1
									 then
									 1
								 else
									 inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)
							 end
					 end
					,dischargedate
					,IntakeDate
					,TCDOB
					,LevelChanges
		 from @cteSummary
	
	declare @cteMainWithScores table (
	    workername char(50)
		,workerfk int
		,pc1id char(15)
		,casecount int
		,DirectServiceTime datetime
		,expvisitcount int
		,startdate datetime
		,enddate datetime
		,levelname char(50)
		,levelstart datetime
		,actvisitcount int
		,inhomevisitcount int
		,attvisitcount int
		,VisitRate float
		,InHomeRate float
		,dischargedate datetime
		,IntakeDate datetime
		,TCDOB datetime
		,LevelChanges int
		,ScoreForCase int
	) 
	insert into @cteMainWithScores 
	select *
		  ,case
			   when expvisitcount = 0
				   then
				   0
			   when VisitRate >= .9 and InHomeRate >= .75
				   then
				   3
			   when VisitRate >= .75 and InHomeRate >= .75
				   then
				   2
			   else
				   1
		   end as ScoreForCase
		from @cteMain
	
	select *
			,case when ScoreForCase=1 then 1 else 0 end as ScoreForCase1
			,case when ScoreForCase=2 then 1 else 0 end as ScoreForCase2
			,case when ScoreForCase=3 then 1 else 0 end as ScoreForCase3
		from @cteMainWithScores
		where expvisitcount > 0
				and not (levelname = 'Level X' and levelstart < @sdate)
		order by WorkerName
				,pc1id

end

GO
