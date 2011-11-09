CREATE TABLE [dbo].[listCaseCriteria]
(
[listCaseCriteriaPK] [int] NOT NULL IDENTITY(1, 1),
[FieldTitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Hint] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listCaseCriteria] ADD CONSTRAINT [PK__listCase__7B14331F2A164134] PRIMARY KEY CLUSTERED  ([listCaseCriteriaPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listCaseCriteria] WITH NOCHECK ADD CONSTRAINT [FK_listCaseCriteria_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
