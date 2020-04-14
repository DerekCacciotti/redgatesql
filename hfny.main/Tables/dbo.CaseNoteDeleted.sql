CREATE TABLE [dbo].[CaseNoteDeleted]
(
[CaseNoteDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[CaseNotePK] [int] NOT NULL,
[CaseNoteContents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteCreateDate] [datetime] NULL,
[CaseNoteCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseNoteDeleteDate] [datetime] NOT NULL,
[CaseNotesDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteDate] [date] NULL,
[CaseNoteEditDate] [datetime] NULL,
[CaseNoteEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseNoteDeleted] ADD CONSTRAINT [PK__CaseNote__2537E72D12CE074B] PRIMARY KEY CLUSTERED  ([CaseNoteDeletedPK]) ON [PRIMARY]
GO
