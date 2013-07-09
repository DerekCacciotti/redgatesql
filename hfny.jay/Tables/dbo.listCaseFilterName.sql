CREATE TABLE [dbo].[listCaseFilterName]
(
[listCaseFilterNamePK] [int] NOT NULL IDENTITY(1, 1),
[FieldTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilterType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hint] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[Inactive] [bit] NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_FK_listCaseFilterName_ProgramFK] ON [dbo].[listCaseFilterName] ([ProgramFK]) ON [PRIMARY]

ALTER TABLE [dbo].[listCaseFilterName] WITH NOCHECK ADD
CONSTRAINT [FK_listCaseFilterName_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[listCaseFilterName] ADD CONSTRAINT [PK__listCase__7B14331F2A164134] PRIMARY KEY CLUSTERED  ([listCaseFilterNamePK]) ON [PRIMARY]
GO

EXEC sp_addextendedproperty N'MS_Description', N'Type of case filter; 1=On/Off, 2=Fixed Choices, 3=Free Form', 'SCHEMA', N'dbo', 'TABLE', N'listCaseFilterName', 'COLUMN', N'FilterType'
GO
