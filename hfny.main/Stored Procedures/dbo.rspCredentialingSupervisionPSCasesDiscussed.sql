SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure:	rspCredentialingSupervisionPSCasesDiscussed
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Description:	Returns a list of open cases and last discussed
--				date or time since assessment. 
--				Ordered by worker and then PC1ID.
-- exec rspCredentialingSupervisionPSCasesDiscussed 17, '2019-03-01', '2019-03-31', null, null, null
-- exec rspCredentialingSupervisionPSCasesDiscussed 1, '2019-03-01', '2019-03-31', null, 2375, null
-- exec rspCredentialingSupervisionPSCasesDiscussed 1, '2019-03-01', '2019-03-31', 2466, null, null
-- exec rspCredentialingSupervisionPSCasesDiscussed 1, '2019-03-01', '2019-03-31', null, null, 2
-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervisionPSCasesDiscussed]

	(@ProgramFK int = null
		, @StartDate datetime = null
		, @EndDate datetime = null
		, @SupervisorFK int = null
		, @WorkerFK int = null
		, @SiteFK int = null
	)
as

begin
	set noCount on;

	with cteMain as
	(
		select HVCaseFK
				, 'Parent Survey' as CaseType
				, PC1ID
				, cl.LevelName as CurrentLevelName
				, convert(date, CaseStartDate) as CaseStartDate
				, convert(date, KempeDate)	   as KempeDate
				, convert(date, IntakeDate)	   as IntakeDate
				, convert(date, DischargeDate) as DischargeDate
				, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
		from CaseProgram cp
		inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
		inner join Worker w on w.WorkerPK = cp.CurrentFAWFK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		where cp.ProgramFK = @ProgramFK
		-- made change here
		AND cp.CurrentFSWFK = ISNULL(@WorkerFK, cp.CurrentFSWFK)
				--and IntakeDate is not null
				--and (hc.KempeDate is null or hc.KempeDate > dateadd(month, -3, current_Timestamp))
				and CaseProgress < 10
				and (DischargeDate is null or 
						cp.DischargeDate > dateadd(month, -6, current_Timestamp))
	)
	, cteLastParentSurveyDiscussion as
	(
		select spsc.HVCaseFK
				, max(convert(date, SupervisionDate)) as LastPSSupervisionDate
		from SupervisionParentSurveyCase spsc
		inner join  Supervision s on s.SupervisionPK = spsc.SupervisionFK
		inner join cteMain m on m.HVCaseFK = spsc.HVCaseFK
		where SupervisionDate < @EndDate
				and spsc.InDepthDiscussion = 1
		group by spsc.HVCaseFK
	)
	select m.HVCaseFK
			, m.CaseType
			, m.PC1ID
			, m.CurrentLevelName
			, m.CaseStartDate
			, m.KempeDate
			, m.IntakeDate
			, m.DischargeDate
			, m.WorkerName
			, lpsd.HVCaseFK as PSHVCaseFK
			, convert(date, lpsd.LastPSSupervisionDate) 
				as LastPSSupervisionDate
			, datediff(day, lpsd.LastPSSupervisionDate, @EndDate) 
				as LastPSDaysSince
			, datediff(day, m.KempeDate, @EndDate) as ElapsedTime
	from cteMain m
	left outer join cteLastParentSurveyDiscussion lpsd on lpsd.HVCaseFK = m.HVCaseFK
	order by m.WorkerName
				, isnull(datediff(day, lpsd.LastPSSupervisionDate, @EndDate), 9999) desc
				, ElapsedTime desc ;
end
GO
