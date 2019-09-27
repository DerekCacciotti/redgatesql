CREATE TABLE [dbo].[CaseView]
(
[CaseViewPK] [int] NOT NULL IDENTITY(1, 1),
[PC1ID] [nchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseView] ADD CONSTRAINT [PK_CaseView] PRIMARY KEY CLUSTERED  ([CaseViewPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseView_PC1ID] ON [dbo].[CaseView] ([PC1ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseView_UserName] ON [dbo].[CaseView] ([Username]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_CaseView_FB287D283711DF6DC75D9F952EE660CB] ON [dbo].[CaseView] ([Username]) INCLUDE ([PC1ID], [ViewDate]) ON [PRIMARY]
GO
