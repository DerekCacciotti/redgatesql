CREATE TABLE [dbo].[TrainingAttendee_old]
(
[TrainingAttendee_oldPK] [int] NOT NULL IDENTITY(1, 1),
[ExemptDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExemptType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExempt] [bit] NULL,
[ProgramFK] [int] NULL,
[SubtopicFK] [int] NULL,
[TopicFK] [int] NULL,
[TrainingAttendeeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TrainingAttendee_TrainingAttendeeCreateDate] DEFAULT (getdate()),
[TrainingAttendeeCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingAttendeeEditDate] [datetime] NULL,
[TrainingAttendeeEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingAttendeePK_old] [int] NULL,
[TrainingFK] [int] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[TrainingAttendee_old] ADD 
CONSTRAINT [PK__Training__C0BC3C361B9317B3] PRIMARY KEY CLUSTERED  ([TrainingAttendee_oldPK]) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingAttendeeEditDate ON TrainingAttendee
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingAttendeeEditDate] ON [dbo].[TrainingAttendee_old]
For Update 
AS
Update TrainingAttendee Set TrainingAttendee.TrainingAttendeeEditDate= getdate()
From [TrainingAttendee] INNER JOIN Inserted ON [TrainingAttendee].[TrainingAttendeePK]= Inserted.[TrainingAttendeePK]
GO