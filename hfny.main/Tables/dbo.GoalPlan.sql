CREATE TABLE [dbo].[GoalPlan]
(
[GoalPlanPK] [int] NOT NULL IDENTITY(1, 1),
[AnticipatedAchievementDate] [datetime] NOT NULL,
[GoalArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalCreationDiscussion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPertainsTo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPertainsToSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalPlanActive] [bit] NOT NULL,
[GoalPlanCreateDate] [datetime] NOT NULL CONSTRAINT [DF_GoalPlan_GoalPlanCreateDate] DEFAULT (getdate()),
[GoalPlanCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanEditDate] [datetime] NULL,
[GoalPlanEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalProblemSolvingAndPlan] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatement] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalStatusDate] [datetime] NOT NULL,
[IsConsentSigned] [bit] NOT NULL CONSTRAINT [DF_GoalPlan_IsConsentSigned] DEFAULT ((0)),
[IsTransitionPlan] [bit] NOT NULL CONSTRAINT [DF_GoalPlan_IsTransitionPlan] DEFAULT ((0)),
[NextStep] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProtectiveFactors] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServicePartners] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NOT NULL,
[HVCaseFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 05/31/18
-- Description:	This trigger records the deletion of a goal plan row
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_GoalPlan]
   ON  [dbo].[GoalPlan]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO dbo.GoalPlanDeleted
	(
	    GoalPlanPK,
	    AnticipatedAchievementDate,
		Deleted,
	    GoalArea,
	    GoalCreationDiscussion,
		GoalName,
	    GoalPertainsTo,
		GoalPertainsToSpecify,
	    GoalPlanActive,
	    GoalPlanCreateDate,
	    GoalPlanCreator,
	    GoalPlanEditDate,
	    GoalPlanEditor,
	    GoalProblemSolvingAndPlan,
	    GoalStatement,
		GoalStatus,
		GoalStatusDate,
		IsConsentSigned,
		IsTransitionPlan,
	    NextStep,
	    ProtectiveFactors,
		ServicePartners,
	    StartDate,
	    HVCaseFK
	)
	SELECT 
	    d.GoalPlanPK,
	    d.AnticipatedAchievementDate,
		1,  --This was a delete
	    d.GoalArea,
	    d.GoalCreationDiscussion,
		d.GoalName,
	    d.GoalPertainsTo,
		d.GoalPertainsToSpecify,
	    d.GoalPlanActive,
	    d.GoalPlanCreateDate,
	    d.GoalPlanCreator,
	    d.GoalPlanEditDate,
	    d.GoalPlanEditor,
	    d.GoalProblemSolvingAndPlan,
	    d.GoalStatement,
		d.GoalStatus,
		d.GoalStatusDate,
		d.IsConsentSigned,
		d.IsTransitionPlan,
	    d.NextStep,
	    d.ProtectiveFactors,
		d.ServicePartners,
	    d.StartDate,
	    d.HVCaseFK
		FROM Deleted d
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 6/20/18
-- Description:	This trigger writes edits to the Deleted table
-- with the delete flag set to false as per Chris's advice
-- =============================================
CREATE TRIGGER [dbo].[TR_GoalPlanEdited]
ON [dbo].[GoalPlan]
AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Update the edit date
	UPDATE dbo.GoalPlan Set GoalPlanEditDate = GETDATE() 
	FROM dbo.GoalPlan gp 
	INNER JOIN Inserted i ON i.GoalPlanPK = gp.GoalPlanPK

    -- Insert the edit into the deleted table
	INSERT INTO dbo.GoalPlanDeleted
	(
	    GoalPlanPK,
	    AnticipatedAchievementDate,
		Deleted,
	    GoalArea,
	    GoalCreationDiscussion,
		GoalName,
	    GoalPertainsTo,
		GoalPertainsToSpecify,
	    GoalPlanActive,
	    GoalPlanCreateDate,
	    GoalPlanCreator,
	    GoalPlanEditDate,
	    GoalPlanEditor,
	    GoalProblemSolvingAndPlan,
	    GoalStatement,
		GoalStatus,
		GoalStatusDate,
		IsConsentSigned,
		IsTransitionPlan,
	    NextStep,
	    ProtectiveFactors,
		ServicePartners,
	    StartDate,
	    HVCaseFK
	)
	SELECT 
	    d.GoalPlanPK,
	    d.AnticipatedAchievementDate,
		0, --This was edited, not deleted
	    d.GoalArea,
	    d.GoalCreationDiscussion,
		d.GoalName,
	    d.GoalPertainsTo,
		d.GoalPertainsToSpecify,
	    d.GoalPlanActive,
	    d.GoalPlanCreateDate,
	    d.GoalPlanCreator,
	    d.GoalPlanEditDate,
	    d.GoalPlanEditor,
	    d.GoalProblemSolvingAndPlan,
	    d.GoalStatement,
		d.GoalStatus,
		d.GoalStatusDate,
		d.IsConsentSigned,
		d.IsTransitionPlan,
	    d.NextStep,
	    d.ProtectiveFactors,
		d.ServicePartners,
	    d.StartDate,
	    d.HVCaseFK
		FROM dbo.GoalPlan gp
		INNER JOIN Deleted d ON d.GoalPlanPK = gp.GoalPlanPK
END
GO
ALTER TABLE [dbo].[GoalPlan] ADD CONSTRAINT [PK_GroupPlan] PRIMARY KEY CLUSTERED  ([GoalPlanPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalPlan] ADD CONSTRAINT [FK_GoalPlan_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
