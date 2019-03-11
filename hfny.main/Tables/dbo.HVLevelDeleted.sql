CREATE TABLE [dbo].[HVLevelDeleted]
(
[HVLevelDeletedPK] [int] NOT NULL IDENTITY(1, 1),
[HVLevelPK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[HVLevelCreateDate] [datetime] NOT NULL,
[HVLevelCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLevelEditDate] [datetime] NULL,
[HVLevelEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelAssignDate] [datetime] NOT NULL,
[LevelFK] [int] NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLevelDeleted] ADD CONSTRAINT [PK__HVLevelDeleted] PRIMARY KEY CLUSTERED  ([HVLevelDeletedPK]) ON [PRIMARY]
GO
