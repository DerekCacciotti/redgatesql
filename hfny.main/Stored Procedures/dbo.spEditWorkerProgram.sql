SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditWorkerProgram](@WorkerProgramPK int=NULL,
@BackgroundCheckDate date=NULL,
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
@WorkerProgramEditor varchar(max)=NULL,
@WorkPhone char(12)=NULL)
AS
UPDATE WorkerProgram
SET 
BackgroundCheckDate = @BackgroundCheckDate, 
CommunityOutreach = @CommunityOutreach, 
DirectParticipantServices = @DirectParticipantServices, 
FatherAdvocate = @FatherAdvocate, 
FatherAdvocateEndDate = @FatherAdvocateEndDate, 
FatherAdvocateStartDate = @FatherAdvocateStartDate, 
FAW = @FAW, 
FAWEndDate = @FAWEndDate, 
FAWStartDate = @FAWStartDate, 
FSW = @FSW, 
FSWEndDate = @FSWEndDate, 
FSWStartDate = @FSWStartDate, 
FundRaiser = @FundRaiser, 
HireDate = @HireDate, 
HoursPerWeek = @HoursPerWeek, 
LivesTargetArea = @LivesTargetArea, 
ProgramFK = @ProgramFK, 
ProgramManager = @ProgramManager, 
ProgramManagerEndDate = @ProgramManagerEndDate, 
ProgramManagerStartDate = @ProgramManagerStartDate, 
SiteFK = @SiteFK, 
Supervisor = @Supervisor, 
SupervisorEndDate = @SupervisorEndDate, 
SupervisorFK = @SupervisorFK, 
SupervisorStartDate = @SupervisorStartDate, 
TerminationDate = @TerminationDate, 
TerminationReasonRetired = @TerminationReasonRetired, 
TerminationReasonForbetterJob = @TerminationReasonForbetterJob, 
TerminationReasonMoved = @TerminationReasonMoved, 
TerminationReasonMoney = @TerminationReasonMoney, 
TerminationReasonBaby = @TerminationReasonBaby, 
TerminationReasonPromotion = @TerminationReasonPromotion, 
TerminationReasonDisability = @TerminationReasonDisability, 
TerminationReasonNotGoodFit = @TerminationReasonNotGoodFit, 
TerminationReasonIncarceration = @TerminationReasonIncarceration, 
TerminationReasonInvoluntary = @TerminationReasonInvoluntary, 
TerminationReasonReassigned = @TerminationReasonReassigned, 
TerminationReasonLossFunding = @TerminationReasonLossFunding, 
TerminationReasonBackToSchool = @TerminationReasonBackToSchool, 
TerminationReasonOther = @TerminationReasonOther, 
TerminationReasonOtherSpecify = @TerminationReasonOtherSpecify, 
WorkerFK = @WorkerFK, 
WorkerNotes = @WorkerNotes, 
WorkerProgramEditor = @WorkerProgramEditor, 
WorkPhone = @WorkPhone
WHERE WorkerProgramPK = @WorkerProgramPK
GO
