CREATE TABLE [dbo].[CriticalIncident]
(
[CriticalIncidentPK] [int] NOT NULL IDENTITY(1, 1),
[ActionTaken] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignedWorkerFK] [int] NULL,
[CriticalIncidentCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CriticalIncident_CriticalIncidentCreateDate] DEFAULT (getdate()),
[CriticalIncidentCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CriticalIncidentDate] [datetime] NOT NULL,
[CriticalIncidentEditDate] [datetime] NULL,
[CriticalIncidentEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSReportMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSReportSubstantiated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpDue] [datetime] NULL,
[FollowUpRequired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[IncidentDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentReportedBy] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentReportedTo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentResolved] [bit] NULL,
[IncidentTime] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCANJNotifiedDate] [datetime] NULL,
[PCNJIncidentReportedTo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCNJNotificationReceived] [datetime] NULL,
[PCNJReportedVia] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[ServiceLevelFK] [int] NULL,
[SiteInformedDate] [datetime] NULL,
[StaffReport] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorFK] [int] NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_FK_CriticalIncident_AssignedWorkerFK] ON [dbo].[CriticalIncident] ([AssignedWorkerFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CriticalIncident_HVCaseFK] ON [dbo].[CriticalIncident] ([HVCaseFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CriticalIncident_ProgramFK] ON [dbo].[CriticalIncident] ([ProgramFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CriticalIncident_ServiceLevelFK] ON [dbo].[CriticalIncident] ([ServiceLevelFK]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_FK_CriticalIncident_SupervisorFK] ON [dbo].[CriticalIncident] ([SupervisorFK]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_CriticalIncident]
on [dbo].[CriticalIncident]
After insert

AS

Declare @PK int

set @PK = (SELECT CriticalIncidentPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='CI'
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
CREATE TRIGGER [dbo].[fr_CriticalIncident_Edit]
on [dbo].[CriticalIncident]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = CriticalIncidentPK  FROM inserted
select @UpdatedFormDate = CriticalIncidentDate FROM inserted
set @FormTypeValue = 'CI'

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
Create TRIGGER [dbo].[fr_delete_CriticalIncident]
on [dbo].[CriticalIncident]
After DELETE

AS

Declare @PK int

set @PK = (SELECT CriticalIncidentPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='CI'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CriticalIncidentEditDate ON CriticalIncident
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CriticalIncidentEditDate] ON [dbo].[CriticalIncident]
For Update 
AS
Update CriticalIncident Set CriticalIncident.CriticalIncidentEditDate= getdate()
From [CriticalIncident] INNER JOIN Inserted ON [CriticalIncident].[CriticalIncidentPK]= Inserted.[CriticalIncidentPK]
GO
ALTER TABLE [dbo].[CriticalIncident] ADD CONSTRAINT [PK__Critical__C34E6F0D5EBF139D] PRIMARY KEY CLUSTERED  ([CriticalIncidentPK]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CriticalIncident] WITH NOCHECK ADD CONSTRAINT [FK_CriticalIncident_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CriticalIncident] WITH NOCHECK ADD CONSTRAINT [FK_CriticalIncident_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[CriticalIncident] WITH NOCHECK ADD CONSTRAINT [FK_CriticalIncident_ServiceLevelFK] FOREIGN KEY ([ServiceLevelFK]) REFERENCES [dbo].[HVLevel] ([HVLevelPK])
GO
