CREATE TABLE [dbo].[ASQSEDeleted]
(
[ASQSEDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[ASQSEPK] [int] NOT NULL,
[ASQSECreateDate] [datetime] NOT NULL,
[ASQSECreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASQSEDateCompleted] [datetime] NOT NULL,
[ASQSEDeleteDate] [datetime] NULL,
[ASQSEDeleter] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSEEditDate] [datetime] NULL,
[ASQSEEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSEInWindow] [bit] NOT NULL,
[ASQSEOverCutOff] [bit] NOT NULL,
[ASQSEReceiving] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSEReferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSETCAge] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASQSETotalScore] [numeric] (4, 1) NOT NULL,
[ASQSEVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiscussedWithPC1] [bit] NULL,
[FSWFK] [int] NOT NULL,
[ReviewCDS] [bit] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TCIDFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQSEDeleted] ADD CONSTRAINT [PK__ASQSEDeleted] PRIMARY KEY CLUSTERED  ([ASQSEDeletedPK]) ON [PRIMARY]
GO
