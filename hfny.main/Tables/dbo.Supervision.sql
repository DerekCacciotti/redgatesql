CREATE TABLE [dbo].[Supervision]
(
[SupervisionPK] [int] NOT NULL IDENTITY(1, 1),
[AreasGrowth] [bit] NULL,
[AreasGrowthComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AreasGrowthStatus] [bit] NULL,
[Boundaries] [bit] NULL,
[BoundariesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BoundariesStatus] [bit] NULL,
[Caseload] [bit] NULL,
[CaseloadComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseloadStatus] [bit] NULL,
[Coaching] [bit] NULL,
[CoachingComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CoachingStatus] [bit] NULL,
[CPS] [bit] NULL,
[CPSComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPSStatus] [bit] NULL,
[FamilyProgress] [bit] NULL,
[FamilyProgressComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FamilyProgressStatus] [bit] NULL,
[FormComplete] [bit] NULL,
[HomeVisitLogActivities] [bit] NULL,
[HomeVisitLogActivitiesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HomeVisitLogActivitiesStatus] [bit] NULL,
[HomeVisitRate] [bit] NULL,
[HomeVisitRateComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HomeVisitRateStatus] [bit] NULL,
[IFSP] [bit] NULL,
[IFSPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPStatus] [bit] NULL,
[ImpactOfWork] [bit] NULL,
[ImpactOfWorkComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImpactOfWorkStatus] [bit] NULL,
[ImplementTraining] [bit] NULL,
[ImplementTrainingComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImplementTrainingStatus] [bit] NULL,
[Outreach] [bit] NULL,
[OutreachComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutreachStatus] [bit] NULL,
[PersonalGrowth] [bit] NULL,
[PersonalGrowthComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PersonalGrowthStatus] [bit] NULL,
[Personnel] [bit] NULL,
[PersonnelComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PersonnelStatus] [bit] NULL,
[PIP] [bit] NULL,
[PIPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIPStatus] [bit] NULL,
[ProfessionalGrowth] [bit] NULL,
[ProfessionalGrowthComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProfessionalGrowthStatus] [bit] NULL,
[ProgramFK] [int] NULL,
[RecordDocumentation] [bit] NULL,
[RecordDocumentationComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordDocumentationStatus] [bit] NULL,
[Retention] [bit] NULL,
[RetentionComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RetentionStatus] [bit] NULL,
[RolePlaying] [bit] NULL,
[RolePlayingComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RolePlayingStatus] [bit] NULL,
[Safety] [bit] NULL,
[SafetyComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SafetyStatus] [bit] NULL,
[SiteDocumentation] [bit] NULL,
[SiteDocumentationComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteDocumentationStatus] [bit] NULL,
[Shadow] [bit] NULL,
[ShadowComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShadowStatus] [bit] NULL,
[StrengthBasedApproach] [bit] NULL,
[StrengthBasedApproachComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StrengthBasedApproachStatus] [bit] NULL,
[Strengths] [bit] NULL,
[StrengthsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StrengthsStatus] [bit] NULL,
[SupervisionCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Supervision_SupervisionCreateDate] DEFAULT (getdate()),
[SupervisionCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionDate] [datetime] NOT NULL,
[SupervisionEditDate] [datetime] NULL,
[SupervisionEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionEndTime] [datetime] NOT NULL,
[SupervisionHours] [int] NULL,
[SupervisionMinutes] [int] NULL,
[SupervisionNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionSessionType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionStartTime] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorFK] [int] NOT NULL,
[SupervisorObservationAssessment] [bit] NULL,
[SupervisorObservationAssessmentComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorObservationAssessmentStatus] [bit] NULL,
[SupervisorObservationHomeVisit] [bit] NULL,
[SupervisorObservationHomeVisitComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorObservationHomeVisitStatus] [bit] NULL,
[TeamDevelopment] [bit] NULL,
[TeamDevelopmentComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TeamDevelopmentStatus] [bit] NULL,
[TechniquesApproaches] [bit] NULL,
[TechniquesApproachesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TechniquesApproachesStatus] [bit] NULL,
[TrainingNeeds] [bit] NULL,
[TrainingNeedsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingNeedsStatus] [bit] NULL,
[WorkerFK] [int] NOT NULL,
[ParticipantEmergency] [bit] NULL,
[ReasonOther] [bit] NULL,
[ReasonOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShortWeek] [bit] NULL,
[StaffCourt] [bit] NULL,
[StaffFamilyEmergency] [bit] NULL,
[StaffForgot] [bit] NULL,
[StaffIll] [bit] NULL,
[StaffOnLeave] [bit] NULL,
[StaffTraining] [bit] NULL,
[StaffVacation] [bit] NULL,
[StaffOutAllWeek] [bit] NULL,
[SupervisorFamilyEmergency] [bit] NULL,
[SupervisorForgot] [bit] NULL,
[SupervisorHoliday] [bit] NULL,
[SupervisorIll] [bit] NULL,
[SupervisorTraining] [bit] NULL,
[SupervisorVacation] [bit] NULL,
[Weather] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Delete FormReview row when  
--				the Supervision row deleted
-- =============================================
CREATE trigger [dbo].[fr_delete_Supervision]
on [dbo].[Supervision]
after delete
as
declare @PK int ;

set @PK = (select SupervisionPK from deleted) ;

begin
	execute spDeleteFormReview_Trigger @FormFK = @PK, @FormTypeValue = 'SU' ;
	
insert into [dbo].[SupervisionDeleted]
           ([SupervisionPK]
		   ,[AreasGrowth]
           ,[AreasGrowthComments]
           ,[AreasGrowthStatus]
           ,[Boundaries]
           ,[BoundariesComments]
           ,[BoundariesStatus]
           ,[Caseload]
           ,[CaseloadComments]
           ,[CaseloadStatus]
           ,[Coaching]
           ,[CoachingComments]
           ,[CoachingStatus]
           ,[CPS]
           ,[CPSComments]
           ,[CPSStatus]
           ,[FamilyProgress]
           ,[FamilyProgressComments]
           ,[FamilyProgressStatus]
           ,[FormComplete]
           ,[HomeVisitLogActivities]
           ,[HomeVisitLogActivitiesComments]
           ,[HomeVisitLogActivitiesStatus]
           ,[HomeVisitRate]
           ,[HomeVisitRateComments]
           ,[HomeVisitRateStatus]
           ,[IFSP]
           ,[IFSPComments]
           ,[IFSPStatus]
           ,[ImpactOfWork]
           ,[ImpactOfWorkComments]
           ,[ImpactOfWorkStatus]
           ,[ImplementTraining]
           ,[ImplementTrainingComments]
           ,[ImplementTrainingStatus]
           ,[Outreach]
           ,[OutreachComments]
           ,[OutreachStatus]
           ,[PersonalGrowth]
           ,[PersonalGrowthComments]
           ,[PersonalGrowthStatus]
           ,[Personnel]
           ,[PersonnelComments]
           ,[PersonnelStatus]
           ,[PIP]
           ,[PIPComments]
           ,[PIPStatus]
           ,[ProfessionalGrowth]
           ,[ProfessionalGrowthComments]
           ,[ProfessionalGrowthStatus]
           ,[ProgramFK]
           ,[RecordDocumentation]
           ,[RecordDocumentationComments]
           ,[RecordDocumentationStatus]
           ,[Retention]
           ,[RetentionComments]
           ,[RetentionStatus]
           ,[RolePlaying]
           ,[RolePlayingComments]
           ,[RolePlayingStatus]
           ,[Safety]
           ,[SafetyComments]
           ,[SafetyStatus]
           ,[SiteDocumentation]
           ,[SiteDocumentationComments]
           ,[SiteDocumentationStatus]
           ,[Shadow]
           ,[ShadowComments]
           ,[ShadowStatus]
           ,[StrengthBasedApproach]
           ,[StrengthBasedApproachComments]
           ,[StrengthBasedApproachStatus]
           ,[Strengths]
           ,[StrengthsComments]
           ,[StrengthsStatus]
           ,[SupervisionCreateDate]
           ,[SupervisionCreator]
           ,[SupervisionDate]
           ,[SupervisionEditDate]
           ,[SupervisionEditor]
           ,[SupervisionEndTime]
           ,[SupervisionHours]
           ,[SupervisionMinutes]
           ,[SupervisionNotes]
		   ,[SupervisionSessionType]
           ,[SupervisionStartTime]
           ,[SupervisorFK]
           ,[SupervisorObservationAssessment]
           ,[SupervisorObservationAssessmentComments]
           ,[SupervisorObservationAssessmentStatus]
           ,[SupervisorObservationHomeVisit]
           ,[SupervisorObservationHomeVisitComments]
           ,[SupervisorObservationHomeVisitStatus]
           ,[TeamDevelopment]
           ,[TeamDevelopmentComments]
           ,[TeamDevelopmentStatus]
           ,[TechniquesApproaches]
           ,[TechniquesApproachesComments]
           ,[TechniquesApproachesStatus]
           ,[TrainingNeeds]
           ,[TrainingNeedsComments]
           ,[TrainingNeedsStatus]
           ,[WorkerFK]
           ,[ParticipantEmergency]
 ,[ReasonOther]
           ,[ReasonOtherSpecify]
           ,[ShortWeek]
           ,[StaffCourt]
           ,[StaffFamilyEmergency]
           ,[StaffForgot]
           ,[StaffIll]
           ,[StaffOnLeave]
           ,[StaffTraining]
           ,[StaffVacation]
           ,[StaffOutAllWeek]
           ,[SupervisorFamilyEmergency]
           ,[SupervisorForgot]
           ,[SupervisorHoliday]
           ,[SupervisorIll]
           ,[SupervisorTraining]
           ,[SupervisorVacation]
           ,[Weather])
select [SupervisionPK]
		   ,[AreasGrowth]
           ,[AreasGrowthComments]
           ,[AreasGrowthStatus]
           ,[Boundaries]
           ,[BoundariesComments]
           ,[BoundariesStatus]
           ,[Caseload]
           ,[CaseloadComments]
           ,[CaseloadStatus]
           ,[Coaching]
           ,[CoachingComments]
           ,[CoachingStatus]
           ,[CPS]
           ,[CPSComments]
           ,[CPSStatus]
           ,[FamilyProgress]
           ,[FamilyProgressComments]
           ,[FamilyProgressStatus]
           ,[FormComplete]
           ,[HomeVisitLogActivities]
           ,[HomeVisitLogActivitiesComments]
           ,[HomeVisitLogActivitiesStatus]
           ,[HomeVisitRate]
           ,[HomeVisitRateComments]
           ,[HomeVisitRateStatus]
           ,[IFSP]
           ,[IFSPComments]
           ,[IFSPStatus]
           ,[ImpactOfWork]
           ,[ImpactOfWorkComments]
           ,[ImpactOfWorkStatus]
           ,[ImplementTraining]
           ,[ImplementTrainingComments]
           ,[ImplementTrainingStatus]
           ,[Outreach]
           ,[OutreachComments]
           ,[OutreachStatus]
           ,[PersonalGrowth]
           ,[PersonalGrowthComments]
           ,[PersonalGrowthStatus]
           ,[Personnel]
           ,[PersonnelComments]
           ,[PersonnelStatus]
           ,[PIP]
           ,[PIPComments]
           ,[PIPStatus]
           ,[ProfessionalGrowth]
           ,[ProfessionalGrowthComments]
           ,[ProfessionalGrowthStatus]
           ,[ProgramFK]
           ,[RecordDocumentation]
           ,[RecordDocumentationComments]
           ,[RecordDocumentationStatus]
           ,[Retention]
           ,[RetentionComments]
           ,[RetentionStatus]
           ,[RolePlaying]
           ,[RolePlayingComments]
           ,[RolePlayingStatus]
           ,[Safety]
           ,[SafetyComments]
           ,[SafetyStatus]
           ,[SiteDocumentation]
           ,[SiteDocumentationComments]
           ,[SiteDocumentationStatus]
           ,[Shadow]
           ,[ShadowComments]
           ,[ShadowStatus]
           ,[StrengthBasedApproach]
           ,[StrengthBasedApproachComments]
           ,[StrengthBasedApproachStatus]
           ,[Strengths]
           ,[StrengthsComments]
           ,[StrengthsStatus]
           ,[SupervisionCreateDate]
           ,[SupervisionCreator]
           ,[SupervisionDate]
           ,[SupervisionEditDate]
           ,[SupervisionEditor]
           ,[SupervisionEndTime]
           ,[SupervisionHours]
           ,[SupervisionMinutes]
           ,[SupervisionNotes]
		   ,[SupervisionSessionType]
           ,[SupervisionStartTime]
           ,[SupervisorFK]
           ,[SupervisorObservationAssessment]
           ,[SupervisorObservationAssessmentComments]
           ,[SupervisorObservationAssessmentStatus]
           ,[SupervisorObservationHomeVisit]
           ,[SupervisorObservationHomeVisitComments]
           ,[SupervisorObservationHomeVisitStatus]
           ,[TeamDevelopment]
           ,[TeamDevelopmentComments]
           ,[TeamDevelopmentStatus]
           ,[TechniquesApproaches]
           ,[TechniquesApproachesComments]
           ,[TechniquesApproachesStatus]
           ,[TrainingNeeds]
           ,[TrainingNeedsComments]
           ,[TrainingNeedsStatus]
           ,[WorkerFK]
           ,[ParticipantEmergency]
		   ,[ReasonOther]
           ,[ReasonOtherSpecify]
           ,[ShortWeek]
           ,[StaffCourt]
           ,[StaffFamilyEmergency]
           ,[StaffForgot]
           ,[StaffIll]
           ,[StaffOnLeave]
           ,[StaffTraining]
           ,[StaffVacation]
           ,[StaffOutAllWeek]
           ,[SupervisorFamilyEmergency]
           ,[SupervisorForgot]
           ,[SupervisorHoliday]
           ,[SupervisorIll]
           ,[SupervisorTraining]
           ,[SupervisorVacation]
           ,[Weather]
from	Deleted d
where	d.SupervisionPK = @PK ;

end ;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Add FormReview row when 
--				inserting Supervision row
-- =============================================
create TRIGGER [dbo].[fr_Supervision]
on [dbo].[Supervision]
After insert

AS

Declare @PK int

set @PK = (SELECT SupervisionPK from inserted)

BEGIN
	EXEC spAddFormReview_userTriggernoHVCaseFK @FormFK=@PK, @FormTypeValue='SU'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Change FormReview's formdate if 
--				the Supervision date changed
-- =============================================
create trigger [dbo].[fr_Supervision_Edit]
on [dbo].[Supervision]
after update

AS

declare @PK int
declare @UpdatedFormDate datetime 
declare @FormTypeValue varchar(2)

select @PK = SupervisionPK FROM inserted
select @UpdatedFormDate = SupervisionDate FROM inserted
set @FormTypeValue = 'SU'

begin
	update FormReview
	set FormDate=@UpdatedFormDate
	where FormFK=@PK 
			and FormType=@FormTypeValue

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_SupervisionEditDate ON Supervision
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Change FormReview's editdate if 
--				Supervision row has been edited
-- =============================================
create trigger [dbo].[TR_SupervisionEditDate] ON [dbo].[Supervision]
For Update 
AS
Update Supervision Set Supervision.SupervisionEditDate= getdate()
From [Supervision] INNER JOIN Inserted ON [Supervision].[SupervisionPK]= Inserted.[SupervisionPK]
GO
ALTER TABLE [dbo].[Supervision] ADD CONSTRAINT [PK__Supervis__3AC5E6F97D0E9093] PRIMARY KEY CLUSTERED  ([SupervisionPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_SupervisorFK] FOREIGN KEY ([SupervisorFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'Supervision', 'COLUMN', N'SupervisionPK'
GO
