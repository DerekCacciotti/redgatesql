CREATE TABLE [dbo].[TrainingAttendee_old]
(
[TrainingAttendee_oldPK] [int] NOT NULL IDENTITY(1, 1),
[ExemptDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExemptType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExempt] [bit] NULL,
[ProgramFK] [int] NULL,
[SubtopicFK] [int] NULL,
[TopicFK] [int] NULL,
[TrainingAttendeeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TrainingAttendee_old_TrainingAttendeeCreateDate] DEFAULT (getdate()),
[TrainingAttendeeCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingAttendeeEditDate] [datetime] NULL,
[TrainingAttendeeEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingAttendeePK_old] [int] NULL,
[TrainingFK] [int] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[TrainingAttendee_old] ADD 
CONSTRAINT [PK__TrainingAttendee_old__C0BC3C361B9317B3] PRIMARY KEY CLUSTERED  ([TrainingAttendee_oldPK]) ON [PRIMARY]

GO
