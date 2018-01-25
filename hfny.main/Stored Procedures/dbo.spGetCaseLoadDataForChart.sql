SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spGetCaseLoadDataForChart] 
					(@programFK int, @rpdate date, @username varchar(255))
					
as
	begin
		with cteData
		as (
			-- post-intake
			select		hvl.HVCaseFK
					, hvl.ProgramFK
					, hvl.LevelAssignDate as FSWAssignDate
					, LevelAbbr
					, codeLevelPK
					, CaseWeight
			from		HVLevel hvl
			inner join	codeLevel on codeLevelPK = LevelFK
			inner join	(
						-- most recent level assignments
						select		HVCaseFK
								, ProgramFK
								, max(LevelAssignDate) as LevelAssignDate
						from		HVLevel h2
						where		LevelAssignDate <= @rpdate
						group by	HVCaseFK
								, ProgramFK
						) e2 on e2.HVCaseFK = hvl.HVCaseFK and e2.ProgramFK = hvl.ProgramFK
								and e2.LevelAssignDate = hvl.LevelAssignDate
			inner join	dbo.SplitString(@ProgramFK, ',') on e2.ProgramFK = ListItem
			inner join	dbo.CaseProgram cp on cp.HVCaseFK = e2.HVCaseFK
			inner join	dbo.HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join dbo.Worker w on w.WorkerPK = cp.CurrentFSWFK
			where		(IntakeDate is not null and IntakeDate <= @rpdate)
						and (DischargeDate is null or DischargeDate > @rpdate)
						and w.UserName = @username
			union all

			-- pre-intake
			select		cp.HVCaseFK
					, cp.ProgramFK
					, FSWAssignDate
					, 'Pre-Int' as LevelAbbr
					, 8 as codeLevelPK
					, 0.5 as CaseWeight
			from		HVCase hc
			inner join	CaseProgram cp on cp.HVCaseFK = HVCasePK
			inner join	(
						select		HVCaseFK
								, ProgramFK
								, max(KempeDate) as KempeDate
								, max(FSWAssignDate) as FSWAssignDate
						from		Preassessment
						group by	HVCaseFK
								, ProgramFK
						) p on cp.HVCaseFK = p.HVCaseFK and cp.ProgramFK = p.ProgramFK
			inner join	dbo.SplitString(@programfk, ',') on cp.ProgramFK = ListItem
			inner join dbo.Worker w on w.WorkerPK = cp.CurrentFSWFK
			where		(IntakeDate is null or IntakeDate > @rpdate)
						and (DischargeDate is null or DischargeDate > @rpdate)
						and (FSWAssignDate is not null and FSWAssignDate < @rpdate)
						and w.UserName = @username
		)

		, cteMain
		as (
			select		PC1ID
					, rtrim(d.LevelAbbr) as LevelName
					, d.codeLevelPK
					, d.CaseWeight
					, rtrim(w.FirstName) as WorkerFirstName
					, rtrim(w.LastName) as WorkerLastName
					, w.WorkerPK
					, StartAssignmentDate
					, EndAssignmentDate
					, FSWAssignDate
			from		cteData d
			inner join	CaseProgram cp on d.HVCaseFK = cp.HVCaseFK and d.ProgramFK = cp.ProgramFK
			inner join	WorkerAssignmentDetail wad on wad.ProgramFK = cp.ProgramFK
													and wad.HVCaseFK = cp.HVCaseFK
													and @rpdate between StartAssignmentDate and 
																		isnull(EndAssignmentDate, @rpdate)
			inner join	Worker w on WorkerPK = wad.WorkerFK
			inner join	dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
			where		(DischargeDate is null or DischargeDate >= @rpdate)
		)

		select	@rpdate as ReportDate
				, left(convert(char(3), @rpdate, 7), 3) as ReportMonth
				, sum(CaseWeight) as CaseWeight
		from		cteMain

end
GO
