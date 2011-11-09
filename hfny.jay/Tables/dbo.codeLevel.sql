CREATE TABLE [dbo].[codeLevel]
(
[codeLevelPK] [int] NOT NULL IDENTITY(1, 1),
[CaseWeight] [numeric] (4, 2) NOT NULL,
[Enrolled] [bit] NULL,
[LevelGroup] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LevelName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaximumVisit] [numeric] (2, 0) NULL,
[MinimumVisit] [numeric] (2, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeLevel] ADD CONSTRAINT [PK__codeLeve__7F907A764316F928] PRIMARY KEY CLUSTERED  ([codeLevelPK]) ON [PRIMARY]
GO
