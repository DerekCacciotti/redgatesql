SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn> dar chen
-- Create date: <12/04/2012>
-- Description: <Report: Program caseload summary (PrmgCaseLoadSummary)>
-- =============================================
create procedure [dbo].[rspPrgmCaseLoadSummary]
(
    @rpdate    datetime,
    @programfk varchar(max)    = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select pc1id
		  ,rtrim(e3.levelname) levelname
		  
	   	, PreintakeCount
		  , Level1Count
		  , Level2Count
		  , Level3Count
		  , Level4Count
		  , Level1SSCount
		  , Level1PrenatalCount
		  , LevelXCount
		  
		  ,e3.caseweight
		  ,rtrim(worker.firstname) as wfname
		  ,rtrim(worker.lastname) as wlname
		  ,worker.workerpk
		  ,startassignmentdate
		  ,endassignmentdate
		  ,levelassigndate
		-- get cases at all levels (level prior to intake are never in the hvlevel table)
		from (select hvlevel.hvcasefk
					,hvlevel.programfk
					,hvlevel.levelassigndate
					,levelname
					
					,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
				  ,case when levelname='Level 1' then 1 else 0 end as Level1Count
				  ,case when levelname='Level 2' then 1 else 0 end as Level2Count
				  ,case when levelname='Level 3' then 1 else 0 end as Level3Count
				  ,case when levelname='Level 4' then 1 else 0 end as Level4Count
				  ,case when levelname='Level 1-SS' then 1 else 0 end as Level1SSCount
				  ,case when levelname='Level 1-Prenatal' then 1 else 0 end as Level1PrenatalCount
				  ,case when levelname='Level X' then 1 else 0 end as LevelXCount
					
					
					
					,caseweight
				  from hvlevel
					  inner join codelevel on codelevelpk = levelfk
					  inner join (select hvcasefk ,programfk ,max(levelassigndate) as levelassigndate
								  from hvlevel h2 where levelassigndate <= @rpdate
								  group by hvcasefk ,programfk) e2 
								  on e2.hvcasefk = hvlevel.hvcasefk and e2.programfk = hvlevel.programfk 
								  and e2.levelassigndate = hvlevel.levelassigndate
			  union
			  -- get cases at preintake level
			  select cp.hvcasefk
					,cp.programfk
					,fswassigndate
					,'Preintake'
					
				  , 1 as PreintakeCount
				  , 0 as Level1Count
				  , 0 as Level2Count
				  , 0 as Level3Count
				  , 0 as Level4Count
				  , 0 as Level1SSCount
				  , 0 as Level1PrenatalCount
				  , 0 as LevelXCount
					
					
					
					,caseweight
				  from hvcase
					  inner join caseprogram cp on cp.hvcasefk = hvcasepk
					  inner join (select hvcasefk
										,programfk
										,max(kempedate) kempedate
										,max(fswassigndate) fswassigndate
									  from preassessment
									  group by hvcasefk
											  ,programfk) p on cp.hvcasefk = p.hvcasefk and cp.programfk = p.programfk
					  left outer join hvlevel hl on hl.hvcasefk = cp.hvcasefk and hl.programfk = cp.programfk and hl.levelassigndate <= @rpdate
					  inner join codelevel on codelevelpk = 9
				  where (intakedate is null
					   or intakedate > @rpdate)
					   and (dischargedate is null
					   or dischargedate > @rpdate)
					   and (fswassigndate is not null
					   and fswassigndate < @rpdate)
					   and hl.hvlevelpk is null
			  union
			  -- get cases at preintake-enroll level
			  select cp.hvcasefk
					,cp.programfk
					,fswassigndate
					,'Preintake'
					 , 1 as PreintakeCount
				  , 0 as Level1Count
				  , 0 as Level2Count
				  , 0 as Level3Count
				  , 0 as Level4Count
				  , 0 as Level1SSCount
				  , 0 as Level1PrenatalCount
				  , 0 as LevelXCount
					,caseweight
				  from hvcase
					  inner join caseprogram cp on cp.hvcasefk = hvcasepk
					  inner join (select hvcasefk
										,programfk
										,max(kempedate) kempedate
										,max(fswassigndate) fswassigndate
									  from preassessment
									  group by hvcasefk
											  ,programfk) p on cp.hvcasefk = p.hvcasefk and cp.programfk = p.programfk
					  left outer join hvlevel hl on hl.hvcasefk = cp.hvcasefk and hl.programfk = cp.programfk and hl.levelassigndate <= @rpdate
					  inner join codelevel on codelevelpk = 10
				  where (intakedate is not null
					   or intakedate <= @rpdate)
					   and (dischargedate is null
					   or dischargedate > @rpdate)
					   and (fswassigndate is not null
					   and fswassigndate < @rpdate)
					   and hl.hvlevelpk is null) e3
			inner join caseprogram on e3.hvcasefk = caseprogram.hvcasefk and e3.programfk = caseprogram.programfk
			inner join workerassignmentdetail wad on wad.programfk = caseprogram.programfk and wad.hvcasefk = caseprogram.hvcasefk and levelassigndate between startassignmentdate and isnull(endassignmentdate,levelassigndate)
			inner join worker
					  --on workerpk = wad.workerfk
					  on workerpk = caseprogram.currentfswfk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where (dischargedate is null
			 or dischargedate >= @rpdate)
		order by pc1id
				,startassignmentdate
				,wlname
				,wfname
GO
