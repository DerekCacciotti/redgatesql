SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorkerProgram](@BackgroundCheckDate date=NULL,
@CommunityOutreach bit=NULL,
@DirectParticipantServices bit=NULL,
@FatherAdvocate bit=NULL,
@FatherAdvocateEndDate datetime=NULL,
@FatherAdvocateStartDate datetime=NULL,
@FAW bit=NULL,
@FAWEndDate datetime=NULL,
@FAWStartDate datetime=NULL,
@FSW bit=NULL,
@FSWEndDate datetime=NULL,
@FSWStartDate datetime=NULL,
@FundRaiser bit=NULL,
@HireDate datetime=NULL,
@HoursPerWeek decimal(5, 2)=NULL,
@LivesTargetArea bit=NULL,
@ProgramFK int=NULL,
@ProgramManager bit=NULL,
@ProgramManagerEndDate datetime=NULL,
@ProgramManagerStartDate datetime=NULL,
@SiteFK int=NULL,
@Supervisor bit=NULL,
@SupervisorEndDate datetime=NULL,
@SupervisorFK int=NULL,
@SupervisorStartDate datetime=NULL,
@TerminationDate datetime=NULL,
@TerminationReasonRetired bit=NULL,
@TerminationReasonForbetterJob bit=NULL,
@TerminationReasonMoved bit=NULL,
@TerminationReasonMoney bit=NULL,
@TerminationReasonBaby bit=NULL,
@TerminationReasonPromotion bit=NULL,
@TerminationReasonDisability bit=NULL,
@TerminationReasonNotGoodFit bit=NULL,
@TerminationReasonIncarceration bit=NULL,
@TerminationReasonInvoluntary bit=NULL,
@TerminationReasonReassigned bit=NULL,
@TerminationReasonLossFunding bit=NULL,
@TerminationReasonBackToSchool bit=NULL,
@TerminationReasonOther bit=NULL,
@TerminationReasonOtherSpecify varchar(50)=NULL,
@WorkerFK int=NULL,
@WorkerNotes varchar(500)=NULL,
@WorkerProgramCreator varchar(max)=NULL,
@WorkPhone char(12)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) WorkerProgramPK
FROM WorkerProgram lastRow
WHERE 
@BackgroundCheckDate = lastRow.BackgroundCheckDate AND
@CommunityOutreach = lastRow.CommunityOutreach AND
@DirectParticipantServices = lastRow.DirectParticipantServices AND
@FatherAdvocate = lastRow.FatherAdvocate AND
@FatherAdvocateEndDate = lastRow.FatherAdvocateEndDate AND
@FatherAdvocateStartDate = lastRow.FatherAdvocateStartDate AND
@FAW = lastRow.FAW AND
@FAWEndDate = lastRow.FAWEndDate AND
@FAWStartDate = lastRow.FAWStartDate AND
@FSW = lastRow.FSW AND
@FSWEndDate = lastRow.FSWEndDate AND
@FSWStartDate = lastRow.FSWStartDate AND
@FundRaiser = lastRow.FundRaiser AND
@HireDate = lastRow.HireDate AND
@HoursPerWeek = lastRow.HoursPerWeek AND
@LivesTargetArea = lastRow.LivesTargetArea AND
@ProgramFK = lastRow.ProgramFK AND
@ProgramManager = lastRow.ProgramManager AND
@ProgramManagerEndDate = lastRow.ProgramManagerEndDate AND
@ProgramManagerStartDate = lastRow.ProgramManagerStartDate AND
@SiteFK = lastRow.SiteFK AND
@Supervisor = lastRow.Supervisor AND
@SupervisorEndDate = lastRow.SupervisorEndDate AND
@SupervisorFK = lastRow.SupervisorFK AND
@SupervisorStartDate = lastRow.SupervisorStartDate AND
@TerminationDate = lastRow.TerminationDate AND
@TerminationReasonRetired = lastRow.TerminationReasonRetired AND
@TerminationReasonForbetterJob = lastRow.TerminationReasonForbetterJob AND
@TerminationReasonMoved = lastRow.TerminationReasonMoved AND
@TerminationReasonMoney = lastRow.TerminationReasonMoney AND
@TerminationReasonBaby = lastRow.TerminationReasonBaby AND
@TerminationReasonPromotion = lastRow.TerminationReasonPromotion AND
@TerminationReasonDisability = lastRow.TerminationReasonDisability AND
@TerminationReasonNotGoodFit = lastRow.TerminationReasonNotGoodFit AND
@TerminationReasonIncarceration = lastRow.TerminationReasonIncarceration AND
@TerminationReasonInvoluntary = lastRow.TerminationReasonInvoluntary AND
@TerminationReasonReassigned = lastRow.TerminationReasonReassigned AND
@TerminationReasonLossFunding = lastRow.TerminationReasonLossFunding AND
@TerminationReasonBackToSchool = lastRow.TerminationReasonBackToSchool AND
@TerminationReasonOther = lastRow.TerminationReasonOther AND
@TerminationReasonOtherSpecify = lastRow.TerminationReasonOtherSpecify AND
@WorkerFK = lastRow.WorkerFK AND
@WorkerNotes = lastRow.WorkerNotes AND
@WorkerProgramCreator = lastRow.WorkerProgramCreator AND
@WorkPhone = lastRow.WorkPhone
ORDER BY WorkerProgramPK DESC) 
BEGIN
INSERT INTO WorkerProgram(
BackgroundCheckDate,
CommunityOutreach,
DirectParticipantServices,
FatherAdvocate,
FatherAdvocateEndDate,
FatherAdvocateStartDate,
FAW,
FAWEndDate,
FAWStartDate,
FSW,
FSWEndDate,
FSWStartDate,
FundRaiser,
HireDate,
HoursPerWeek,
LivesTargetArea,
ProgramFK,
ProgramManager,
ProgramManagerEndDate,
ProgramManagerStartDate,
SiteFK,
Supervisor,
SupervisorEndDate,
SupervisorFK,
SupervisorStartDate,
TerminationDate,
TerminationReasonRetired,
TerminationReasonForbetterJob,
TerminationReasonMoved,
TerminationReasonMoney,
TerminationReasonBaby,
TerminationReasonPromotion,
TerminationReasonDisability,
TerminationReasonNotGoodFit,
TerminationReasonIncarceration,
TerminationReasonInvoluntary,
TerminationReasonReassigned,
TerminationReasonLossFunding,
TerminationReasonBackToSchool,
TerminationReasonOther,
TerminationReasonOtherSpecify,
WorkerFK,
WorkerNotes,
WorkerProgramCreator,
WorkPhone
)
VALUES(
@BackgroundCheckDate,
@CommunityOutreach,
@DirectParticipantServices,
@FatherAdvocate,
@FatherAdvocateEndDate,
@FatherAdvocateStartDate,
@FAW,
@FAWEndDate,
@FAWStartDate,
@FSW,
@FSWEndDate,
@FSWStartDate,
@FundRaiser,
@HireDate,
@HoursPerWeek,
@LivesTargetArea,
@ProgramFK,
@ProgramManager,
@ProgramManagerEndDate,
@ProgramManagerStartDate,
@SiteFK,
@Supervisor,
@SupervisorEndDate,
@SupervisorFK,
@SupervisorStartDate,
@TerminationDate,
@TerminationReasonRetired,
@TerminationReasonForbetterJob,
@TerminationReasonMoved,
@TerminationReasonMoney,
@TerminationReasonBaby,
@TerminationReasonPromotion,
@TerminationReasonDisability,
@TerminationReasonNotGoodFit,
@TerminationReasonIncarceration,
@TerminationReasonInvoluntary,
@TerminationReasonReassigned,
@TerminationReasonLossFunding,
@TerminationReasonBackToSchool,
@TerminationReasonOther,
@TerminationReasonOtherSpecify,
@WorkerFK,
@WorkerNotes,
@WorkerProgramCreator,
@WorkPhone
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
