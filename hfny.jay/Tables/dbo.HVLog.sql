CREATE TABLE [dbo].[HVLog]
(
[HVLogPK] [int] NOT NULL IDENTITY(1, 1),
[CAChildSupport] [bit] NULL,
[CAAdvocacy] [bit] NULL,
[CAGoods] [bit] NULL,
[CAHousing] [bit] NULL,
[CALaborSupport] [bit] NULL,
[CALegal] [bit] NULL,
[CAOther] [bit] NULL,
[CAParentRights] [bit] NULL,
[CASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CATranslation] [bit] NULL,
[CATransportation] [bit] NULL,
[CAVisitation] [bit] NULL,
[CDChildDevelopment] [bit] NULL,
[CDOther] [bit] NULL,
[CDSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDToys] [bit] NULL,
[CIProblems] [bit] NULL,
[CIOther] [bit] NULL,
[CIOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Curriculum247Dads] [bit] NULL,
[CurriculumBoyz2Dads] [bit] NULL,
[CurriculumGrowingGreatKids] [bit] NULL,
[CurriculumHelpingBabiesLearn] [bit] NULL,
[CurriculumInsideOutDads] [bit] NULL,
[CurriculumMomGateway] [bit] NULL,
[CurriculumOther] [bit] NULL,
[CurriculumOtherSpecify] [bit] NULL,
[CurriculumParentsForLearning] [bit] NULL,
[CurriculumPartnersHealthyBaby] [bit] NULL,
[CurriculumPAT] [bit] NULL,
[CurriculumPATFocusFathers] [bit] NULL,
[CurriculumSanAngelo] [bit] NULL,
[FatherAdvocateParticipated] [bit] NULL,
[FatherFigureParticipated] [bit] NULL,
[FSWFK] [int] NULL,
[GrandParentParticipated] [bit] NULL,
[HCBreastFeeding] [bit] NULL,
[HCChild] [bit] NULL,
[HCDental] [bit] NULL,
[HCFamilyPlanning] [bit] NULL,
[HCFASD] [bit] NULL,
[HCFeeding] [bit] NULL,
[HCGeneral] [bit] NULL,
[HCMedicalAdvocacy] [bit] NULL,
[HCNutrition] [bit] NULL,
[HCOther] [bit] NULL,
[HCPrenatalCare] [bit] NULL,
[HCProviders] [bit] NULL,
[HCSafety] [bit] NULL,
[HCSexEducation] [bit] NULL,
[HCSIDS] [bit] NULL,
[HCSmoking] [bit] NULL,
[HCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[HVLogCreateDate] [datetime] NOT NULL,
[HVLogCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLogEditDate] [datetime] NULL,
[HVLogEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVSupervisorParticipated] [bit] NULL,
[NonPrimaryFSWParticipated] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBPParticipated] [bit] NULL,
[OtherLocationSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherParticipated] [bit] NULL,
[PAAssessmentIssues] [bit] NULL,
[PAForms] [bit] NULL,
[PAGroups] [bit] NULL,
[PAIFSP] [bit] NULL,
[PAOther] [bit] NULL,
[PARecreation] [bit] NULL,
[ParentCompletedActivity] [bit] NULL,
[ParentObservationsDiscussed] [bit] NULL,
[ParticipatedSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAVideo] [bit] NULL,
[PC1Participated] [bit] NULL,
[PC2Participated] [bit] NULL,
[PCBasicNeeds] [bit] NULL,
[PCChildInteraction] [bit] NULL,
[PCChildManagement] [bit] NULL,
[PCFeelings] [bit] NULL,
[PCOther] [bit] NULL,
[PCShakenBaby] [bit] NULL,
[PCShakenBabyVideo] [bit] NULL,
[PCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCStress] [bit] NULL,
[ProgramFK] [int] NULL,
[ReviewAssessmentIssues] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiblingParticipated] [bit] NULL,
[SSCalendar] [bit] NULL,
[SSChildCare] [bit] NULL,
[SSEducation] [bit] NULL,
[SSEmployment] [bit] NULL,
[SSHousekeeping] [bit] NULL,
[SSJob] [bit] NULL,
[SSMoneyManagement] [bit] NULL,
[SSOther] [bit] NULL,
[SSProblemSolving] [bit] NULL,
[SSSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSTransportation] [bit] NULL,
[SupervisorObservation] [bit] NULL,
[TCParticipated] [bit] NULL,
[TotalPercentageSpent] [int] NULL,
[UpcomingProgramEvents] [bit] NULL,
[VisitLengthHour] [int] NOT NULL,
[VisitLengthMinute] [int] NOT NULL,
[VisitLocation] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VisitStartTime] [datetime] NOT NULL,
[VisitType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_hvlog]
on dbo.HVLog
After DELETE

AS

Declare @PK int

set @PK = (SELECT HVLOGPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='VL'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_hvlog]
on dbo.HVLog
After insert

AS

Declare @PK int

set @PK = (SELECT HVLogPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='VL'
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
CREATE TRIGGER [dbo].[fr_HVLog_Edit]
on dbo.HVLog
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = HVLogPK  FROM inserted
select @UpdatedFormDate = VisitStartTime FROM inserted
set @FormTypeValue = 'VL'

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
CREATE TRIGGER [dbo].[TR_HVLogEditDate] ON dbo.HVLog
For Update 
AS
Update HVLog Set HVLog.HVLogEditDate= getdate()
From [HVLog] INNER JOIN Inserted ON [HVLog].[HVLogPK]= Inserted.[HVLogPK]
GO
ALTER TABLE [dbo].[HVLog] ADD CONSTRAINT [PK__HVLog__ED876F581332DBDC] PRIMARY KEY CLUSTERED  ([HVLogPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
