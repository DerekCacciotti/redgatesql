SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervision](@AreasGrowth bit=NULL,
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
@SupervisionCreator char(10)=NULL,
@SupervisionDate datetime=NULL,
@SupervisionEndTime datetime=NULL,
@SupervisionHours int=NULL,
@SupervisionMinutes int=NULL,
@SupervisionNotes varchar(max)=NULL,
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
INSERT INTO Supervision(
AreasGrowth,
AreasGrowthComments,
AreasGrowthStatus,
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
FamilyProgress,
FamilyProgressComments,
FamilyProgressStatus,
FormComplete,
HomeVisitLogActivities,
HomeVisitLogActivitiesComments,
HomeVisitLogActivitiesStatus,
HomeVisitRate,
HomeVisitRateComments,
HomeVisitRateStatus,
IFSP,
IFSPComments,
IFSPStatus,
ImpactOfWork,
ImpactOfWorkComments,
ImpactOfWorkStatus,
ImplementTraining,
ImplementTrainingComments,
ImplementTrainingStatus,
Outreach,
OutreachComments,
OutreachStatus,
PersonalGrowth,
PersonalGrowthComments,
PersonalGrowthStatus,
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
Shadow,
ShadowComments,
ShadowStatus,
StrengthBasedApproach,
StrengthBasedApproachComments,
StrengthBasedApproachStatus,
Strengths,
StrengthsComments,
StrengthsStatus,
SupervisionCreator,
SupervisionDate,
SupervisionEndTime,
SupervisionHours,
SupervisionMinutes,
SupervisionNotes,
SupervisionStartTime,
SupervisorFK,
SupervisorObservationAssessment,
SupervisorObservationAssessmentComments,
SupervisorObservationAssessmentStatus,
SupervisorObservationHomeVisit,
SupervisorObservationHomeVisitComments,
SupervisorObservationHomeVisitStatus,
TakePlace,
TeamDevelopment,
TeamDevelopmentComments,
TeamDevelopmentStatus,
TechniquesApproaches,
TechniquesApproachesComments,
TechniquesApproachesStatus,
TrainingNeeds,
TrainingNeedsComments,
TrainingNeedsStatus,
WorkerFK,
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
@AreasGrowth,
@AreasGrowthComments,
@AreasGrowthStatus,
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
@FamilyProgress,
@FamilyProgressComments,
@FamilyProgressStatus,
@FormComplete,
@HomeVisitLogActivities,
@HomeVisitLogActivitiesComments,
@HomeVisitLogActivitiesStatus,
@HomeVisitRate,
@HomeVisitRateComments,
@HomeVisitRateStatus,
@IFSP,
@IFSPComments,
@IFSPStatus,
@ImpactOfWork,
@ImpactOfWorkComments,
@ImpactOfWorkStatus,
@ImplementTraining,
@ImplementTrainingComments,
@ImplementTrainingStatus,
@Outreach,
@OutreachComments,
@OutreachStatus,
@PersonalGrowth,
@PersonalGrowthComments,
@PersonalGrowthStatus,
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
@Shadow,
@ShadowComments,
@ShadowStatus,
@StrengthBasedApproach,
@StrengthBasedApproachComments,
@StrengthBasedApproachStatus,
@Strengths,
@StrengthsComments,
@StrengthsStatus,
@SupervisionCreator,
@SupervisionDate,
@SupervisionEndTime,
@SupervisionHours,
@SupervisionMinutes,
@SupervisionNotes,
@SupervisionStartTime,
@SupervisorFK,
@SupervisorObservationAssessment,
@SupervisorObservationAssessmentComments,
@SupervisorObservationAssessmentStatus,
@SupervisorObservationHomeVisit,
@SupervisorObservationHomeVisitComments,
@SupervisorObservationHomeVisitStatus,
@TakePlace,
@TeamDevelopment,
@TeamDevelopmentComments,
@TeamDevelopmentStatus,
@TechniquesApproaches,
@TechniquesApproachesComments,
@TechniquesApproachesStatus,
@TrainingNeeds,
@TrainingNeedsComments,
@TrainingNeedsStatus,
@WorkerFK,
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
