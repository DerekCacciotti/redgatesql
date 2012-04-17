SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
-- =============================================
CREATE procedure [dbo].[rspHVAchievementRate_Aggregate](@programfk    varchar(max)    = null,
                                                       @sdate        datetime,
                                                       @edate        datetime,
                                                       @supervisorfk int             = null,
                                                       @workerfk     int             = null
                                                       )

as

begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','');


	with cteMain
	as
	(select distinct rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,FLOOR(reqvisit) as expvisitcount
					,sum(case
							 when visittype <> '0001' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when visittype = '0001' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			 inner join worker on workerpk = hvr.workerfk
			 inner join workerprogram wp on wp.workerfk = workerpk
			 inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
		 where workerpk = isnull(@workerfk,workerpk)
			  and supervisorfk = isnull(@supervisorfk,supervisorfk)
			  and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
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
	)
	-- make the aggregate table
	select workername
		  ,workerfk
		  ,pc1id
		  ,casecount
		  ,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
		  ,expvisitcount
		  ,startdate
		  ,enddate
		  ,levelname
		  ,levelstart
		  ,actvisitcount
		  ,attvisitcount
		  ,dischargedate
		from (
			  select distinct workername
							 ,workerfk
							 ,pc1id
							 ,casecount
							 ,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
							 ,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
							 ,min(startdate) over (partition by pc1wrkfk) as 'startdate'
							 ,max(enddate) over (partition by pc1wrkfk) as 'enddate'
							 ,(select top 1 levelname
								   from CTEMAIN
								   where enddate <= @edate) as levelname
							 ,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
							 ,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
							 ,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
							 ,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
				  from CTEMAIN
			 ) a

end
GO
