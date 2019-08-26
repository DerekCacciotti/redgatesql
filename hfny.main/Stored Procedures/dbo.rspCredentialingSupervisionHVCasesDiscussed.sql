SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure:	rspCredentialingSupervisionHVCasesDiscussed
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Description:	Returns a list of open cases and last discussed
--				date or time since intake. 
--				Ordered by worker and then PC1ID.
-- exec rspCredentialingSupervisionHVCasesDiscussed 17, '2019-03-01', '2019-03-31', null, null, null
-- exec rspCredentialingSupervisionHVCasesDiscussed 1, '2019-03-01', '2019-03-31', null, 2375, null
-- exec rspCredentialingSupervisionHVCasesDiscussed 1, '2019-03-01', '2019-03-31', 2466, null, null
-- exec rspCredentialingSupervisionHVCasesDiscussed 1, '2019-03-01', '2019-03-31', null, null, 2
-- =============================================
CREATE procedure [dbo].[rspCredentialingSupervisionHVCasesDiscussed]

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
				, 'Home Visit' as CaseType
				, PC1ID
				, cl.LevelName as CurrentLevelName
				, convert(date, CaseStartDate) as CaseStartDate
				, convert(date, KempeDate)	   as KempeDate
				, convert(date, IntakeDate)	   as IntakeDate
				, convert(date, DischargeDate) as DischargeDate
				, rtrim(w.LastName) + ', ' + rtrim(w.FirstName) as WorkerName
		from CaseProgram cp
		inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
		inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		where cp.ProgramFK = @ProgramFK 
		-- made change here
		AND cp.CurrentFSWFK = ISNULL(@WorkerFK, cp.CurrentFSWFK)
				and IntakeDate is not null
				and (DischargeDate is null or 
						cp.DischargeDate > dateadd(month, -6, current_Timestamp))
		--union all
	)
	, cteLastHomeVisitDiscussion as
	(
		select shvc.HVCaseFK
				, max(convert(date, SupervisionDate)) as LastHVSupervisionDate
		from SupervisionHomeVisitCase shvc
		inner join  Supervision s on s.SupervisionPK = shvc.SupervisionFK
		inner join cteMain m on m.HVCaseFK = shvc.HVCaseFK
		where SupervisionDate < @EndDate
				and shvc.InDepthDiscussion = 1
		group by shvc.HVCaseFK
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
			, lhvd.HVCaseFK as HVHVCaseFK
			, convert(date, lhvd.LastHVSupervisionDate) 
				as LastHVSupervisionDate
			, datediff(day, lhvd.LastHVSupervisionDate, @EndDate)
				as LastHVDaysSince
			, datediff(day, m.KempeDate, @EndDate) as ElapsedTime
	from cteMain m
	left outer join cteLastHomeVisitDiscussion lhvd on lhvd.HVCaseFK = m.HVCaseFK
	order by WorkerName
				, isnull(datediff(day, lhvd.LastHVSupervisionDate, @EndDate), 9999) desc
				, ElapsedTime desc ;
end
GO
