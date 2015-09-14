CREATE TABLE [dbo].[CaseNotes]
(
[CaseNotesPK] [int] NOT NULL IDENTITY(1, 1),
[CaseNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNotesCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseNotes_CaseNotesCreateDate] DEFAULT (getdate()),
[CaseNotesCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNotesEditDate] [datetime] NULL,
[CaseNotesEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseNotes] ADD CONSTRAINT [PK_CaseNotes] PRIMARY KEY CLUSTERED  ([CaseNotesPK]) ON [PRIMARY]
GO
