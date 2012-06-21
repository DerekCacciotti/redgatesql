CREATE TABLE [dbo].[Training]
(
[TrainingPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[TrainerFK] [int] NULL,
[TrainingMethodFK] [int] NULL,
[TrainingCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Training_TrainingCreateDate] DEFAULT (getdate()),
[TrainingCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingDate] [datetime] NOT NULL,
[TrainingDays] [int] NOT NULL,
[TrainingDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDuration] [int] NOT NULL,
[TrainingEditDate] [datetime] NULL,
[TrainingEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingHours] [int] NOT NULL,
[TrainingMinutes] [int] NOT NULL,
[TrainingPK_old] [int] NOT NULL,
[TrainingTitle] [char] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[Training] ADD
CONSTRAINT [FK_Training_TrainingMethodFK] FOREIGN KEY ([TrainingMethodFK]) REFERENCES [dbo].[TrainingMethod] ([TrainingMethodPK])
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingEditDate ON Training
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingEditDate] ON dbo.Training
For Update 
AS
Update Training Set Training.TrainingEditDate= getdate()
From [Training] INNER JOIN Inserted ON [Training].[TrainingPK]= Inserted.[TrainingPK]
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [PK__Training__E8D0D89816CE6296] PRIMARY KEY CLUSTERED  ([TrainingPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD CONSTRAINT [FK_Training_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD CONSTRAINT [FK_Training_TrainerFK] FOREIGN KEY ([TrainerFK]) REFERENCES [dbo].[Trainer] ([TrainerPK])
GO
