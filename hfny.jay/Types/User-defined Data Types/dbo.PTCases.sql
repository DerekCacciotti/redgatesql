CREATE TYPE [dbo].[PTCases] AS TABLE
(
[HVCaseFK] [int] NOT NULL,
[PC1ID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PC1FullName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentWorkerFK] [int] NOT NULL,
[CurrentWorkerFullName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentLevel] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
)
GO
