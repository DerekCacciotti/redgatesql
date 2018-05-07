CREATE TABLE [dbo].[CaseProgramDeleted]
(
[CaseProgramDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[CaseProgramCreateDate] [datetime] NOT NULL,
[CaseProgramCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseProgramDeleteDate] [datetime] NULL,
[CaseProgramDeleter] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseProgramEditDate] [datetime] NULL,
[CaseProgramEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseStartDate] [datetime] NOT NULL,
[CurrentFAFK] [int] NULL,
[CurrentFAWFK] [int] NULL,
[CurrentFSWFK] [int] NULL,
[CurrentLevelDate] [datetime] NOT NULL,
[CurrentLevelFK] [int] NOT NULL,
[DischargeDate] [datetime] NULL,
[DischargeReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField1] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField2] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField3] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField4] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField5] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField6] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField7] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField8] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField9] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[HVCaseFK_old] [int] NOT NULL,
[OldID] [char] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ID] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[TransferredtoProgram] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferredtoProgramFK] [int] NULL,
[TransferredStatus] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseProgramDeleted] ADD CONSTRAINT [PK_CaseProgramDeleted] PRIMARY KEY CLUSTERED  ([CaseProgramDeletedPK]) ON [PRIMARY]
GO
