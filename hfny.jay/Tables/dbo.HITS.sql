CREATE TABLE [dbo].[HITS]
(
[HITSPK] [int] NOT NULL IDENTITY(1, 1),
[FormFK] [int] NOT NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HITSCreateDate] [datetime] NOT NULL,
[HITSCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HITSEditDate] [datetime] NULL,
[HITSEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[Invalid] [bit] NOT NULL,
[Positive] [bit] NOT NULL,
[TotalScore] [int] NOT NULL,
[Hurt] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Insult] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotDoneReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Scream] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Threaten] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HITS] ADD CONSTRAINT [PK_HITS] PRIMARY KEY CLUSTERED  ([HITSPK]) ON [PRIMARY]
GO
