CREATE TABLE [dbo].[CIParticipant]
(
[CIParticipantPK] [int] NOT NULL IDENTITY(1, 1),
[CIFollowUpFK] [int] NOT NULL,
[CIParticipantCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CIParticipant_CIParticipantCreateDate] DEFAULT (getdate()),
[CIParticipantCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CIParticipantEditDate] [datetime] NULL,
[CIParticipantEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIParticipantName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CIParticipantType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CriticalIncidentFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CIParticipantEditDate ON CIParticipant
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CIParticipantEditDate] ON [dbo].[CIParticipant]
For Update 
AS
Update CIParticipant Set CIParticipant.CIParticipantEditDate= getdate()
From [CIParticipant] INNER JOIN Inserted ON [CIParticipant].[CIParticipantPK]= Inserted.[CIParticipantPK]
GO
ALTER TABLE [dbo].[CIParticipant] ADD CONSTRAINT [PK__CIPartic__500BE60E1B0907CE] PRIMARY KEY CLUSTERED  ([CIParticipantPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIParticipant] WITH NOCHECK ADD CONSTRAINT [FK_CIParticipant_CIFollowUpFK] FOREIGN KEY ([CIFollowUpFK]) REFERENCES [dbo].[CIFollowUP] ([CIFollowUpPK])
GO
ALTER TABLE [dbo].[CIParticipant] WITH NOCHECK ADD CONSTRAINT [FK_CIParticipant_CriticalIncidentFK] FOREIGN KEY ([CriticalIncidentFK]) REFERENCES [dbo].[CriticalIncident] ([CriticalIncidentPK])
GO
