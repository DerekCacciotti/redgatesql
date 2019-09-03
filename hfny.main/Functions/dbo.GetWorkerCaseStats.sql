SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Function:	GetWorkerCaseStats
-- Author:		jrobohn
-- Create date: Apr. 8, 2019
-- Description:	Get supervisor's casecount and most frequent
--				case visit count for assigned cases
-- =============================================
CREATE function [dbo].[GetWorkerCaseStats]
(
	@ProgramFK int,
		@StartPeriod date, 
		@EndPeriod date	
)
returns 
@WorkerCaseStats table 
(
	WorkerPK int, 
	MostFrequentVisitCount numeric(5,2), 
	CaseCount int
)
AS
BEGIN
	; with cteStartCases as 
	(
		select cp.CurrentFSWFK as WorkerFK
				, cp.HVCaseFK
				, cl.MinimumVisit
		from CaseProgram cp
		inner join WorkerAssignmentDetail wad on wad.HVCaseFK = cp.HVCaseFK 
											and wad.WorkerFK = cp.CurrentFSWFK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		inner join Worker w on w.WorkerPK = wad.WorkerFK
		where wad.StartAssignmentDate <= @StartPeriod
				and isnull(wad.EndAssignmentDate, @EndPeriod) >= @EndPeriod
				and cl.MinimumVisit <> 0
	) 
	
	insert into @WorkerCaseStats (WorkerPK
									, MostFrequentVisitCount
									, CaseCount)
	select WorkerFK
			, max(MinimumVisit) as MostFrequentVisitCount
			, count(HVCaseFK) as CaseCount
	from cteStartCases
	group by WorkerFK
	return
end
GO
