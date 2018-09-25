CREATE TABLE [dbo].[SupervisionCase]
(
[SupervisionCasePK] [int] NOT NULL IDENTITY(1, 1),
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[SupervisionFK] [int] NOT NULL,
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionCase] ADD CONSTRAINT [PK_SupervisionCase] PRIMARY KEY CLUSTERED  ([SupervisionCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionCase] WITH NOCHECK ADD CONSTRAINT [FK_SupervisionCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
