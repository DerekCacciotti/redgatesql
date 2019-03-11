CREATE TABLE [dbo].[SupervisionParentSurveyCase]
(
[SupervisionParentSurveyCasePK] [int] NOT NULL IDENTITY(1, 1),
[AssessmentIssues] [bit] NULL,
[AssessmentIssuesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssessmentIssuesStatus] [bit] NULL,
[CaseComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpPSCase] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProtectiveFactors] [bit] NULL,
[ProtectiveFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProtectiveFactorsStatus] [bit] NULL,
[PSServicePlan] [bit] NULL,
[PSServicePlanComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSServicePlanStatus] [bit] NULL,
[Referrals] [bit] NULL,
[ReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralsStatus] [bit] NULL,
[RiskFactors] [bit] NULL,
[RiskFactorsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskFactorsStatus] [bit] NULL,
[SupervisionFK] [int] NOT NULL,
[SupervisionParentSurveyCaseCreateDate] [datetime] NULL CONSTRAINT [DF_SupervisionParentSurveyCase_SupervisionParentSurveyCaseCreateDate] DEFAULT (getdate()),
[SupervisionParentSurveyCaseCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SupervisionParentSurveyCaseEditDate] [datetime] NULL,
[SupervisionParentSurveyCaseEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		bsimmons
-- Create date: 2/11/19
-- Description:	Record deletions of rows from SupervisionParentSurveyCase
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_SupervisionParentSurveyCase]
ON [dbo].[SupervisionParentSurveyCase]
AFTER DELETE
AS

BEGIN

	BEGIN TRY
		INSERT	INTO dbo.SupervisionParentSurveyCaseDeleted
		(
			SupervisionParentSurveyCasePK,
			AssessmentIssues,
			AssessmentIssuesComments,
			AssessmentIssuesStatus,
			CaseComments,
			FollowUpPSCase,
			HVCaseFK,
			ProgramFK,
			ProtectiveFactors,
			ProtectiveFactorsComments,
			ProtectiveFactorsStatus,
			PSServicePlan,
			PSServicePlanComments,
			PSServicePlanStatus,
			Referrals,
			ReferralsComments,
			ReferralsStatus,
			RiskFactors,
			RiskFactorsComments,
			RiskFactorsStatus,
			SupervisionFK,
			SupervisionParentSurveyCaseCreateDate,
			SupervisionParentSurveyCaseCreator,
			SupervisionParentSurveyCaseEditDate,
			SupervisionParentSurveyCaseEditor
		)
		SELECT	SupervisionParentSurveyCasePK,
				AssessmentIssues,
				AssessmentIssuesComments,
				AssessmentIssuesStatus,
				CaseComments,
				FollowUpPSCase,
				HVCaseFK,
				ProgramFK,
				ProtectiveFactors,
				ProtectiveFactorsComments,
				ProtectiveFactorsStatus,
				PSServicePlan,
				PSServicePlanComments,
				PSServicePlanStatus,
				Referrals,
				ReferralsComments,
				ReferralsStatus,
				RiskFactors,
				RiskFactorsComments,
				RiskFactorsStatus,
				SupervisionFK,
				SupervisionParentSurveyCaseCreateDate,
				SupervisionParentSurveyCaseCreator,
				SupervisionParentSurveyCaseEditDate,
				SupervisionParentSurveyCaseEditor
		FROM	Deleted d ;

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
				N'fr_delete_SupervisionParentSurveyCase',		-- Source - nvarchar(60)
				ISNULL(ERROR_MESSAGE(), 'Error occured while inserting into the SupervisionParentSurveyCaseDeleted table'),		-- Message - nvarchar(500)
				N'CHSRUser',		-- User - nvarchar(50)
				0,			-- StatusCode - int
				GETDATE(),	-- TimeUtc - datetime
				N''			-- AllXml - ntext
				)
	END CATCH
END;
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] ADD CONSTRAINT [PK_SupervisionParentSurveyCase] PRIMARY KEY CLUSTERED  ([SupervisionParentSurveyCasePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupervisionParentSurveyCase] ADD CONSTRAINT [FK_SupervisionParentSurveyCase_SupervisionFK] FOREIGN KEY ([SupervisionFK]) REFERENCES [dbo].[Supervision] ([SupervisionPK])
GO
