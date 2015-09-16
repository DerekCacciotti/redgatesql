CREATE TABLE [dbo].[CaseNote]
(
[CaseNotePK] [int] NOT NULL IDENTITY(1, 1),
[CaseNote] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseNotes_CaseNotesCreateDate] DEFAULT (getdate()),
[CaseNoteCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteEditDate] [datetime] NULL,
[CaseNoteEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseNote] ADD CONSTRAINT [PK_CaseNotes] PRIMARY KEY CLUSTERED  ([CaseNotePK]) ON [PRIMARY]
GO
