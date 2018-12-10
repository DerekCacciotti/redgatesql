SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervision](@SupervisionPK int=NULL,
@AreasGrowth bit=NULL,
@AreasGrowthComments varchar(max)=NULL,
@AreasGrowthStatus bit=NULL,
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
@FamilyProgress bit=NULL,
@FamilyProgressComments varchar(max)=NULL,
@FamilyProgressStatus bit=NULL,
@FormComplete bit=NULL,
@HomeVisitLogActivities bit=NULL,
@HomeVisitLogActivitiesComments varchar(max)=NULL,
@HomeVisitLogActivitiesStatus bit=NULL,
@HomeVisitRate bit=NULL,
@HomeVisitRateComments varchar(max)=NULL,
@HomeVisitRateStatus bit=NULL,
@IFSP bit=NULL,
@IFSPComments varchar(max)=NULL,
@IFSPStatus bit=NULL,
@ImpactOfWork bit=NULL,
@ImpactOfWorkComments varchar(max)=NULL,
@ImpactOfWorkStatus bit=NULL,
@ImplementTraining bit=NULL,
@ImplementTrainingComments varchar(max)=NULL,
@ImplementTrainingStatus bit=NULL,
@Outreach bit=NULL,
@OutreachComments varchar(max)=NULL,
@OutreachStatus bit=NULL,
@PersonalGrowth bit=NULL,
@PersonalGrowthComments varchar(max)=NULL,
@PersonalGrowthStatus bit=NULL,
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
@Shadow bit=NULL,
@ShadowComments varchar(max)=NULL,
@ShadowStatus bit=NULL,
@StrengthBasedApproach bit=NULL,
@StrengthBasedApproachComments varchar(max)=NULL,
@StrengthBasedApproachStatus bit=NULL,
@Strengths bit=NULL,
@StrengthsComments varchar(max)=NULL,
@StrengthsStatus bit=NULL,
@SupervisionDate datetime=NULL,
@SupervisionEditor char(10)=NULL,
@SupervisionEndTime datetime=NULL,
@SupervisionHours int=NULL,
@SupervisionMinutes int=NULL,
@SupervisionNotes varchar(max)=NULL,
@SupervisionSessionType char(2)=NULL,
@SupervisionStartTime char(8)=NULL,
@SupervisorFK int=NULL,
@SupervisorObservationAssessment bit=NULL,
@SupervisorObservationAssessmentComments varchar(max)=NULL,
@SupervisorObservationAssessmentStatus bit=NULL,
@SupervisorObservationHomeVisit bit=NULL,
@SupervisorObservationHomeVisitComments varchar(max)=NULL,
@SupervisorObservationHomeVisitStatus bit=NULL,
@TakePlace bit=NULL,
@TeamDevelopment bit=NULL,
@TeamDevelopmentComments varchar(max)=NULL,
@TeamDevelopmentStatus bit=NULL,
@TechniquesApproaches bit=NULL,
@TechniquesApproachesComments varchar(max)=NULL,
@TechniquesApproachesStatus bit=NULL,
@TrainingNeeds bit=NULL,
@TrainingNeedsComments varchar(max)=NULL,
@TrainingNeedsStatus bit=NULL,
@WorkerFK int=NULL,
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
UPDATE Supervision
SET 
AreasGrowth = @AreasGrowth, 
AreasGrowthComments = @AreasGrowthComments, 
AreasGrowthStatus = @AreasGrowthStatus, 
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
FamilyProgress = @FamilyProgress, 
FamilyProgressComments = @FamilyProgressComments, 
FamilyProgressStatus = @FamilyProgressStatus, 
FormComplete = @FormComplete, 
HomeVisitLogActivities = @HomeVisitLogActivities, 
HomeVisitLogActivitiesComments = @HomeVisitLogActivitiesComments, 
HomeVisitLogActivitiesStatus = @HomeVisitLogActivitiesStatus, 
HomeVisitRate = @HomeVisitRate, 
HomeVisitRateComments = @HomeVisitRateComments, 
HomeVisitRateStatus = @HomeVisitRateStatus, 
IFSP = @IFSP, 
IFSPComments = @IFSPComments, 
IFSPStatus = @IFSPStatus, 
ImpactOfWork = @ImpactOfWork, 
ImpactOfWorkComments = @ImpactOfWorkComments, 
ImpactOfWorkStatus = @ImpactOfWorkStatus, 
ImplementTraining = @ImplementTraining, 
ImplementTrainingComments = @ImplementTrainingComments, 
ImplementTrainingStatus = @ImplementTrainingStatus, 
Outreach = @Outreach, 
OutreachComments = @OutreachComments, 
OutreachStatus = @OutreachStatus, 
PersonalGrowth = @PersonalGrowth, 
PersonalGrowthComments = @PersonalGrowthComments, 
PersonalGrowthStatus = @PersonalGrowthStatus, 
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
Shadow = @Shadow, 
ShadowComments = @ShadowComments, 
ShadowStatus = @ShadowStatus, 
StrengthBasedApproach = @StrengthBasedApproach, 
StrengthBasedApproachComments = @StrengthBasedApproachComments, 
StrengthBasedApproachStatus = @StrengthBasedApproachStatus, 
Strengths = @Strengths, 
StrengthsComments = @StrengthsComments, 
StrengthsStatus = @StrengthsStatus, 
SupervisionDate = @SupervisionDate, 
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
TakePlace = @TakePlace, 
TeamDevelopment = @TeamDevelopment, 
TeamDevelopmentComments = @TeamDevelopmentComments, 
TeamDevelopmentStatus = @TeamDevelopmentStatus, 
TechniquesApproaches = @TechniquesApproaches, 
TechniquesApproachesComments = @TechniquesApproachesComments, 
TechniquesApproachesStatus = @TechniquesApproachesStatus, 
TrainingNeeds = @TrainingNeeds, 
TrainingNeedsComments = @TrainingNeedsComments, 
TrainingNeedsStatus = @TrainingNeedsStatus, 
WorkerFK = @WorkerFK, 
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
WHERE SupervisionPK = @SupervisionPK
GO
