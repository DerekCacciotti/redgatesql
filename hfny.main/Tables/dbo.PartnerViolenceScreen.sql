CREATE TABLE [dbo].[PartnerViolenceScreen]
(
[PartnerViolenceScreenPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[PVSDate] [datetime] NOT NULL,
[FeelSafeCurrentRelationship] [int] NULL,
[FeelSafeExplain] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreviousPartnerUnsafe] [int] NULL,
[PreviousPartnerExplain] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HurtBySomeone] [int] NULL,
[HurtExplain] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PVSCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PVSCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PartnerViolenceScreen_CreateDate] DEFAULT (getdate()),
[PVSEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PVSEditDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_delete_PVS]
on [dbo].[PartnerViolenceScreen]
After DELETE

AS

Declare @PK int

set @PK = (SELECT PartnerViolenceScreenPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PV'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_PVS]
on [dbo].[PartnerViolenceScreen]
After insert

AS

Declare @PK int

set @PK = (SELECT PartnerViolenceScreenPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PV'
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
create trigger [dbo].[fr_PVS_Edit]
on [dbo].[PartnerViolenceScreen]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = PartnerViolenceScreenPK FROM inserted
select @UpdatedFormDate = PVSDate FROM inserted
set @FormTypeValue = 'PV'

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
CREATE TRIGGER [dbo].[TR_PVSEditDate] ON [dbo].[PartnerViolenceScreen]
For Update 
AS
Update dbo.PartnerViolenceScreen Set PartnerViolenceScreen.PVSEditDate = getdate()
From [dbo].[PartnerViolenceScreen] 
INNER JOIN Inserted ON [PartnerViolenceScreen].[PartnerViolenceScreenPK]= Inserted.[PartnerViolenceScreenPK]
GO
ALTER TABLE [dbo].[PartnerViolenceScreen] ADD CONSTRAINT [PK_PartnerViolenceScreen] PRIMARY KEY CLUSTERED  ([PartnerViolenceScreenPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PartnerViolenceScreen] ADD CONSTRAINT [FK_PartnerViolenceScreen_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[PartnerViolenceScreen] ADD CONSTRAINT [FK_PartnerViolenceScreen_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
