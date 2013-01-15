
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	PreIntakeActivitySummary Report
-- =============================================
CREATE PROCEDURE [dbo].[rspPreIntakeActivitySummary_Part1] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime,
	@WorkerFK int,
	@SupervisorFK int
AS

--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '01/31/2011'
--DECLARE @programfk INT = 17

;
with HV
as
(
select distinct HVCaseFK
	from Preintake pi
	inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
	inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	where pi.ProgramFK = @programfk
		 and PIDate < @StartDt
		 and CaseStatus in ('02','03')
		 and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
		 and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
),
At_Start_Of_Month
as
(select distinct HVCaseFK
	from Preintake pi
	inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
	inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	where HVCaseFK not in (select HV.HVCaseFK
								from HV)
		 and pi.ProgramFK = @programfk
		 and PIDate < @StartDt
		 and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
		 and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
),
HV1
as
(
select distinct HVCaseFK
	from Preintake pi
	inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
	inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	where pi.ProgramFK = @programfk
		 and PIDate <= @EndDt
		 and CaseStatus in ('02','03')
		 and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
		 and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
),
At_End_Of_Month
as
(
select distinct HVCaseFK
	from Preintake pi
	inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
	inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	where HVCaseFK not in (select HV1.HVCaseFK
							   from HV1)
		 and pi.ProgramFK = @programfk
		 and PIDate <= @EndDt
		 and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
		 and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
)
,

PreAssessmentFSWAssignDate
AS
(
SELECT DISTINCT a.HVCaseFK
FROM Preassessment AS a
WHERE a.FSWAssignDate BETWEEN @StartDt AND @EndDt
AND a.ProgramFK = @programfk
)

select count(*) [PreInTakeCases]
	  ,(select count(*)
			from At_Start_Of_Month) [At_Start_of_Month]
	  ,sum(case when PIFSWFK is not null AND x.HVCaseFK IS NOT NULL then 1 else 0 end) [AssignedFSW]
	  ,sum(case when CaseStatus = '02' then 1 else 0 end) [Enrolled]
	  ,sum(case when CaseStatus = '03' then 1 else 0 end) [Terminated]
	  ,sum(case when CaseStatus = '01' then 1 else 0 end) [Continued]
	  ,(select count(*)
			from At_End_Of_Month) [At_End_of_Month]
	  ,sum(ISNULL(PIParentLetter,0)) [Letters]
	  ,sum(ISNULL(PICall2Parent,0)) [Call2Parent]
	  ,sum(ISNULL(PICallFromParent,0)) [CallFromParent]
	  ,sum(ISNULL(PIVisitAttempt,0)) [VisitAttempted]
	  ,sum(ISNULL(PIVisitMade,0)) [VisitConducted]
	  ,sum(ISNULL(PIOtherHVProgram,0)) [Referrals]
	  ,sum(ISNULL(PIParent2Office,0)) [Parent2Office]
	  ,sum(ISNULL(PIProgramMaterial,0)) [ProgramMaterial]
	  ,sum(ISNULL(PIGift,0)) [Gift]
	  ,sum(ISNULL(PICaseReview,0)) [CaseReview]
	  ,sum(ISNULL(PIOtherActivity,0)) [OtherActivity]

	from Preintake pi
	inner join WorkerProgram wp on wp.WorkerFK = PIFSWFK
	inner join WorkerProgram sup on sup.WorkerFK = wp.SupervisorFK
	LEFT OUTER JOIN PreAssessmentFSWAssignDate AS x ON pi.HVCaseFK = x.HVCaseFK
	where pi.ProgramFK = @programfk
		 and PIDate between @StartDt and @EndDt
		 and wp.WorkerFK = isnull(@WorkerFK, wp.WorkerFK)
		 and sup.WorkerFK = isnull(@SupervisorFK, sup.WorkerFK)
GO
