CREATE TABLE [dbo].[HITS]
(
[HITSPK] [int] NOT NULL IDENTITY(1, 1),
[FormFK] [int] NOT NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HITSCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HITS_HITSCreateDate] DEFAULT (getdate()),
[HITSCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HITSEditDate] [datetime] NULL,
[HITSEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Hurt] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NOT NULL,
[Insult] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Invalid] [bit] NOT NULL,
[NotDoneReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Positive] [bit] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Scream] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Threaten] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TotalScore] [int] NOT NULL
) ON [PRIMARY]
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseProgramEditDate ON CaseProgram
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
create TRIGGER [dbo].[TR_HITSEditDate] ON [dbo].[HITS]
For Update 
AS
Update HITS Set HITS.HITSEditDate= getdate()
From [HITS] INNER JOIN Inserted ON [HITS].[HITSPK]= Inserted.[HITSPK]
GO

ALTER TABLE [dbo].[HITS] ADD CONSTRAINT [PK_HITS] PRIMARY KEY CLUSTERED  ([HITSPK]) ON [PRIMARY]
GO