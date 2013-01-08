CREATE TABLE [dbo].[Training]
(
[TrainingPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[TrainerFK] [int] NULL,
[TrainingCreateDate] [datetime] NULL CONSTRAINT [DF_Training_TrainingCreateDate] DEFAULT (getdate()),
[TrainingCreator] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDate] [datetime] NULL,
[TrainingDays] [int] NULL,
[TrainingDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDuration] [int] NULL,
[TrainingEditDate] [datetime] NULL,
[TrainingEditor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingHours] [int] NULL,
[TrainingMinutes] [int] NULL,
[TrainingTitle] [char] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingMethodFK] [int] NULL,
[IsExempt] [bit] NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[Training] ADD 
CONSTRAINT [PK__Training__E8D0D89816CE6296] PRIMARY KEY CLUSTERED  ([TrainingPK]) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_delete_training]
on dbo.Training
After DELETE
AS
Declare @PK int

set @PK = (SELECT TrainingPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='TR'
END
GO

CREATE TRIGGER [dbo].[fr_Training]
on dbo.Training
After insert
AS
Declare @PK int
set @PK = (SELECT TrainingPK from inserted)
BEGIN
	EXEC spAddFormReview_userTriggernoHVCaseFK @FormFK=@PK, @FormTypeValue='TR'
END
GO

CREATE TRIGGER [dbo].[fr_Training_Edit]
on dbo.Training
AFTER UPDATE
AS
Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)
select @PK = TrainingPK FROM inserted
select @UpdatedFormDate = TrainingDate FROM inserted
set @FormTypeValue = 'TR'
BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue
END
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

ALTER TABLE [dbo].[Training] WITH NOCHECK ADD
CONSTRAINT [FK_Training_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD
CONSTRAINT [FK_Training_TrainerFK] FOREIGN KEY ([TrainerFK]) REFERENCES [dbo].[Trainer] ([TrainerPK])









GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[fr_Training]
on [dbo].[Training]
After insert

AS

Declare @PK int

set @PK = (SELECT TrainingPK from inserted)

BEGIN
	EXEC spAddFormReview_userTriggernoHVCaseFK @FormFK=@PK, @FormTypeValue='TR'
END
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[fr_Training_Edit]
on [dbo].[Training]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = TrainingPK FROM inserted
select @UpdatedFormDate = TrainingDate FROM inserted
set @FormTypeValue = 'TR'

BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue

END

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
