CREATE TABLE [dbo].[UNCOPE]
(
[UNCOPEPK] [int] NOT NULL IDENTITY(1, 1),
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[FSWFK] [int] NOT NULL,
[UNCOPEDate] [datetime] NOT NULL,
[Used] [int] NULL,
[Neglected] [int] NULL,
[CutDown] [int] NULL,
[Objected] [int] NULL,
[Preoccupied] [int] NULL,
[EmotionalDiscomfort] [int] NULL,
[Score] [int] NULL,
[UNCOPECreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UNCOPECreateDate] [datetime] NOT NULL CONSTRAINT [DF_UNCOPE_UNCOPECreateDate] DEFAULT (getdate()),
[UNCOPEEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UNCOPEEditDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_delete_UNCOPE]
on [dbo].[UNCOPE]
After DELETE

AS

Declare @PK int

set @PK = (SELECT UNCOPEPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='UN'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_UNCOPE]
on [dbo].[UNCOPE]
After insert

AS

Declare @PK int

set @PK = (SELECT UNCOPEPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='UN'
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
CREATE trigger [dbo].[fr_UNCOPE_Edit]
on [dbo].[UNCOPE]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = UNCOPEPK FROM inserted
select @UpdatedFormDate = UNCOPEDate FROM inserted
set @FormTypeValue = 'UN'

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
CREATE TRIGGER [dbo].[TR_UNCOPEEditDate] ON [dbo].[UNCOPE]
For Update 
AS
Update dbo.UNCOPE Set UNCOPE.UNCOPEEditDate = getdate()
From [dbo].[UNCOPE] 
INNER JOIN Inserted ON [UNCOPE].[UNCOPEPK]= Inserted.[UNCOPEPK]
GO
ALTER TABLE [dbo].[UNCOPE] ADD CONSTRAINT [PK_UNCOPE] PRIMARY KEY CLUSTERED  ([UNCOPEPK]) ON [PRIMARY]
GO
