CREATE TABLE [dbo].[CaseNote]
(
[CaseNotePK] [int] NOT NULL IDENTITY(1, 1),
[CaseNoteContents] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseNotes_CaseNotesCreateDate] DEFAULT (getdate()),
[CaseNoteCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseNoteDate] [date] NULL,
[CaseNoteEditDate] [datetime] NULL,
[CaseNoteEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseNoteEditDate ON CaseNote
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
create TRIGGER [dbo].[TR_CaseNoteEditDate] ON [dbo].[CaseNote]
For Update 
AS
Update CaseNote set CaseNote.CaseNoteEditDate= getdate()
From [CaseNote] INNER JOIN Inserted ON [CaseNote].[CaseNotePK]= Inserted.[CaseNotePK]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_delCaseNote] ON [dbo].[CaseNote] AFTER DELETE AS

DECLARE @notepk INT = (SELECT Deleted.CaseNotePK FROM Deleted)
INSERT INTO CaseNoteDeleted
(
    CaseNotePK,
    CaseNoteContents,
    CaseNoteCreateDate,
    CaseNoteCreator,
    CaseNoteDeleteDate,
    CaseNotesDeleter,
    CaseNoteDate,
    CaseNoteEditDate,
    CaseNoteEditor,
    HVCaseFK,
    ProgramFK
)
SELECT d.CaseNotePK, d.CaseNoteContents, d.CaseNoteCreateDate, d.CaseNoteCreator, GETDATE(),
NULL, d.CaseNoteDate, d.CaseNoteEditDate, d.CaseNoteEditor, d.HVCaseFK, d.ProgramFK
FROM Deleted d 
WHERE d.CaseNotePK = @notepk
GO
ALTER TABLE [dbo].[CaseNote] ADD CONSTRAINT [PK_CaseNotes] PRIMARY KEY CLUSTERED  ([CaseNotePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_CaseNote_0DD622D0101BDAF66E3E2FD861BBC842] ON [dbo].[CaseNote] ([HVCaseFK], [ProgramFK]) INCLUDE ([CaseNoteContents], [CaseNoteCreateDate], [CaseNoteCreator], [CaseNoteDate], [CaseNoteEditDate], [CaseNoteEditor]) ON [PRIMARY]
GO
