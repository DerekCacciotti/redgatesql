CREATE TABLE [dbo].[State]
(
[StatePK] [int] NOT NULL IDENTITY(1, 1),
[Abbreviation] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[State] ADD CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED  ([StatePK]) ON [PRIMARY]
GO
