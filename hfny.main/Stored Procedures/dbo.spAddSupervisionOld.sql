SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionOld](@ActivitiesOther bit=NULL,
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
@SupervisionCreator varchar(max)=NULL,
@SupervisionDate datetime=NULL,
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
IF NOT EXISTS (SELECT TOP(1) SupervisionOldPK
FROM SupervisionOld lastRow
WHERE 
@ActivitiesOther = lastRow.ActivitiesOther AND
@ActivitiesOtherSpecify = lastRow.ActivitiesOtherSpecify AND
@AreasGrowth = lastRow.AreasGrowth AND
@AssessmentIssues = lastRow.AssessmentIssues AND
@AssessmentRate = lastRow.AssessmentRate AND
@Boundaries = lastRow.Boundaries AND
@Caseload = lastRow.Caseload AND
@Coaching = lastRow.Coaching AND
@CommunityResources = lastRow.CommunityResources AND
@CulturalSensitivity = lastRow.CulturalSensitivity AND
@Curriculum = lastRow.Curriculum AND
@FamilyProgress = lastRow.FamilyProgress AND
@HomeVisitLogActivities = lastRow.HomeVisitLogActivities AND
@HomeVisitRate = lastRow.HomeVisitRate AND
@IFSP = lastRow.IFSP AND
@ImplementTraining = lastRow.ImplementTraining AND
@LevelChange = lastRow.LevelChange AND
@Outreach = lastRow.Outreach AND
@ParticipantEmergency = lastRow.ParticipantEmergency AND
@PersonalGrowth = lastRow.PersonalGrowth AND
@ProfessionalGrowth = lastRow.ProfessionalGrowth AND
@ProgramFK = lastRow.ProgramFK AND
@ReasonOther = lastRow.ReasonOther AND
@ReasonOtherSpecify = lastRow.ReasonOtherSpecify AND
@RecordDocumentation = lastRow.RecordDocumentation AND
@Referrals = lastRow.Referrals AND
@Retention = lastRow.Retention AND
@RolePlaying = lastRow.RolePlaying AND
@Safety = lastRow.Safety AND
@ShortWeek = lastRow.ShortWeek AND
@StaffCourt = lastRow.StaffCourt AND
@StaffFamilyEmergency = lastRow.StaffFamilyEmergency AND
@StaffForgot = lastRow.StaffForgot AND
@StaffIll = lastRow.StaffIll AND
@StaffTraining = lastRow.StaffTraining AND
@StaffVacation = lastRow.StaffVacation AND
@StaffOutAllWeek = lastRow.StaffOutAllWeek AND
@StrengthBasedApproach = lastRow.StrengthBasedApproach AND
@Strengths = lastRow.Strengths AND
@SupervisionCreator = lastRow.SupervisionCreator AND
@SupervisionDate = lastRow.SupervisionDate AND
@SupervisionEndTime = lastRow.SupervisionEndTime AND
@SupervisionHours = lastRow.SupervisionHours AND
@SupervisionMinutes = lastRow.SupervisionMinutes AND
@SupervisionNotes = lastRow.SupervisionNotes AND
@SupervisionStartTime = lastRow.SupervisionStartTime AND
@SupervisorFamilyEmergency = lastRow.SupervisorFamilyEmergency AND
@SupervisorFK = lastRow.SupervisorFK AND
@SupervisorForgot = lastRow.SupervisorForgot AND
@SupervisorHoliday = lastRow.SupervisorHoliday AND
@SupervisorIll = lastRow.SupervisorIll AND
@SupervisorObservationAssessment = lastRow.SupervisorObservationAssessment AND
@SupervisorObservationHomeVisit = lastRow.SupervisorObservationHomeVisit AND
@SupervisorTraining = lastRow.SupervisorTraining AND
@SupervisorVacation = lastRow.SupervisorVacation AND
@TakePlace = lastRow.TakePlace AND
@TechniquesApproaches = lastRow.TechniquesApproaches AND
@Tools = lastRow.Tools AND
@TrainingNeeds = lastRow.TrainingNeeds AND
@Weather = lastRow.Weather AND
@WorkerFK = lastRow.WorkerFK
ORDER BY SupervisionOldPK DESC) 
BEGIN
INSERT INTO SupervisionOld(
ActivitiesOther,
ActivitiesOtherSpecify,
AreasGrowth,
AssessmentIssues,
AssessmentRate,
Boundaries,
Caseload,
Coaching,
CommunityResources,
CulturalSensitivity,
Curriculum,
FamilyProgress,
HomeVisitLogActivities,
HomeVisitRate,
IFSP,
ImplementTraining,
LevelChange,
Outreach,
ParticipantEmergency,
PersonalGrowth,
ProfessionalGrowth,
ProgramFK,
ReasonOther,
ReasonOtherSpecify,
RecordDocumentation,
Referrals,
Retention,
RolePlaying,
Safety,
ShortWeek,
StaffCourt,
StaffFamilyEmergency,
StaffForgot,
StaffIll,
StaffTraining,
StaffVacation,
StaffOutAllWeek,
StrengthBasedApproach,
Strengths,
SupervisionCreator,
SupervisionDate,
SupervisionEndTime,
SupervisionHours,
SupervisionMinutes,
SupervisionNotes,
SupervisionStartTime,
SupervisorFamilyEmergency,
SupervisorFK,
SupervisorForgot,
SupervisorHoliday,
SupervisorIll,
SupervisorObservationAssessment,
SupervisorObservationHomeVisit,
SupervisorTraining,
SupervisorVacation,
TakePlace,
TechniquesApproaches,
Tools,
TrainingNeeds,
Weather,
WorkerFK
)
VALUES(
@ActivitiesOther,
@ActivitiesOtherSpecify,
@AreasGrowth,
@AssessmentIssues,
@AssessmentRate,
@Boundaries,
@Caseload,
@Coaching,
@CommunityResources,
@CulturalSensitivity,
@Curriculum,
@FamilyProgress,
@HomeVisitLogActivities,
@HomeVisitRate,
@IFSP,
@ImplementTraining,
@LevelChange,
@Outreach,
@ParticipantEmergency,
@PersonalGrowth,
@ProfessionalGrowth,
@ProgramFK,
@ReasonOther,
@ReasonOtherSpecify,
@RecordDocumentation,
@Referrals,
@Retention,
@RolePlaying,
@Safety,
@ShortWeek,
@StaffCourt,
@StaffFamilyEmergency,
@StaffForgot,
@StaffIll,
@StaffTraining,
@StaffVacation,
@StaffOutAllWeek,
@StrengthBasedApproach,
@Strengths,
@SupervisionCreator,
@SupervisionDate,
@SupervisionEndTime,
@SupervisionHours,
@SupervisionMinutes,
@SupervisionNotes,
@SupervisionStartTime,
@SupervisorFamilyEmergency,
@SupervisorFK,
@SupervisorForgot,
@SupervisorHoliday,
@SupervisorIll,
@SupervisorObservationAssessment,
@SupervisorObservationHomeVisit,
@SupervisorTraining,
@SupervisorVacation,
@TakePlace,
@TechniquesApproaches,
@Tools,
@TrainingNeeds,
@Weather,
@WorkerFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
