SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Description:	Gets all open cases, ordered by passed worker first, then cases assigbned to others
-- exec spGetCasesByWorker @WorkerFK = 2147, @ProgramFK = 17
-- exec spGetCasesByWorker @WorkerFK = 943, @ProgramFK = 17
-- =============================================
CREATE procedure [dbo].[spGetCasesByWorker]
	@WorkerFK as int, 
	@ProgramFK as int
as 
begin 
	set noCount on;

    -- Insert statements for procedure here
	select HVCaseFK
			, 'HV' as CaseType
			, PC1ID
			, cl.LevelName as CurrentLevelName
			, case when CurrentFSWFK = @WorkerFK then 1 else 0 end as Assigned
			, case when DischargeDate is null then 0 else 1 end as Discharged
			, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
	from CaseProgram cp
	inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
	inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
	inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
	where cp.ProgramFK = @ProgramFK
			and IntakeDate is not null
			and (DischargeDate is null or 
					cp.DischargeDate > dateadd(month, -6, current_Timestamp))
	union all
	select HVCaseFK
			, 'PS' as CaseType
			, PC1ID
			, cl.LevelName as CurrentLevelName
			, case when CurrentFAWFK = @WorkerFK then 1 else 0 end as Assigned
			, case when DischargeDate is null then 0 else 1 end as Discharged
			, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
	from CaseProgram cp
	inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
	inner join Worker w on w.WorkerPK = cp.CurrentFAWFK
	inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
	where cp.ProgramFK = @ProgramFK
			--and IntakeDate is not null
			and (hc.KempeDate is null or hc.KempeDate > dateadd(month, -2, current_Timestamp))
			and (DischargeDate is null or 
					cp.DischargeDate > dateadd(month, -6, current_Timestamp))
	order by Assigned desc
				, Discharged
				, CaseType
				, cp.PC1ID
end
GO
