CREATE TABLE [dbo].[ProgressNotes]
(
[ProgressNotesPK] [int] NOT NULL IDENTITY(1, 1),
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProgressNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgressNotesCreateDate] [datetime] NOT NULL CONSTRAINT [DF_ProgressNotes_ProgressNotesCreateDate] DEFAULT (getdate()),
[ProgressNotesCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgressNotesEditDate] [datetime] NULL,
[ProgressNotesEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
