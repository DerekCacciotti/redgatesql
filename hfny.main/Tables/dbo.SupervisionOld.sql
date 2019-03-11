CREATE TABLE [dbo].[SupervisionOld]
(
[SupervisionOldPK] [int] NOT NULL IDENTITY(1, 1),
[ActivitiesOther] [bit] NULL,
[ActivitiesOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AreasGrowth] [bit] NULL,
[AssessmentIssues] [bit] NULL,
[AssessmentRate] [bit] NULL,
[Boundaries] [bit] NULL,
[Caseload] [bit] NULL,
[Coaching] [bit] NULL,
[CommunityResources] [bit] NULL,
[CulturalSensitivity] [bit] NULL,
[Curriculum] [bit] NULL,
[FamilyProgress] [bit] NULL,
[HomeVisitLogActivities] [bit] NULL,
[HomeVisitRate] [bit] NULL,
[IFSP] [bit] NULL,
[ImplementTraining] [bit] NULL,
[LevelChange] [bit] NULL,
[Outreach] [bit] NULL,
[ParticipantEmergency] [bit] NULL,
[PersonalGrowth] [bit] NULL,
[ProfessionalGrowth] [bit] NULL,
[ProgramFK] [int] NULL,
[ReasonOther] [bit] NULL,
[ReasonOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordDocumentation] [bit] NULL,
[Referrals] [bit] NULL,
[Retention] [bit] NULL,
[RolePlaying] [bit] NULL,
[Safety] [bit] NULL,
[ShortWeek] [bit] NULL,
[StaffCourt] [bit] NULL,
[StaffFamilyEmergency] [bit] NULL,
[StaffForgot] [bit] NULL,
[StaffIll] [bit] NULL,
[StaffTraining] [bit] NULL,
[StaffVacation] [bit] NULL,
[StaffOutAllWeek] [bit] NULL,
[StrengthBasedApproach] [bit] NULL,
[Strengths] [bit] NULL,
[SupervisionCreateDate] [datetime] NOT NULL CONSTRAINT [DF_SupervisionOld_SupervisionCreateDate] DEFAULT (getdate()),
[SupervisionCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupervisionDate] [datetime] NOT NULL,
[SupervisionEditDate] [datetime] NULL,
[SupervisionEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionEndTime] [datetime] NOT NULL,
[SupervisionHours] [int] NULL,
[SupervisionMinutes] [int] NULL,
[SupervisionNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionStartTime] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorFamilyEmergency] [bit] NULL,
[SupervisorFK] [int] NOT NULL,
[SupervisorForgot] [bit] NULL,
[SupervisorHoliday] [bit] NULL,
[SupervisorIll] [bit] NULL,
[SupervisorObservationAssessment] [bit] NULL,
[SupervisorObservationHomeVisit] [bit] NULL,
[SupervisorTraining] [bit] NULL,
[SupervisorVacation] [bit] NULL,
[TakePlace] [bit] NULL,
[TechniquesApproaches] [bit] NULL,
[Tools] [bit] NULL,
[TrainingNeeds] [bit] NULL,
[Weather] [bit] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionOld] ADD CONSTRAINT [PK_SupervisionOld] PRIMARY KEY NONCLUSTERED  ([SupervisionOldPK]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ClusteredIndex-20181113-083839] ON [dbo].[SupervisionOld] ([SupervisionOldPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionOld] WITH NOCHECK ADD CONSTRAINT [FK_SupervisionOld_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[SupervisionOld] WITH NOCHECK ADD CONSTRAINT [FK_SupervisionOld_SupervisorFK] FOREIGN KEY ([SupervisorFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[SupervisionOld] WITH NOCHECK ADD CONSTRAINT [FK_SupervisionOld_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'SupervisionOld', 'COLUMN', N'SupervisionOldPK'
GO
