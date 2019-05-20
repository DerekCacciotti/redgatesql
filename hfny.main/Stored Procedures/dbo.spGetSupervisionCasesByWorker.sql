SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Description:	Gets all open cases, ordered by passed worker first, 
--				then cases assigned to others
-- exec spGetCasesByWorker @WorkerFK = 2147, @ProgramFK = 17
-- exec spGetCasesByWorker @WorkerFK = 943, @ProgramFK = 17, @SupervisionDate = '2018-09-01'
-- =============================================
create procedure [dbo].[spGetSupervisionCasesByWorker] (
	@WorkerFK as int, 
	@ProgramFK as int,
	@SupervisionDate date
)
as 
begin 
	set noCount on;

    -- Insert statements for procedure here
	with cteMain as
	(
		select HVCaseFK
				, 'Home Visit' as CaseType
				, PC1ID
				, cl.LevelName as CurrentLevelName
				, case when CurrentFSWFK = @WorkerFK then 1 else 0 end as Assigned
				, case when DischargeDate is null then 0 else 1 end as Discharged
				, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
				, convert(date, null) as LastDiscussion
				, convert(int, null) as DaysSince
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
				, 'Parent Survey' as CaseType
				, PC1ID
				, cl.LevelName as CurrentLevelName
				, case when CurrentFAWFK = @WorkerFK then 1 else 0 end as Assigned
				, case when DischargeDate is null then 0 else 1 end as Discharged
				, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
				, convert(date, null) as LastDiscussion
				, convert(int, null) as DaysSince
		from CaseProgram cp
		inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
		inner join Worker w on w.WorkerPK = cp.CurrentFAWFK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		where cp.ProgramFK = @ProgramFK
				--and IntakeDate is not null
				and (hc.KempeDate is null or hc.KempeDate > dateadd(month, -3, current_Timestamp))
				and (DischargeDate is null or 
						cp.DischargeDate > dateadd(month, -6, current_Timestamp))
	)
	, cteLastHomeVisitDiscussion as
	(
		select shvc.HVCaseFK
				, max(convert(date, SupervisionDate)) as LastHVSupervisionDate
		from SupervisionHomeVisitCase shvc
		inner join  Supervision s on s.SupervisionPK = shvc.SupervisionFK
		inner join cteMain m on m.HVCaseFK = shvc.HVCaseFK
		where SupervisionDate < @SupervisionDate
				and shvc.InDepthDiscussion = 1
		group by shvc.HVCaseFK
	)	
	, cteLastParentSurveyDiscussion as
	(
		select spsc.HVCaseFK
				, max(convert(date, SupervisionDate)) as LastPSSupervisionDate
		from SupervisionParentSurveyCase spsc
		inner join  Supervision s on s.SupervisionPK = spsc.SupervisionFK
		inner join cteMain m on m.HVCaseFK = spsc.HVCaseFK
		where SupervisionDate < @SupervisionDate
				and spsc.InDepthDiscussion = 1
		group by spsc.HVCaseFK
	)
	select m.HVCaseFK
			, m.CaseType
			, m.PC1ID
			, m.CurrentLevelName
			, case when m.Assigned = 1 then 'Current' else 'Other' end as Assigned
			, case when m.Discharged = 1 then 'Discharged' else 'Active' end as Discharged
			, m.WorkerName
			, m.LastDiscussion
			, m.DaysSince
			, lhvd.HVCaseFK as HVHVCaseFK
			, lhvd.LastHVSupervisionDate
			, datediff(day, lhvd.LastHVSupervisionDate, @SupervisionDate) as LastHVDays
			, lpsd.HVCaseFK as PSHVCaseFK
			, lpsd.LastPSSupervisionDate
			, datediff(day, lpsd.LastPSSupervisionDate, @SupervisionDate) as LastPSDays
	from cteMain m
	left outer join cteLastHomeVisitDiscussion lhvd on lhvd.HVCaseFK = m.HVCaseFK
	left outer join cteLastParentSurveyDiscussion lpsd on lpsd.HVCaseFK = m.HVCaseFK
	order by Assigned
				, Discharged
				, CaseType
				, m.PC1ID ;
end
GO
