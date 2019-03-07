SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionDeleted](@SupervisionDeletedPK int=NULL,
@SupervisionPK int=NULL,
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
@SupervisionDate datetime=NULL,
@SupervisionDeleteDate datetime=NULL,
@SupervisionDeleter char(10)=NULL,
@SupervisionEditor char(10)=NULL,
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
UPDATE SupervisionDeleted
SET 
SupervisionPK = @SupervisionPK, 
Boundaries = @Boundaries, 
BoundariesComments = @BoundariesComments, 
BoundariesStatus = @BoundariesStatus, 
Caseload = @Caseload, 
CaseloadComments = @CaseloadComments, 
CaseloadStatus = @CaseloadStatus, 
Coaching = @Coaching, 
CoachingComments = @CoachingComments, 
CoachingStatus = @CoachingStatus, 
CPS = @CPS, 
CPSComments = @CPSComments, 
CPSStatus = @CPSStatus, 
Curriculum = @Curriculum, 
CurriculumComments = @CurriculumComments, 
CurriculumStatus = @CurriculumStatus, 
FamilyReview = @FamilyReview, 
FamilyReviewComments = @FamilyReviewComments, 
FamilyReviewStatus = @FamilyReviewStatus, 
FormComplete = @FormComplete, 
ImpactOfWork = @ImpactOfWork, 
ImpactOfWorkComments = @ImpactOfWorkComments, 
ImpactOfWorkStatus = @ImpactOfWorkStatus, 
ImplementTraining = @ImplementTraining, 
ImplementTrainingComments = @ImplementTrainingComments, 
ImplementTrainingStatus = @ImplementTrainingStatus, 
Outreach = @Outreach, 
OutreachComments = @OutreachComments, 
OutreachStatus = @OutreachStatus, 
Personnel = @Personnel, 
PersonnelComments = @PersonnelComments, 
PersonnelStatus = @PersonnelStatus, 
PIP = @PIP, 
PIPComments = @PIPComments, 
PIPStatus = @PIPStatus, 
ProfessionalGrowth = @ProfessionalGrowth, 
ProfessionalGrowthComments = @ProfessionalGrowthComments, 
ProfessionalGrowthStatus = @ProfessionalGrowthStatus, 
ProgramFK = @ProgramFK, 
RecordDocumentation = @RecordDocumentation, 
RecordDocumentationComments = @RecordDocumentationComments, 
RecordDocumentationStatus = @RecordDocumentationStatus, 
Retention = @Retention, 
RetentionComments = @RetentionComments, 
RetentionStatus = @RetentionStatus, 
RolePlaying = @RolePlaying, 
RolePlayingComments = @RolePlayingComments, 
RolePlayingStatus = @RolePlayingStatus, 
Safety = @Safety, 
SafetyComments = @SafetyComments, 
SafetyStatus = @SafetyStatus, 
SiteDocumentation = @SiteDocumentation, 
SiteDocumentationComments = @SiteDocumentationComments, 
SiteDocumentationStatus = @SiteDocumentationStatus, 
Strengths = @Strengths, 
StrengthsComments = @StrengthsComments, 
StrengthsStatus = @StrengthsStatus, 
SupervisionDate = @SupervisionDate, 
SupervisionDeleteDate = @SupervisionDeleteDate, 
SupervisionDeleter = @SupervisionDeleter, 
SupervisionEditor = @SupervisionEditor, 
SupervisionEndTime = @SupervisionEndTime, 
SupervisionHours = @SupervisionHours, 
SupervisionMinutes = @SupervisionMinutes, 
SupervisionNotes = @SupervisionNotes, 
SupervisionSessionType = @SupervisionSessionType, 
SupervisionStartTime = @SupervisionStartTime, 
SupervisorFK = @SupervisorFK, 
SupervisorObservationAssessment = @SupervisorObservationAssessment, 
SupervisorObservationAssessmentComments = @SupervisorObservationAssessmentComments, 
SupervisorObservationAssessmentStatus = @SupervisorObservationAssessmentStatus, 
SupervisorObservationHomeVisit = @SupervisorObservationHomeVisit, 
SupervisorObservationHomeVisitComments = @SupervisorObservationHomeVisitComments, 
SupervisorObservationHomeVisitStatus = @SupervisorObservationHomeVisitStatus, 
SupervisorObservationSupervision = @SupervisorObservationSupervision, 
SupervisorObservationSupervisionComments = @SupervisorObservationSupervisionComments, 
SupervisorObservationSupervisionStatus = @SupervisorObservationSupervisionStatus, 
SupportHFAModel = @SupportHFAModel, 
SupportHFAModelComments = @SupportHFAModelComments, 
SupportHFAModelStatus = @SupportHFAModelStatus, 
TeamDevelopment = @TeamDevelopment, 
TeamDevelopmentComments = @TeamDevelopmentComments, 
TeamDevelopmentStatus = @TeamDevelopmentStatus, 
WorkerFK = @WorkerFK, 
WorkplaceEnvironment = @WorkplaceEnvironment, 
WorkplaceEnvironmentComments = @WorkplaceEnvironmentComments, 
WorkplaceEnvironmentStatus = @WorkplaceEnvironmentStatus, 
ParticipantEmergency = @ParticipantEmergency, 
ReasonOther = @ReasonOther, 
ReasonOtherSpecify = @ReasonOtherSpecify, 
ShortWeek = @ShortWeek, 
StaffCourt = @StaffCourt, 
StaffFamilyEmergency = @StaffFamilyEmergency, 
StaffForgot = @StaffForgot, 
StaffIll = @StaffIll, 
StaffOnLeave = @StaffOnLeave, 
StaffTraining = @StaffTraining, 
StaffVacation = @StaffVacation, 
StaffOutAllWeek = @StaffOutAllWeek, 
SupervisorFamilyEmergency = @SupervisorFamilyEmergency, 
SupervisorForgot = @SupervisorForgot, 
SupervisorHoliday = @SupervisorHoliday, 
SupervisorIll = @SupervisorIll, 
SupervisorTraining = @SupervisorTraining, 
SupervisorVacation = @SupervisorVacation, 
Weather = @Weather
WHERE SupervisionDeletedPK = @SupervisionDeletedPK
GO
