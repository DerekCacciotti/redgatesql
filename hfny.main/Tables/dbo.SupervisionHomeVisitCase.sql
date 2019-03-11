CREATE TABLE [dbo].[SupervisionHomeVisitCase]
(
[SupervisionHomeVisitCasePK] [int] NOT NULL IDENTITY(1, 1),
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChallengingIssues] [bit] NULL,
[ChallengingIssuesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChallengingIssuesStatus] [bit] NULL,
[CHEERSFeedback] [bit] NULL,
[CHEERSFeedbackComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSFeedbackStatus] [bit] NULL,
[FGPProgress] [bit] NULL,
[FGPProgressComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FGPProgressStatus] [bit] NULL,
[FollowUpHVCase] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[HVCPS] [bit] NULL,
[HVCPSComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCPSStatus] [bit] NULL,
[HVReferrals] [bit] NULL,
[HVReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVReferralsStatus] [bit] NULL,
[LevelChange] [bit] NULL,
[LevelChangeComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelChangeStatus] [bit] NULL,
[Medical] [bit] NULL,
[MedicalComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalStatus] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[ServicePlan] [bit] NULL,
[ServicePlanComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServicePlanStatus] [bit] NULL,
[SupervisionFK] [int] NOT NULL,
[SupervisionHomeVisitCaseCreateDate] [datetime] NULL CONSTRAINT [DF_SupervisionHomeVisitCase_SupervisionHomeVisitCaseCreateDate] DEFAULT (getdate()),
[SupervisionHomeVisitCaseCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupervisionHomeVisitCaseEditDate] [datetime] NULL,
[SupervisionHomeVisitCaseEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tools] [bit] NULL,
[ToolsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToolsStatus] [bit] NULL,
[TransitionPlanning] [bit] NULL,
[TransitionPlanningComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransitionPlanningStatus] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		bsimmons
-- Create date: 2/11/19
-- Description:	Record deletions of rows from SupervisionHomeVisitCase
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_SupervisionHomeVisitCase]
ON [dbo].[SupervisionHomeVisitCase]
AFTER DELETE
AS

BEGIN

	BEGIN TRY
		INSERT	INTO dbo.SupervisionHomeVisitCaseDeleted
		(
			SupervisionHomeVisitCasePK,
			CaseComments,
			ChallengingIssues,
			ChallengingIssuesComments,
			ChallengingIssuesStatus,
			CHEERSFeedback,
			CHEERSFeedbackComments,
			CHEERSFeedbackStatus,
			FGPProgress,
			FGPProgressComments,
			FGPProgressStatus,
			FollowUpHVCase,
			HVCaseFK,
			HVCPS, 
			HVCPSComments, 
			HVCPSStatus, 
			HVReferrals,
			HVReferralsComments,
			HVReferralsStatus,
			LevelChange,
			LevelChangeComments,
			LevelChangeStatus,
			Medical,
			MedicalComments,
			MedicalStatus,
			ProgramFK,
			ServicePlan,
			ServicePlanComments,
			ServicePlanStatus,
			SupervisionFK,
			SupervisionHomeVisitCaseCreateDate,
			SupervisionHomeVisitCaseCreator,
			SupervisionHomeVisitCaseEditDate,
			SupervisionHomeVisitCaseEditor,
			Tools,
			ToolsComments,
			ToolsStatus,
			TransitionPlanning,
			TransitionPlanningComments,
			TransitionPlanningStatus
		)
		SELECT	SupervisionHomeVisitCasePK,
				CaseComments,
				ChallengingIssues,
				ChallengingIssuesComments,
				ChallengingIssuesStatus,
				CHEERSFeedback,
				CHEERSFeedbackComments,
				CHEERSFeedbackStatus,
				FGPProgress,
				FGPProgressComments,
				FGPProgressStatus,
				FollowUpHVCase,
				HVCaseFK,
				HVCPS, 
				HVCPSComments, 
				HVCPSStatus, 
				HVReferrals,
				HVReferralsComments,
				HVReferralsStatus,
				LevelChange,
				LevelChangeComments,
				LevelChangeStatus,
				Medical,
				MedicalComments,
				MedicalStatus,
				ProgramFK,
				ServicePlan,
				ServicePlanComments,
				ServicePlanStatus,
				SupervisionFK,
				SupervisionHomeVisitCaseCreateDate,
				SupervisionHomeVisitCaseCreator,
				SupervisionHomeVisitCaseEditDate,
				SupervisionHomeVisitCaseEditor,
				Tools,
				ToolsComments,
				ToolsStatus,
				TransitionPlanning,
				TransitionPlanningComments,
				TransitionPlanningStatus
		FROM	Deleted d

	END TRY
    BEGIN CATCH
		INSERT INTO dbo.ELMAH_Error
		(
			ErrorId,
			Application,
			Host,
			Type,
			Source,
			Message,
			[User],
			StatusCode,
			TimeUtc,
			AllXml
		)
		VALUES
		(	NEWID(),		-- ErrorId - uniqueidentifier
			N'HFNY',		-- Application - nvarchar(60)
			N'Unknown',		-- Host - nvarchar(50)
			N'Custom SQL Server Error',		-- Type - nvarchar(100)
			N'fr_delete_SupervisionHomeVisitCase',		-- Source - nvarchar(60)
			ISNULL(ERROR_MESSAGE(), 'Error occured while inserting into the SupervisionHomeVisitCaseDeleted table'),		-- Message - nvarchar(500)
			N'CHSRUser',		-- User - nvarchar(50)
			0,			-- StatusCode - int
			GETDATE(),	-- TimeUtc - datetime
			N''			-- AllXml - ntext
			)
	END CATCH
END;
GO
ALTER TABLE [dbo].[SupervisionHomeVisitCase] ADD CONSTRAINT [PK_SupervisionHomeVisitCase] PRIMARY KEY CLUSTERED  ([SupervisionHomeVisitCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionHomeVisitCase] ADD CONSTRAINT [FK_SupervisionHomeVisitCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
