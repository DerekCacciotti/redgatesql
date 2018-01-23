SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn> dar chen
-- Create date: <12/04/2012>
-- Description: <Report: Program caseload summary (PrmgCaseLoadSummary)>
-- exec rspPrgmCaseLoadSummary '2013-06-26', '23'
-- exec dbo.rspPrgmCaseLoadSummary @rpdate = '2017-01-01' -- datetime
--							, @programfk = '26' -- varchar(max)
-- =============================================
CREATE procedure [dbo].[rspPrgmCaseLoadSummary]
(
    @rpdate    DATETIME,
    @programfk VARCHAR(MAX) = null
)
as 
begin
	IF @programfk IS NULL
	BEGIN
		SELECT @programfk = SUBSTRING((
			SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
			FROM HVProgram
			FOR XML PATH ('')
		),2,8000)
	END

	SET @programfk = REPLACE(@programfk,'"','');
	
	WITH 
	cteData AS (
		-- post-intake
		SELECT 
			hvl.HVCaseFK
			, hvl.ProgramFK
			, hvl.LevelAssignDate AS FSWAssignDate
			, LevelAbbr
			, codeLevelPK
			, CaseWeight
		FROM 
			HVLevel hvl
			INNER JOIN codeLevel ON codeLevelPK = LevelFK
			INNER JOIN (
				-- most recent level assignments
				SELECT
					HVCaseFK
					, ProgramFK
					, MAX(LevelAssignDate) AS LevelAssignDate
				FROM
					HVLevel h2 
				WHERE
					LevelAssignDate <= @rpdate
				GROUP BY
					HVCaseFK
					, ProgramFK
			) e2 ON e2.HVCaseFK = hvl.HVCaseFK 
				AND e2.ProgramFK = hvl.ProgramFK
				AND e2.LevelAssignDate = hvl.LevelAssignDate
			inner join dbo.SplitString(@ProgramFK,',') ON e2.ProgramFK = ListItem
			inner join dbo.CaseProgram cp on cp.HVCaseFK = e2.HVCaseFK
			inner join dbo.HVCase hc on hc.HVCasePK = cp.HVCaseFK
			where (IntakeDate is not null and IntakeDate <= @rpdate)
					and (DischargeDate IS NULL OR DischargeDate > @rpdate)
		UNION ALL

		-- pre-intake
		SELECT
			cp.HVCaseFK
			, cp.ProgramFK
			, FSWAssignDate
			, 'Pre-Int' as LevelAbbr
			, 8 as codeLevelPK
			, 0.5 as CaseWeight
			--, cp.PC1ID 
			--, hc.ScreenDate
			--, hc.KempeDate
			--, hc.IntakeDate
			--, cp.DischargeDate
		FROM
			HVCase hc
			INNER JOIN CaseProgram cp ON cp.HVCaseFK = HVCasePK
			INNER JOIN (
				SELECT
					HVCaseFK
					,ProgramFK
					,MAX(KempeDate) AS KempeDate
					,MAX(FSWAssignDate) AS FSWAssignDate
				FROM
					Preassessment
				GROUP BY
					HVCaseFK
					,ProgramFK
			) p ON cp.HVCaseFK = p.HVCaseFK 
					AND cp.ProgramFK = p.ProgramFK
			--LEFT OUTER JOIN HVLevel hl ON hl.HVCaseFK = cp.HVCaseFK 
			--	AND hl.ProgramFK = cp.ProgramFK 
			--	AND hl.LevelAssignDate <= @rpdate
			--INNER JOIN codeLevel l ON Enrolled = 0 and CaseWeight > 0 AND cp.currentLevelFK = l.codeLevelPK -- captures all pre-intake levels with caseweights
			INNER JOIN dbo.SplitString(@programfk,',') ON cp.programfk = listitem
		WHERE
			(IntakeDate IS NULL OR IntakeDate > @rpdate)
			AND (DischargeDate IS NULL OR DischargeDate > @rpdate)
			AND (FSWAssignDate IS NOT NULL AND FSWAssignDate < @rpdate) 
			--AND hl.HVLevelPK IS NULL
	)
	
	--select d.*, cp.PC1ID 
	--		, hc.ScreenDate
	--		, hc.KempeDate
	--		, hc.IntakeDate
	--		, cp.DischargeDate
	--from cteData d
	--inner join dbo.CaseProgram cp on cp.HVCaseFK = d.HVCaseFK
	--inner join dbo.HVCase hc on hc.HVCasePK = cp.HVCaseFK
	--order by cp.PC1ID
	--select * from dbo.codeLevel cl

	,

	cteMain AS (
		SELECT 
			PC1ID
			, rtrim(d.LevelAbbr) AS LevelName
			, d.codeLevelPK
			, d.CaseWeight
			, rtrim(w.FirstName) AS WorkerFirstName
			, rtrim(w.LastName) AS WorkerLastName
			, w.WorkerPK
			, StartAssignmentDate
			, EndAssignmentDate
			, FSWAssignDate
		FROM 
			cteData d
			INNER JOIN CaseProgram cp ON d.HVCaseFK = cp.HVCaseFK 
				AND d.ProgramFK = cp.ProgramFK
			INNER JOIN WorkerAssignmentDetail wad ON wad.programfk = cp.ProgramFK 
				AND wad.hvcasefk = cp.HVCaseFK 
				AND @rpdate between StartAssignmentDate AND ISNULL(EndAssignmentDate, @rpdate)
			INNER JOIN Worker w ON WorkerPK = wad.WorkerFK
			INNER JOIN dbo.SplitString(@ProgramFK,',') ON cp.ProgramFK = ListItem
		WHERE 
			(DischargeDate IS NULL OR DischargeDate >= @rpdate)
	)

	SELECT DISTINCT
		*
	FROM
		cteMain
	ORDER BY
		WorkerLastName
		, WorkerFirstName
		, PC1ID
		, StartAssignmentDate
end
GO
