CREATE TABLE [dbo].[MIECHVEligible]
(
[MIECHVEligiblePK] [int] NOT NULL IDENTITY(1, 1),
[PC1ID] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NULL,
[ProgramFK] [int] NULL,
[CaseStartDate] [datetime] NULL,
[DischargeDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MIECHVEligible] ADD CONSTRAINT [PK_MIECHVEligible] PRIMARY KEY CLUSTERED  ([MIECHVEligiblePK]) ON [PRIMARY]
GO
