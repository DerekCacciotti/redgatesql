CREATE TABLE [dbo].[ASQDeleted]
(
[ASQDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[ASQPK] [int] NULL,
[ASQCreateDate] [datetime] NOT NULL,
[ASQCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[ASQCommunicationScore] [numeric] (4, 1) NULL,
[ASQDeleteDate] [datetime] NULL,
[ASQDeleter] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQEditDate] [datetime] NULL,
[ASQEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQFineMotorScore] [numeric] (4, 1) NULL,
[ASQGrossMotorScore] [numeric] (4, 1) NULL,
[ASQInWindow] [bit] NULL,
[ASQPersonalSocialScore] [numeric] (4, 1) NULL,
[ASQProblemSolvingScore] [numeric] (4, 1) NULL,
[ASQTCReceiving] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCompleted] [datetime] NOT NULL,
[DevServicesStartDate] [date] NULL,
[DiscussedWithPC1] [bit] NULL,
[FSWFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ReviewCDS] [bit] NOT NULL,
[TCAge] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCIDFK] [int] NOT NULL,
[TCReferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnderCommunication] [bit] NULL,
[UnderFineMotor] [bit] NULL,
[UnderGrossMotor] [bit] NULL,
[UnderPersonalSocial] [bit] NULL,
[UnderProblemSolving] [bit] NULL,
[VersionNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQDeleted] ADD CONSTRAINT [PK__ASQDELETED] PRIMARY KEY CLUSTERED  ([ASQDeletedPK]) ON [PRIMARY]
GO
