CREATE TABLE [dbo].[CIFollowUP]
(
[CIFollowUpPK] [int] NOT NULL IDENTITY(1, 1),
[ActionTaken] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIFollowUpCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CIFollowUP_CIFollowUpCreateDate] DEFAULT (getdate()),
[CIFollowUpCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CIFollowUpEditDate] [datetime] NULL,
[CIFollowUpEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CriticalIncidentFK] [int] NOT NULL,
[FollowUpDue] [datetime] NULL,
[HVCaseFK] [int] NOT NULL,
[IncidentFollowUpDate] [datetime] NOT NULL,
[IncidentResolved] [bit] NULL,
[MoreFollowUpNeeded] [bit] NULL,
[NewCriticalIncidentInfo] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewDFYSReportMade] [bit] NULL,
[OriginalIncidentDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ReportByStaff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportSubstantiated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_FK_CIFollowUP_CriticalIncidentFK] ON [dbo].[CIFollowUP] ([CriticalIncidentFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CIFollowUP_HVCaseFK] ON [dbo].[CIFollowUP] ([HVCaseFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CIFollowUP_ProgramFK] ON [dbo].[CIFollowUP] ([ProgramFK]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_CIFollowUp]
on [dbo].[CIFollowUP]
After insert

AS

Declare @PK int

set @PK = (SELECT CIFollowUpPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='IF'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/18/2010
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
CREATE TRIGGER [dbo].[fr_CIFollowUp_Edit]
on [dbo].[CIFollowUP]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = CIFollowUpPK FROM inserted
select @UpdatedFormDate = OriginalIncidentDate FROM inserted
set @FormTypeValue = 'IF'

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
Create TRIGGER [dbo].[fr_delete_CIFollowUp]
on [dbo].[CIFollowUP]
After DELETE

AS

Declare @PK int

set @PK = (SELECT CIFollowUpPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='IF'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CIFollowUpEditDate ON CIFollowUP
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CIFollowUpEditDate] ON [dbo].[CIFollowUP]
For Update 
AS
Update CIFollowUP Set CIFollowUP.CIFollowUpEditDate= getdate()
From [CIFollowUP] INNER JOIN Inserted ON [CIFollowUP].[CIFollowUpPK]= Inserted.[CIFollowUpPK]
GO
ALTER TABLE [dbo].[CIFollowUP] ADD CONSTRAINT [PK__CIFollow__7F7C376F164452B1] PRIMARY KEY CLUSTERED  ([CIFollowUpPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIFollowUP] WITH NOCHECK ADD CONSTRAINT [FK_CIFollowUP_CriticalIncidentFK] FOREIGN KEY ([CriticalIncidentFK]) REFERENCES [dbo].[CriticalIncident] ([CriticalIncidentPK])
GO
ALTER TABLE [dbo].[CIFollowUP] WITH NOCHECK ADD CONSTRAINT [FK_CIFollowUP_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CIFollowUP] WITH NOCHECK ADD CONSTRAINT [FK_CIFollowUP_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
