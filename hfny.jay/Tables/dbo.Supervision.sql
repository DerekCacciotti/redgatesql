CREATE TABLE [dbo].[Supervision]
(
[SupervisionPK] [int] NOT NULL IDENTITY(1, 1),
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
[SupervisionCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Supervision_SupervisionCreateDate] DEFAULT (getdate()),
[SupervisionCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionDate] [datetime] NOT NULL,
[SupervisionEditDate] [datetime] NULL,
[SupervisionEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD
CONSTRAINT [FK_Supervision_SupervisorFK] FOREIGN KEY ([SupervisorFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD
CONSTRAINT [FK_Supervision_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
CREATE NONCLUSTERED INDEX [IX_FK_Supervision_SupervisorFK] ON [dbo].[Supervision] ([SupervisorFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_Supervision_WorkerFK] ON [dbo].[Supervision] ([WorkerFK]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Supervision] ADD CONSTRAINT [PK__Supervis__3AC5E6F97D0E9093] PRIMARY KEY CLUSTERED  ([SupervisionPK]) ON [PRIMARY]
GO
