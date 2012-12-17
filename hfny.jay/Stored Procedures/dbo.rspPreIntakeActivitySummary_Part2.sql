
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- exec rspPreIntakeActivitySummary_Part2 1,'20111101','20121031',null,null
-- =============================================
CREATE procedure [dbo].[rspPreIntakeActivitySummary_Part2]-- Add the parameters for the stored procedure here
    @programfk int = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @WorkerFK int,
    @SupervisorFK int
as

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '01/31/2011'
	--DECLARE @programfk INT = 17

	select c.PC1ID [Participant]
		  ,rtrim(w.LastName)+', '+rtrim(w.FirstName) [Worker]
		  ,cast(datediff(day,b.KempeDate,a.PIDate) as varchar(12))+' days' [DaysInPreintake]
		  ,case when a.CaseStatus = '01' then 'Engagement Continue'
			   when a.CaseStatus = '02' then 'Enrolled '+(select top 1 convert(varchar(12),IntakeDate,101)
															  from HVCase
															  where HVCasePK = a.HVCaseFK)
			   when a.CaseStatus = '03' then
				   isnull((select top 1 rtrim(ReportDischargeText)
							   from codeDischarge
							   where DischargeCode = a.DischargeReason)+' ','Terminated ')
				   +isnull(convert(varchar(12),c.DischargeDate,101),'')
			   else '(Status Unknown)' end [CaseStatus]

		  ,ISNULL(PIParentLetter,0) [Letters]
		  ,ISNULL(PICall2Parent,0) [Call2Parent]
		  ,ISNULL(PICallFromParent,0) [CallFromParent]
		  ,ISNULL(PIVisitAttempt,0) [VisitAttempted]
		  ,ISNULL(PIVisitMade,0) [VisitConducted]
		  ,ISNULL(PIOtherHVProgram,0) [Referrals]
		  ,ISNULL(PIParent2Office,0) [Parent2Office]
		  ,ISNULL(PIProgramMaterial,0) [ProgramMaterial]
		  ,ISNULL(PIGift,0) [Gift]
		  ,ISNULL(PICaseReview,0) [CaseReview]
		  ,ISNULL(PIOtherActivity,0) [OtherActivity]

		  ,a.CaseStatus
		  ,a.ProgramFK
		  ,a.DischargeReason
		  ,a.PIDate
		  ,a.PIFSWFK
		  ,a.KempeFK
		  ,a.HVCaseFK
		from Preintake as a
			join CaseProgram as c on c.HVCaseFK = a.HVCaseFK
			join Kempe as b on b.KempePK = a.KempeFK
			left outer join Worker as w on w.WorkerPK = a.PIFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
			inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
		where a.ProgramFK = @programfk
			and a.PIDate between @StartDt and @EndDt
			and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
			and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
		order by [Participant]
GO
