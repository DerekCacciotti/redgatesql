CREATE TABLE [dbo].[AuditC]
(
[AuditCPK] [int] NOT NULL IDENTITY(1, 1),
[AuditCCreateDate] [datetime] NOT NULL,
[AuditCCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuditCEditDate] [datetime] NOT NULL,
[AuditCEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DailyDrinks] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormFK] [int] NOT NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HowOften] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NOT NULL,
[Invalid] [bit] NULL,
[MoreThanSix] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Positive] [bit] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TotalScore] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [PK_AuditC] PRIMARY KEY CLUSTERED  ([AuditCPK]) ON [PRIMARY]
GO
