CREATE TABLE [dbo].[AppOptions]
(
[AppOptionsPK] [int] NOT NULL IDENTITY(1, 1),
[AppName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionCreateDate] [datetime] NOT NULL CONSTRAINT [DF_AppOptions_OptionCreateDate] DEFAULT (getdate()),
[OptionCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AppOptions_OptionCreator] DEFAULT ('Existing'),
[OptionDataType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OptionDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionEditDate] [datetime] NULL,
[OptionEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionEnd] [datetime] NULL,
[OptionItem] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OptionStart] [datetime] NOT NULL,
[OptionValue] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_ASQEditDate ON ASQ
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_AppOptionsEditDate]
ON [dbo].[AppOptions]
FOR UPDATE
AS
UPDATE dbo.AppOptions
SET OptionEditDate = GETDATE()
FROM dbo.AppOptions ao
    INNER JOIN Inserted i
        ON i.AppOptionsPK = ao.AppOptionsPK;
GO
ALTER TABLE [dbo].[AppOptions] ADD CONSTRAINT [PK__AppOptio__6E5B65BC7F60ED59] PRIMARY KEY CLUSTERED  ([AppOptionsPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_AppOptions_ProgramFK] ON [dbo].[AppOptions] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppOptions] WITH NOCHECK ADD CONSTRAINT [FK_AppOptions_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
