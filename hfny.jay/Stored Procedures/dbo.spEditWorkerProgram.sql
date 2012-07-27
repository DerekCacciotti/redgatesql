
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditWorkerProgram](@WorkerProgramPK int=NULL,
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
@WorkerFK int=NULL,
@WorkerNotes varchar(500)=NULL,
@WorkerProgramEditor char(10)=NULL,
@WorkPhone char(12)=NULL,
@YearEarlyChildExperience int=NULL,
@YearHVExperience int=NULL)
AS
UPDATE WorkerProgram
SET 
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
WorkerFK = @WorkerFK, 
WorkerNotes = @WorkerNotes, 
WorkerProgramEditor = @WorkerProgramEditor, 
WorkPhone = @WorkPhone, 
YearEarlyChildExperience = @YearEarlyChildExperience, 
YearHVExperience = @YearHVExperience
WHERE WorkerProgramPK = @WorkerProgramPK
GO
