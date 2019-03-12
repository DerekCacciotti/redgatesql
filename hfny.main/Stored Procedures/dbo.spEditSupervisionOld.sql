SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionOld](@SupervisionOldPK int=NULL,
@ActivitiesOther bit=NULL,
@ActivitiesOtherSpecify varchar(500)=NULL,
@AreasGrowth bit=NULL,
@AssessmentIssues bit=NULL,
@AssessmentRate bit=NULL,
@Boundaries bit=NULL,
@Caseload bit=NULL,
@Coaching bit=NULL,
@CommunityResources bit=NULL,
@CulturalSensitivity bit=NULL,
@Curriculum bit=NULL,
@FamilyProgress bit=NULL,
@HomeVisitLogActivities bit=NULL,
@HomeVisitRate bit=NULL,
@IFSP bit=NULL,
@ImplementTraining bit=NULL,
@LevelChange bit=NULL,
@Outreach bit=NULL,
@ParticipantEmergency bit=NULL,
@PersonalGrowth bit=NULL,
@ProfessionalGrowth bit=NULL,
@ProgramFK int=NULL,
@ReasonOther bit=NULL,
@ReasonOtherSpecify varchar(500)=NULL,
@RecordDocumentation bit=NULL,
@Referrals bit=NULL,
@Retention bit=NULL,
@RolePlaying bit=NULL,
@Safety bit=NULL,
@ShortWeek bit=NULL,
@StaffCourt bit=NULL,
@StaffFamilyEmergency bit=NULL,
@StaffForgot bit=NULL,
@StaffIll bit=NULL,
@StaffTraining bit=NULL,
@StaffVacation bit=NULL,
@StaffOutAllWeek bit=NULL,
@StrengthBasedApproach bit=NULL,
@Strengths bit=NULL,
@SupervisionDate datetime=NULL,
@SupervisionEditor varchar(max)=NULL,
@SupervisionEndTime datetime=NULL,
@SupervisionHours int=NULL,
@SupervisionMinutes int=NULL,
@SupervisionNotes varchar(max)=NULL,
@SupervisionStartTime char(8)=NULL,
@SupervisorFamilyEmergency bit=NULL,
@SupervisorFK int=NULL,
@SupervisorForgot bit=NULL,
@SupervisorHoliday bit=NULL,
@SupervisorIll bit=NULL,
@SupervisorObservationAssessment bit=NULL,
@SupervisorObservationHomeVisit bit=NULL,
@SupervisorTraining bit=NULL,
@SupervisorVacation bit=NULL,
@TakePlace bit=NULL,
@TechniquesApproaches bit=NULL,
@Tools bit=NULL,
@TrainingNeeds bit=NULL,
@Weather bit=NULL,
@WorkerFK int=NULL)
AS
UPDATE SupervisionOld
SET 
ActivitiesOther = @ActivitiesOther, 
ActivitiesOtherSpecify = @ActivitiesOtherSpecify, 
AreasGrowth = @AreasGrowth, 
AssessmentIssues = @AssessmentIssues, 
AssessmentRate = @AssessmentRate, 
Boundaries = @Boundaries, 
Caseload = @Caseload, 
Coaching = @Coaching, 
CommunityResources = @CommunityResources, 
CulturalSensitivity = @CulturalSensitivity, 
Curriculum = @Curriculum, 
FamilyProgress = @FamilyProgress, 
HomeVisitLogActivities = @HomeVisitLogActivities, 
HomeVisitRate = @HomeVisitRate, 
IFSP = @IFSP, 
ImplementTraining = @ImplementTraining, 
LevelChange = @LevelChange, 
Outreach = @Outreach, 
ParticipantEmergency = @ParticipantEmergency, 
PersonalGrowth = @PersonalGrowth, 
ProfessionalGrowth = @ProfessionalGrowth, 
ProgramFK = @ProgramFK, 
ReasonOther = @ReasonOther, 
ReasonOtherSpecify = @ReasonOtherSpecify, 
RecordDocumentation = @RecordDocumentation, 
Referrals = @Referrals, 
Retention = @Retention, 
RolePlaying = @RolePlaying, 
Safety = @Safety, 
ShortWeek = @ShortWeek, 
StaffCourt = @StaffCourt, 
StaffFamilyEmergency = @StaffFamilyEmergency, 
StaffForgot = @StaffForgot, 
StaffIll = @StaffIll, 
StaffTraining = @StaffTraining, 
StaffVacation = @StaffVacation, 
StaffOutAllWeek = @StaffOutAllWeek, 
StrengthBasedApproach = @StrengthBasedApproach, 
Strengths = @Strengths, 
SupervisionDate = @SupervisionDate, 
SupervisionEditor = @SupervisionEditor, 
SupervisionEndTime = @SupervisionEndTime, 
SupervisionHours = @SupervisionHours, 
SupervisionMinutes = @SupervisionMinutes, 
SupervisionNotes = @SupervisionNotes, 
SupervisionStartTime = @SupervisionStartTime, 
SupervisorFamilyEmergency = @SupervisorFamilyEmergency, 
SupervisorFK = @SupervisorFK, 
SupervisorForgot = @SupervisorForgot, 
SupervisorHoliday = @SupervisorHoliday, 
SupervisorIll = @SupervisorIll, 
SupervisorObservationAssessment = @SupervisorObservationAssessment, 
SupervisorObservationHomeVisit = @SupervisorObservationHomeVisit, 
SupervisorTraining = @SupervisorTraining, 
SupervisorVacation = @SupervisorVacation, 
TakePlace = @TakePlace, 
TechniquesApproaches = @TechniquesApproaches, 
Tools = @Tools, 
TrainingNeeds = @TrainingNeeds, 
Weather = @Weather, 
WorkerFK = @WorkerFK
WHERE SupervisionOldPK = @SupervisionOldPK
GO
