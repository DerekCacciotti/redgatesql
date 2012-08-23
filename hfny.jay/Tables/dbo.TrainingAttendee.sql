CREATE TABLE [dbo].[TrainingAttendee]
(
[TrainingAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[TrainingFK] [int] NOT NULL,
[WorkerFK] [int] NOT NULL,
[TrainingAttendeeCreateDate] [datetime] NOT NULL,
[TrainingAttendeeCreator] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingAttendeeEditDate] [datetime] NULL,
[TrainingAttendeeEditor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[TrainingAttendee] ADD 
CONSTRAINT [PK_TrainingAttend] PRIMARY KEY CLUSTERED  ([TrainingAttendeePK]) ON [PRIMARY]
GO
