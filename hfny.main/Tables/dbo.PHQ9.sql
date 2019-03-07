CREATE TABLE [dbo].[PHQ9]
(
[PHQ9PK] [int] NOT NULL IDENTITY(1, 1),
[Appetite] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadSelf] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BetterOffDead] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Concentration] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateAdministered] [datetime] NULL,
[DepressionReferralMade] [bit] NULL,
[Difficulty] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Down] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormFK] [int] NOT NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[Interest] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invalid] [bit] NULL,
[ParticipantRefused] [bit] NULL,
[PHQ9CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PHQ9_PHQ9CreateDate] DEFAULT (getdate()),
[PHQ9Creator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PHQ9EditDate] [datetime] NULL,
[PHQ9Editor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Positive] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[Sleep] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SlowOrFast] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tired] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalScore] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [dbo].[fr_delete_phq9]
on [dbo].[PHQ9]
After DELETE

AS

Declare @PK int

set @PK = (SELECT phq9pk from deleted)

BEGIN
	exec spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PQ'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [dbo].[fr_phq9]
on [dbo].[PHQ9]
After insert

AS

Declare @PK int

set @PK = (SELECT PHQ9PK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PQ'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[fr_phq9_Edit]
on [dbo].[PHQ9]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = phq9pk  FROM inserted
select @UpdatedFormDate = DateAdministered FROM inserted
set @FormTypeValue = 'PQ'

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
create TRIGGER [dbo].[TR_PHQ9EditDate] ON [dbo].[PHQ9]
For Update 
AS
Update PHQ9 Set PHQ9.PHQ9EditDate= getdate()
From [PHQ9] INNER JOIN Inserted ON [PHQ9].[PHQ9PK]= Inserted.[PHQ9PK]
GO
ALTER TABLE [dbo].[PHQ9] ADD CONSTRAINT [PK_PHQ9] PRIMARY KEY CLUSTERED  ([PHQ9PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PHQ9_HVCaseFK] ON [dbo].[PHQ9] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PHQ9_ProgramFK] ON [dbo].[PHQ9] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PHQ9] ADD CONSTRAINT [FK_PHQ9_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[PHQ9] ADD CONSTRAINT [FK_PHQ9_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
