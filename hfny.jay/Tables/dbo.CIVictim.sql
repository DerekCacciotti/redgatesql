CREATE TABLE [dbo].[CIVictim]
(
[CIVictimPK] [int] NOT NULL IDENTITY(1, 1),
[CIVictimCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CIVictim_CIVictimCreateDate] DEFAULT (getdate()),
[CIVictimCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CIVictimEditDate] [datetime] NULL,
[CIVictimEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CriticalIncidentFK] [int] NOT NULL,
[IncidentType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VictimCategory] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VictimDOB] [datetime] NULL,
[VictimGender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VictimName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CIVictimEditDate ON CIVictim
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CIVictimEditDate] ON [dbo].[CIVictim]
For Update 
AS
Update CIVictim Set CIVictim.CIVictimEditDate= getdate()
From [CIVictim] INNER JOIN Inserted ON [CIVictim].[CIVictimPK]= Inserted.[CIVictimPK]
GO
ALTER TABLE [dbo].[CIVictim] ADD CONSTRAINT [PK__CIVictim__AB3402001FCDBCEB] PRIMARY KEY CLUSTERED  ([CIVictimPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIVictim] WITH NOCHECK ADD CONSTRAINT [FK_CIVictim_CriticalIncidentFK] FOREIGN KEY ([CriticalIncidentFK]) REFERENCES [dbo].[CriticalIncident] ([CriticalIncidentPK])
GO
