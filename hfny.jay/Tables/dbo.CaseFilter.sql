CREATE TABLE [dbo].[CaseFilter]
(
[CaseFilterPK] [int] NOT NULL IDENTITY(1, 1),
[CaseFilterNameFK] [int] NOT NULL,
[CaseFilterCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseFilter_CaseFilterCreateDate] DEFAULT (getdate()),
[CaseFilterCreator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseFilterEditDate] [datetime] NULL,
[CaseFilterEditor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseFilterNameChoice] [bit] NULL,
[CaseFilterNameOptionFK] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseFilterValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD
CONSTRAINT [FK_CaseFilter_CaseFilterNameFK] FOREIGN KEY ([CaseFilterNameFK]) REFERENCES [dbo].[listCaseFilterName] ([listCaseFilterNamePK])
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseFilterEditDate ON CaseFilter
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CaseFilterEditDate] ON [dbo].[CaseFilter]
For Update 
AS
Update CaseFilter Set CaseFilter.CaseFilterEditDate= getdate()
From [CaseFilter] INNER JOIN Inserted ON [CaseFilter].[CaseFilterPK]= Inserted.[CaseFilterPK]
GO
ALTER TABLE [dbo].[CaseFilter] ADD CONSTRAINT [PK__CaseFilt__9E62C9EB0CBAE877] PRIMARY KEY CLUSTERED  ([CaseFilterPK]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD CONSTRAINT [FK_CaseFilter_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD CONSTRAINT [FK_CaseFilter_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
