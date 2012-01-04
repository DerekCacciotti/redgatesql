SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
-- =============================================
create procedure [dbo].[rspHVAchievementRate_Aggregate](
	@programfk varchar(max) = null, 
	@sdate datetime, @edate datetime, 
	@supervisorfk INT=NULL, @workerfk INT=NULL)

as

IF @programfk IS NULL BEGIN
	SELECT @programfk = 
		SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
					FROM HVProgram
					FOR XML PATH('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','');


WITH cteMain
AS
(SELECT distinct rtrim(firstname)+' '+rtrim(lastname) as workername, hvr.workerfk,
	count(distinct casefk) as casecount, 
	pc1id,startdate,enddate,hvr.levelname, 
	(select max(hld.StartLevelDate) from hvleveldetail hld 
		where hvr.casefk=hld.hvcasefk AND StartLevelDate<=@edate
		and hvr.programfk = hld.programfk) as levelstart,
	FLOOR(reqvisit) as expvisitcount, 
	sum(case when visittype<>'001' then 1 Else 0 End) as actvisitcount,
	sum(case when visittype='001' then 1 Else 0 End) as attvisitcount,
	(dateadd(mi, sum(visitlengthminute), dateadd(hh, sum(visitlengthhour), '01/01/2001'))) DirectServiceTime,
	sum(visitlengthminute) + sum(visitlengthhour)*60 as visitlengthminute,
	sum(visitlengthhour) as visitlengthhour,
	dischargedate,
	pc1id+CONVERT(CHAR(10),hvr.workerfk) AS pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
from [dbo].[udfHVRecords](@programfk, @sdate, @edate) hvr
INNER JOIN worker
ON workerpk = hvr.workerfk
inner join workerprogram wp
on wp.workerfk = workerpk
INNER JOIN dbo.SplitString(@programfk,',')
ON wp.programfk  = listitem
where workerpk = isnull(@workerfk, workerpk)
and supervisorfk = isnull(@supervisorfk, supervisorfk)
and startdate<enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
Group by firstname,lastname,hvr.workerfk,pc1id,startdate,enddate,hvr.levelname,reqvisit,dischargedate, hvr.casefk, hvr.programfk--,hld.StartLevelDate
)
-- make the aggregate table
SELECT 
workername, workerfk, pc1id, casecount,
dateadd(yy,(2003-1900),0) + dateadd(mm,11-1,0) + 6-1 + dateadd(mi,minutes,0)as DirectServiceTime,
expvisitcount, startdate, enddate,levelname,
levelstart, actvisitcount, attvisitcount,
dischargedate
FROM(
SELECT distinct workername, workerfk, pc1id, casecount
,SUM(visitlengthminute) OVER(PARTITION BY pc1wrkfk) AS 'Minutes'
,SUM(expvisitcount) OVER(PARTITION BY pc1wrkfk) AS expvisitcount,
MIN(startdate) OVER(PARTITION BY pc1wrkfk) AS 'startdate',
MAX(enddate) OVER(PARTITION BY pc1wrkfk) AS 'enddate',
(SELECT TOP 1 levelname FROM CTEMAIN WHERE enddate<=@edate) AS levelname
,MAX(levelstart) OVER(PARTITION BY pc1wrkfk) AS 'levelstart',
SUM(actvisitcount) OVER(PARTITION BY pc1wrkfk) AS actvisitcount,
SUM(attvisitcount) OVER(PARTITION BY pc1wrkfk) AS attvisitcount,
MAX(dischargedate) OVER(PARTITION BY pc1wrkfk) AS 'dischargedate'
FROM CTEMAIN
) a
GO
