CREATE TABLE [dbo].[codeSAT]
(
[codeSATPK] [int] NOT NULL IDENTITY(1, 1),
[codeSATPK_old] [int] NOT NULL,
[ProgramFK] [int] NULL,
[SATCompareDateField] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SATDescription] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SATInterval] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SATName] [char] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_FK_codeSAT_ProgramFK] ON [dbo].[codeSAT] ([ProgramFK]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[codeSAT] ADD CONSTRAINT [PK__codeSAT__0E8D13AB4AB81AF0] PRIMARY KEY CLUSTERED  ([codeSATPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeSAT] WITH NOCHECK ADD CONSTRAINT [FK_codeSAT_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
