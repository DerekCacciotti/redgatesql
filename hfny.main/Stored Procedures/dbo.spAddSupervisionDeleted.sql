SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionDeleted](@SupervisionPK int=NULL,
@Boundaries bit=NULL,
@BoundariesComments varchar(max)=NULL,
@BoundariesStatus bit=NULL,
@Caseload bit=NULL,
@CaseloadComments varchar(max)=NULL,
@CaseloadStatus bit=NULL,
@Coaching bit=NULL,
@CoachingComments varchar(max)=NULL,
@CoachingStatus bit=NULL,
@CPS bit=NULL,
@CPSComments varchar(max)=NULL,
@CPSStatus bit=NULL,
@Curriculum bit=NULL,
@CurriculumComments varchar(max)=NULL,
@CurriculumStatus bit=NULL,
@FamilyReview bit=NULL,
@FamilyReviewComments varchar(max)=NULL,
@FamilyReviewStatus bit=NULL,
@FormComplete bit=NULL,
@ImpactOfWork bit=NULL,
@ImpactOfWorkComments varchar(max)=NULL,
@ImpactOfWorkStatus bit=NULL,
@ImplementTraining bit=NULL,
@ImplementTrainingComments varchar(max)=NULL,
@ImplementTrainingStatus bit=NULL,
@Outreach bit=NULL,
@OutreachComments varchar(max)=NULL,
@OutreachStatus bit=NULL,
@Personnel bit=NULL,
@PersonnelComments varchar(max)=NULL,
@PersonnelStatus bit=NULL,
@PIP bit=NULL,
@PIPComments varchar(max)=NULL,
@PIPStatus bit=NULL,
@ProfessionalGrowth bit=NULL,
@ProfessionalGrowthComments varchar(max)=NULL,
@ProfessionalGrowthStatus bit=NULL,
@ProgramFK int=NULL,
@RecordDocumentation bit=NULL,
@RecordDocumentationComments varchar(max)=NULL,
@RecordDocumentationStatus bit=NULL,
@Retention bit=NULL,
@RetentionComments varchar(max)=NULL,
@RetentionStatus bit=NULL,
@RolePlaying bit=NULL,
@RolePlayingComments varchar(max)=NULL,
@RolePlayingStatus bit=NULL,
@Safety bit=NULL,
@SafetyComments varchar(max)=NULL,
@SafetyStatus bit=NULL,
@SiteDocumentation bit=NULL,
@SiteDocumentationComments varchar(max)=NULL,
@SiteDocumentationStatus bit=NULL,
@Strengths bit=NULL,
@StrengthsComments varchar(max)=NULL,
@StrengthsStatus bit=NULL,
@SupervisionCreator varchar(max)=NULL,
@SupervisionDate datetime=NULL,
@SupervisionDeleteDate datetime=NULL,
@SupervisionDeleter varchar(max)=NULL,
@SupervisionEndTime datetime=NULL,
@SupervisionHours int=NULL,
@SupervisionMinutes int=NULL,
@SupervisionNotes varchar(max)=NULL,
@SupervisionSessionType char(1)=NULL,
@SupervisionStartTime char(8)=NULL,
@SupervisorFK int=NULL,
@SupervisorObservationAssessment bit=NULL,
@SupervisorObservationAssessmentComments varchar(max)=NULL,
@SupervisorObservationAssessmentStatus bit=NULL,
@SupervisorObservationHomeVisit bit=NULL,
@SupervisorObservationHomeVisitComments varchar(max)=NULL,
@SupervisorObservationHomeVisitStatus bit=NULL,
@SupervisorObservationSupervision bit=NULL,
@SupervisorObservationSupervisionComments varchar(max)=NULL,
@SupervisorObservationSupervisionStatus bit=NULL,
@SupportHFAModel bit=NULL,
@SupportHFAModelComments varchar(max)=NULL,
@SupportHFAModelStatus bit=NULL,
@TeamDevelopment bit=NULL,
@TeamDevelopmentComments varchar(max)=NULL,
@TeamDevelopmentStatus bit=NULL,
@WorkerFK int=NULL,
@WorkplaceEnvironment bit=NULL,
@WorkplaceEnvironmentComments varchar(max)=NULL,
@WorkplaceEnvironmentStatus bit=NULL,
@ParticipantEmergency bit=NULL,
@ReasonOther bit=NULL,
@ReasonOtherSpecify varchar(500)=NULL,
@ShortWeek bit=NULL,
@StaffCourt bit=NULL,
@StaffFamilyEmergency bit=NULL,
@StaffForgot bit=NULL,
@StaffIll bit=NULL,
@StaffOnLeave bit=NULL,
@StaffTraining bit=NULL,
@StaffVacation bit=NULL,
@StaffOutAllWeek bit=NULL,
@SupervisorFamilyEmergency bit=NULL,
@SupervisorForgot bit=NULL,
@SupervisorHoliday bit=NULL,
@SupervisorIll bit=NULL,
@SupervisorTraining bit=NULL,
@SupervisorVacation bit=NULL,
@Weather bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) SupervisionDeletedPK
FROM SupervisionDeleted lastRow
WHERE 
@SupervisionPK = lastRow.SupervisionPK AND
@Boundaries = lastRow.Boundaries AND
@BoundariesComments = lastRow.BoundariesComments AND
@BoundariesStatus = lastRow.BoundariesStatus AND
@Caseload = lastRow.Caseload AND
@CaseloadComments = lastRow.CaseloadComments AND
@CaseloadStatus = lastRow.CaseloadStatus AND
@Coaching = lastRow.Coaching AND
@CoachingComments = lastRow.CoachingComments AND
@CoachingStatus = lastRow.CoachingStatus AND
@CPS = lastRow.CPS AND
@CPSComments = lastRow.CPSComments AND
@CPSStatus = lastRow.CPSStatus AND
@Curriculum = lastRow.Curriculum AND
@CurriculumComments = lastRow.CurriculumComments AND
@CurriculumStatus = lastRow.CurriculumStatus AND
@FamilyReview = lastRow.FamilyReview AND
@FamilyReviewComments = lastRow.FamilyReviewComments AND
@FamilyReviewStatus = lastRow.FamilyReviewStatus AND
@FormComplete = lastRow.FormComplete AND
@ImpactOfWork = lastRow.ImpactOfWork AND
@ImpactOfWorkComments = lastRow.ImpactOfWorkComments AND
@ImpactOfWorkStatus = lastRow.ImpactOfWorkStatus AND
@ImplementTraining = lastRow.ImplementTraining AND
@ImplementTrainingComments = lastRow.ImplementTrainingComments AND
@ImplementTrainingStatus = lastRow.ImplementTrainingStatus AND
@Outreach = lastRow.Outreach AND
@OutreachComments = lastRow.OutreachComments AND
@OutreachStatus = lastRow.OutreachStatus AND
@Personnel = lastRow.Personnel AND
@PersonnelComments = lastRow.PersonnelComments AND
@PersonnelStatus = lastRow.PersonnelStatus AND
@PIP = lastRow.PIP AND
@PIPComments = lastRow.PIPComments AND
@PIPStatus = lastRow.PIPStatus AND
@ProfessionalGrowth = lastRow.ProfessionalGrowth AND
@ProfessionalGrowthComments = lastRow.ProfessionalGrowthComments AND
@ProfessionalGrowthStatus = lastRow.ProfessionalGrowthStatus AND
@ProgramFK = lastRow.ProgramFK AND
@RecordDocumentation = lastRow.RecordDocumentation AND
@RecordDocumentationComments = lastRow.RecordDocumentationComments AND
@RecordDocumentationStatus = lastRow.RecordDocumentationStatus AND
@Retention = lastRow.Retention AND
@RetentionComments = lastRow.RetentionComments AND
@RetentionStatus = lastRow.RetentionStatus AND
@RolePlaying = lastRow.RolePlaying AND
@RolePlayingComments = lastRow.RolePlayingComments AND
@RolePlayingStatus = lastRow.RolePlayingStatus AND
@Safety = lastRow.Safety AND
@SafetyComments = lastRow.SafetyComments AND
@SafetyStatus = lastRow.SafetyStatus AND
@SiteDocumentation = lastRow.SiteDocumentation AND
@SiteDocumentationComments = lastRow.SiteDocumentationComments AND
@SiteDocumentationStatus = lastRow.SiteDocumentationStatus AND
@Strengths = lastRow.Strengths AND
@StrengthsComments = lastRow.StrengthsComments AND
@StrengthsStatus = lastRow.StrengthsStatus AND
@SupervisionCreator = lastRow.SupervisionCreator AND
@SupervisionDate = lastRow.SupervisionDate AND
@SupervisionDeleteDate = lastRow.SupervisionDeleteDate AND
@SupervisionDeleter = lastRow.SupervisionDeleter AND
@SupervisionEndTime = lastRow.SupervisionEndTime AND
@SupervisionHours = lastRow.SupervisionHours AND
@SupervisionMinutes = lastRow.SupervisionMinutes AND
@SupervisionNotes = lastRow.SupervisionNotes AND
@SupervisionSessionType = lastRow.SupervisionSessionType AND
@SupervisionStartTime = lastRow.SupervisionStartTime AND
@SupervisorFK = lastRow.SupervisorFK AND
@SupervisorObservationAssessment = lastRow.SupervisorObservationAssessment AND
@SupervisorObservationAssessmentComments = lastRow.SupervisorObservationAssessmentComments AND
@SupervisorObservationAssessmentStatus = lastRow.SupervisorObservationAssessmentStatus AND
@SupervisorObservationHomeVisit = lastRow.SupervisorObservationHomeVisit AND
@SupervisorObservationHomeVisitComments = lastRow.SupervisorObservationHomeVisitComments AND
@SupervisorObservationHomeVisitStatus = lastRow.SupervisorObservationHomeVisitStatus AND
@SupervisorObservationSupervision = lastRow.SupervisorObservationSupervision AND
@SupervisorObservationSupervisionComments = lastRow.SupervisorObservationSupervisionComments AND
@SupervisorObservationSupervisionStatus = lastRow.SupervisorObservationSupervisionStatus AND
@SupportHFAModel = lastRow.SupportHFAModel AND
@SupportHFAModelComments = lastRow.SupportHFAModelComments AND
@SupportHFAModelStatus = lastRow.SupportHFAModelStatus AND
@TeamDevelopment = lastRow.TeamDevelopment AND
@TeamDevelopmentComments = lastRow.TeamDevelopmentComments AND
@TeamDevelopmentStatus = lastRow.TeamDevelopmentStatus AND
@WorkerFK = lastRow.WorkerFK AND
@WorkplaceEnvironment = lastRow.WorkplaceEnvironment AND
@WorkplaceEnvironmentComments = lastRow.WorkplaceEnvironmentComments AND
@WorkplaceEnvironmentStatus = lastRow.WorkplaceEnvironmentStatus AND
@ParticipantEmergency = lastRow.ParticipantEmergency AND
@ReasonOther = lastRow.ReasonOther AND
@ReasonOtherSpecify = lastRow.ReasonOtherSpecify AND
@ShortWeek = lastRow.ShortWeek AND
@StaffCourt = lastRow.StaffCourt AND
@StaffFamilyEmergency = lastRow.StaffFamilyEmergency AND
@StaffForgot = lastRow.StaffForgot AND
@StaffIll = lastRow.StaffIll AND
@StaffOnLeave = lastRow.StaffOnLeave AND
@StaffTraining = lastRow.StaffTraining AND
@StaffVacation = lastRow.StaffVacation AND
@StaffOutAllWeek = lastRow.StaffOutAllWeek AND
@SupervisorFamilyEmergency = lastRow.SupervisorFamilyEmergency AND
@SupervisorForgot = lastRow.SupervisorForgot AND
@SupervisorHoliday = lastRow.SupervisorHoliday AND
@SupervisorIll = lastRow.SupervisorIll AND
@SupervisorTraining = lastRow.SupervisorTraining AND
@SupervisorVacation = lastRow.SupervisorVacation AND
@Weather = lastRow.Weather
ORDER BY SupervisionDeletedPK DESC) 
BEGIN
INSERT INTO SupervisionDeleted(
SupervisionPK,
Boundaries,
BoundariesComments,
BoundariesStatus,
Caseload,
CaseloadComments,
CaseloadStatus,
Coaching,
CoachingComments,
CoachingStatus,
CPS,
CPSComments,
CPSStatus,
Curriculum,
CurriculumComments,
CurriculumStatus,
FamilyReview,
FamilyReviewComments,
FamilyReviewStatus,
FormComplete,
ImpactOfWork,
ImpactOfWorkComments,
ImpactOfWorkStatus,
ImplementTraining,
ImplementTrainingComments,
ImplementTrainingStatus,
Outreach,
OutreachComments,
OutreachStatus,
Personnel,
PersonnelComments,
PersonnelStatus,
PIP,
PIPComments,
PIPStatus,
ProfessionalGrowth,
ProfessionalGrowthComments,
ProfessionalGrowthStatus,
ProgramFK,
RecordDocumentation,
RecordDocumentationComments,
RecordDocumentationStatus,
Retention,
RetentionComments,
RetentionStatus,
RolePlaying,
RolePlayingComments,
RolePlayingStatus,
Safety,
SafetyComments,
SafetyStatus,
SiteDocumentation,
SiteDocumentationComments,
SiteDocumentationStatus,
Strengths,
StrengthsComments,
StrengthsStatus,
SupervisionCreator,
SupervisionDate,
SupervisionDeleteDate,
SupervisionDeleter,
SupervisionEndTime,
SupervisionHours,
SupervisionMinutes,
SupervisionNotes,
SupervisionSessionType,
SupervisionStartTime,
SupervisorFK,
SupervisorObservationAssessment,
SupervisorObservationAssessmentComments,
SupervisorObservationAssessmentStatus,
SupervisorObservationHomeVisit,
SupervisorObservationHomeVisitComments,
SupervisorObservationHomeVisitStatus,
SupervisorObservationSupervision,
SupervisorObservationSupervisionComments,
SupervisorObservationSupervisionStatus,
SupportHFAModel,
SupportHFAModelComments,
SupportHFAModelStatus,
TeamDevelopment,
TeamDevelopmentComments,
TeamDevelopmentStatus,
WorkerFK,
WorkplaceEnvironment,
WorkplaceEnvironmentComments,
WorkplaceEnvironmentStatus,
ParticipantEmergency,
ReasonOther,
ReasonOtherSpecify,
ShortWeek,
StaffCourt,
StaffFamilyEmergency,
StaffForgot,
StaffIll,
StaffOnLeave,
StaffTraining,
StaffVacation,
StaffOutAllWeek,
SupervisorFamilyEmergency,
SupervisorForgot,
SupervisorHoliday,
SupervisorIll,
SupervisorTraining,
SupervisorVacation,
Weather
)
VALUES(
@SupervisionPK,
@Boundaries,
@BoundariesComments,
@BoundariesStatus,
@Caseload,
@CaseloadComments,
@CaseloadStatus,
@Coaching,
@CoachingComments,
@CoachingStatus,
@CPS,
@CPSComments,
@CPSStatus,
@Curriculum,
@CurriculumComments,
@CurriculumStatus,
@FamilyReview,
@FamilyReviewComments,
@FamilyReviewStatus,
@FormComplete,
@ImpactOfWork,
@ImpactOfWorkComments,
@ImpactOfWorkStatus,
@ImplementTraining,
@ImplementTrainingComments,
@ImplementTrainingStatus,
@Outreach,
@OutreachComments,
@OutreachStatus,
@Personnel,
@PersonnelComments,
@PersonnelStatus,
@PIP,
@PIPComments,
@PIPStatus,
@ProfessionalGrowth,
@ProfessionalGrowthComments,
@ProfessionalGrowthStatus,
@ProgramFK,
@RecordDocumentation,
@RecordDocumentationComments,
@RecordDocumentationStatus,
@Retention,
@RetentionComments,
@RetentionStatus,
@RolePlaying,
@RolePlayingComments,
@RolePlayingStatus,
@Safety,
@SafetyComments,
@SafetyStatus,
@SiteDocumentation,
@SiteDocumentationComments,
@SiteDocumentationStatus,
@Strengths,
@StrengthsComments,
@StrengthsStatus,
@SupervisionCreator,
@SupervisionDate,
@SupervisionDeleteDate,
@SupervisionDeleter,
@SupervisionEndTime,
@SupervisionHours,
@SupervisionMinutes,
@SupervisionNotes,
@SupervisionSessionType,
@SupervisionStartTime,
@SupervisorFK,
@SupervisorObservationAssessment,
@SupervisorObservationAssessmentComments,
@SupervisorObservationAssessmentStatus,
@SupervisorObservationHomeVisit,
@SupervisorObservationHomeVisitComments,
@SupervisorObservationHomeVisitStatus,
@SupervisorObservationSupervision,
@SupervisorObservationSupervisionComments,
@SupervisorObservationSupervisionStatus,
@SupportHFAModel,
@SupportHFAModelComments,
@SupportHFAModelStatus,
@TeamDevelopment,
@TeamDevelopmentComments,
@TeamDevelopmentStatus,
@WorkerFK,
@WorkplaceEnvironment,
@WorkplaceEnvironmentComments,
@WorkplaceEnvironmentStatus,
@ParticipantEmergency,
@ReasonOther,
@ReasonOtherSpecify,
@ShortWeek,
@StaffCourt,
@StaffFamilyEmergency,
@StaffForgot,
@StaffIll,
@StaffOnLeave,
@StaffTraining,
@StaffVacation,
@StaffOutAllWeek,
@SupervisorFamilyEmergency,
@SupervisorForgot,
@SupervisorHoliday,
@SupervisorIll,
@SupervisorTraining,
@SupervisorVacation,
@Weather
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
