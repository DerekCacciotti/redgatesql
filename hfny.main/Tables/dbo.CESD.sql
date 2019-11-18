CREATE TABLE [dbo].[CESD]
(
[CESDPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[CESDDate] [datetime] NOT NULL,
[Bothered] [int] NULL,
[PoorAppetite] [int] NULL,
[CantShakeBlues] [int] NULL,
[GoodAsOthers] [int] NULL,
[TroubleKeepingMind] [int] NULL,
[Depressed] [int] NULL,
[EverythingAnEffort] [int] NULL,
[Hopeful] [int] NULL,
[Failure] [int] NULL,
[Fearful] [int] NULL,
[RestlessSleep] [int] NULL,
[Happy] [int] NULL,
[TalkedLess] [int] NULL,
[Lonely] [int] NULL,
[UnfriendlyPeople] [int] NULL,
[EnjoyLife] [int] NULL,
[Crying] [int] NULL,
[Sad] [int] NULL,
[PeopleDislikeMe] [int] NULL,
[CantGetGoing] [int] NULL,
[Score] [int] NULL,
[CESDCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CESDCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CESD_CESDCreateDate] DEFAULT (getdate()),
[CESDEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CESDEditDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_CESD]
on [dbo].[CESD]
After insert

AS

Declare @PK int

set @PK = (SELECT CESDPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='CE'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 10/30/2019
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
CREATE trigger [dbo].[fr_CESD_Edit]
on [dbo].[CESD]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = CESDPK FROM inserted
select @UpdatedFormDate = CESDDate FROM inserted
set @FormTypeValue = 'CE'

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
CREATE TRIGGER [dbo].[fr_delete_CESD]
on [dbo].[CESD]
After DELETE

AS

Declare @PK int

set @PK = (SELECT CESDPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='CE'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[TR_CESDEditDate] ON [dbo].[CESD]
For Update 
AS
Update dbo.CESD Set CESD.CESDEditDate = getdate()
From [dbo].[CESD] 
INNER JOIN Inserted ON [CESD].[CESDPK]= Inserted.[CESDPK]
GO
ALTER TABLE [dbo].[CESD] ADD CONSTRAINT [PK_CESD] PRIMARY KEY CLUSTERED  ([CESDPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CESD] ADD CONSTRAINT [FK_CESD_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CESD] ADD CONSTRAINT [FK_CESD_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
