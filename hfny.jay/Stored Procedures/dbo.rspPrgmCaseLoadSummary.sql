
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn> dar chen
-- Create date: <12/04/2012>
-- Description: <Report: Program caseload summary (PrmgCaseLoadSummary)>
-- exec rspPrgmCaseLoadSummary '2013-06-26', '23'
-- =============================================
CREATE procedure [dbo].[rspPrgmCaseLoadSummary]
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

	set @programfk = REPLACE(@programfk,'"','');
	
	with cteData as
		(
			-- part 1 of 3 pronged sub-select
			select hvl.HVCaseFK
					, hvl.ProgramFK
					, hvl.LevelAssignDate as FSWAssignDate
					, LevelName
					, case when LevelName='Preintake' then 1 else 0 end as PreintakeCount
					, case when LevelName='Level 1' then 1 else 0 end as Level1Count
					, case when LevelName='Level 2' then 1 else 0 end as Level2Count
					, case when LevelName='Level 3' then 1 else 0 end as Level3Count
					, case when LevelName='Level 4' then 1 else 0 end as Level4Count
					, case when LevelName='Level 1-SS' then 1 else 0 end as Level1SSCount
					, case when LevelName='Level 1-Prenatal' then 1 else 0 end as Level1PrenatalCount
					, case when LevelName='Level X' then 1 else 0 end as LevelXCount
					, CaseWeight
			  from HVLevel hvl
				  inner join codeLevel on codeLevelPK = LevelFK
				  inner join (select HVCaseFK, ProgramFK, max(LevelAssignDate) as LevelAssignDate
							  from HVLevel h2 
							  where LevelAssignDate <= @rpdate
							  group by HVCaseFK, ProgramFK) e2 on e2.HVCaseFK = hvl.HVCaseFK 
																	and e2.ProgramFK = hvl.ProgramFK
																	and e2.LevelAssignDate = hvl.LevelAssignDate
				  inner join dbo.SplitString(@ProgramFK,',') on hvl.ProgramFK = ListItem
			union all		   
			-- part 2 of 3 pronged sub-select
			-- get cases at preintake level
			select cp.HVCaseFK
					, cp.ProgramFK
					, FSWAssignDate
					, 'Preintake' as LevelName
					, 1 as PreintakeCount
					, 0 as Level1Count
					, 0 as Level2Count
					, 0 as Level3Count
					, 0 as Level4Count
					, 0 as Level1SSCount
					, 0 as Level1PrenatalCount
					, 0 as LevelXCount
					, CaseWeight
			  from HVCase
				  inner join CaseProgram cp on cp.HVCaseFK = HVCasePK
				  inner join (select HVCaseFK
									,ProgramFK
									,max(KempeDate) as KempeDate
									,max(FSWAssignDate) as FSWAssignDate
								  from Preassessment
								  group by HVCaseFK
										  ,ProgramFK) p on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK
				  left outer join HVLevel hl on hl.HVCaseFK = cp.HVCaseFK and hl.ProgramFK = cp.ProgramFK and hl.LevelAssignDate <= @rpdate
				  inner join codeLevel l on codeLevelPK = 7
				  inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			  where (IntakeDate is null
						or IntakeDate > @rpdate)
						and (DischargeDate is null
						or DischargeDate > @rpdate)
						and (FSWAssignDate is not null
						and FSWAssignDate < @rpdate)
						and hl.HVLevelPK is null
			union all
			-- part 3 of 3 pronged sub-select
			-- get cases at preintake-enroll level
			select cp.HVCaseFK
					, cp.ProgramFK
					, FSWAssignDate
					, 'Preintake' as LevelName
					, 0 as PreintakeCount
					, 0 as Level1Count
					, 0 as Level2Count
					, 0 as Level3Count
					, 0 as Level4Count
					, 0 as Level1SSCount
					, 0 as Level1PrenatalCount
					, 0 as LevelXCount
					, CaseWeight
			  from HVCase
				  inner join CaseProgram cp on cp.hvcasefk = hvcasepk
				  inner join (select HVCaseFK
									,ProgramFK
									,max(KempeDate) as KempeDate
									,max(FSWAssignDate) as FSWAssignDate
								  from Preassessment
								  group by HVCaseFK
										  ,ProgramFK) p on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK
				  left outer join HVLevel hl on hl.HVCaseFK = cp.HVCaseFK and hl.ProgramFK = cp.ProgramFK and hl.LevelAssignDate <= @rpdate
				  inner join codeLevel l on codeLevelPK = 8
				  inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			  where (IntakeDate is not null
						or IntakeDate <= @rpdate)
						and (DischargeDate is null
						or DischargeDate > @rpdate)
						and (FSWAssignDate is not null
						and FSWAssignDate < @rpdate)
						and hl.HVLevelPK is null
		), 
		cteMain as
		(
			select PC1ID
					, rtrim(d.LevelName) as LevelName
					, PreintakeCount
					, Level1Count
					, Level2Count
					, Level3Count
					, Level4Count
					, Level1SSCount
					, Level1PrenatalCount
					, LevelXCount
					, d.CaseWeight
					, rtrim(w.FirstName) as WorkerFirstName
					, rtrim(w.LastName) as WorkerLastName
					, w.WorkerPK
					, StartAssignmentDate
					, EndAssignmentDate
					, FSWAssignDate
			from cteData d
				inner join CaseProgram cp on d.HVCaseFK = cp.HVCaseFK and d.ProgramFK = cp.ProgramFK
				inner join WorkerAssignmentDetail wad on wad.programfk = cp.ProgramFK 
															and wad.hvcasefk = cp.HVCaseFK 
															and FSWAssignDate between StartAssignmentDate and isnull(EndAssignmentDate,FSWAssignDate)
				inner join Worker w on WorkerPK = cp.currentfswfk --on workerpk = wad.workerfk				  
				inner join dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = ListItem
			where (DischargeDate is null
				 or DischargeDate >= @rpdate)
			--order by PC1ID
			--		, StartAssignmentDate
			--		, WorkerLastName
			--		, WorkerFirstName
		)

	select * from cteMain
	order by WorkerFirstName
				, WorkerLastName
				, PC1ID
				, StartAssignmentDate
				
	--select WorkerFirstName
	--		, WorkerLastName
	--		, count(PC1ID) as CaseCount
	--		, sum(CaseWeight) as TotalCaseWeight
	--		, sum(PreintakeCount) as PreintakeCount
	--		, sum(PreintakeEnrollCount) as PreintakeEnrollCount
	--		, sum(Level1Count) as Level1Count
	--		, sum(Level2Count) as Level2Count
	--		, sum(Level3Count) as Level3Count
	--		, sum(Level4Count) as Level4Count
	--		, sum(Level1SSCount) as Level1SSCount
	--		, sum(Level1PrenatalCount) as Level1PrenatalCount
	--		, sum(LevelXCount) as LevelXCount
	--from cteMain
	--where LevelName = 'Preintake'
	--group by WorkerFirstName, WorkerLastName
	--order by WorkerFirstName
	---- order by HVCaseFK

GO
