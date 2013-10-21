CREATE TABLE [dbo].[PCProgram]
(
[PCProgramPK] [int] NOT NULL IDENTITY(1, 1),
[PCFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_FK_PCProgram_PCFK] ON [dbo].[PCProgram] ([PCFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_PCProgram_ProgramFK] ON [dbo].[PCProgram] ([ProgramFK]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[PCProgram] ADD CONSTRAINT [PK__PCProgra__16BA68D059C55456] PRIMARY KEY CLUSTERED  ([PCProgramPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCProgram] WITH NOCHECK ADD CONSTRAINT [FK_PCProgram_PCFK] FOREIGN KEY ([PCFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
