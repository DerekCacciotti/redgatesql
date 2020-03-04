CREATE TABLE [dbo].[GoalPlanHVLogStatus]
(
[GoalPlanHVLogStatusPK] [int] NOT NULL IDENTITY(1, 1),
[Challenges] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DevelopmentSinceLastVisit] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FollowUpAndSupport] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanHVLogStatusCreateDate] [datetime] NOT NULL CONSTRAINT [DF_GoalPlanHVLogStatus_GoalStepCreateDate] DEFAULT (getdate()),
[GoalPlanHVLogStatusCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GoalPlanHVLogStatusEditDate] [datetime] NULL,
[GoalPlanHVLogStatusEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GoalPlanFK] [int] NOT NULL,
[HVLogFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 05/31/18
-- Description:	This trigger records the deletion of a goal plan HVLog status row
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_GoalPlanHVLogStatus]
   ON  [dbo].[GoalPlanHVLogStatus]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	INSERT INTO dbo.GoalPlanHVLogStatusDeleted
	(
	    GoalPlanHVLogStatusPK,
		Deleted,
	    DevelopmentSinceLastVisit,
	    Challenges,
	    FollowUpAndSupport,
	    GoalPlanHVLogStatusCreateDate,
	    GoalPlanHVLogStatusCreator,
	    GoalPlanHVLogStatusEditDate,
	    GoalPlanHVLogStatusEditor,
	    GoalPlanFK,
	    HVLogFK
	)
	SELECT GoalPlanHVLogStatusPK,
		1, -- This was a delete
	    d.DevelopmentSinceLastVisit,
	    d.Challenges,
	    d.FollowUpAndSupport,
	    d.GoalPlanHVLogStatusCreateDate,
	    d.GoalPlanHVLogStatusCreator,
	    d.GoalPlanHVLogStatusEditDate,
	    d.GoalPlanHVLogStatusEditor,
	    d.GoalPlanFK,
	    d.HVLogFK
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
CREATE TRIGGER [dbo].[TR_GoalPlanHVLogStatusEdited]
ON [dbo].[GoalPlanHVLogStatus]
AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.GoalPlanHVLogStatus Set GoalPlanHVLogStatusEditDate = GETDATE() 
	FROM dbo.GoalPlanHVLogStatus gphls 
	INNER JOIN Inserted i ON i.GoalPlanHVLogStatusPK = gphls.GoalPlanHVLogStatusPK

    -- Insert the edit into the deleted table
	INSERT INTO dbo.GoalPlanHVLogStatusDeleted
	(
	    GoalPlanHVLogStatusPK,
		Deleted,
	    DevelopmentSinceLastVisit,
	    Challenges,
	    FollowUpAndSupport,
	    GoalPlanHVLogStatusCreateDate,
	    GoalPlanHVLogStatusCreator,
	    GoalPlanHVLogStatusEditDate,
	    GoalPlanHVLogStatusEditor,
	    GoalPlanFK,
	    HVLogFK
	)
	SELECT 
		d.GoalPlanHVLogStatusPK,
		0, --This was an edit, not a deletion
	    d.DevelopmentSinceLastVisit,
	    d.Challenges,
	    d.FollowUpAndSupport,
	    d.GoalPlanHVLogStatusCreateDate,
	    d.GoalPlanHVLogStatusCreator,
	    d.GoalPlanHVLogStatusEditDate,
	    d.GoalPlanHVLogStatusEditor,
	    d.GoalPlanFK,
	    d.HVLogFK
		FROM dbo.GoalPlanHVLogStatus gphls
		INNER JOIN Deleted d ON d.GoalPlanHVLogStatusPK = gphls.GoalPlanHVLogStatusPK
END
GO
ALTER TABLE [dbo].[GoalPlanHVLogStatus] ADD CONSTRAINT [PK_GoalPlanHVLogStatus] PRIMARY KEY CLUSTERED  ([GoalPlanHVLogStatusPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GoalPlanHVLogStatus] ADD CONSTRAINT [FK_GoalPlanHVLogStatus_GoalPlan] FOREIGN KEY ([GoalPlanFK]) REFERENCES [dbo].[GoalPlan] ([GoalPlanPK])
GO
ALTER TABLE [dbo].[GoalPlanHVLogStatus] ADD CONSTRAINT [FK_GoalPlanHVLogStatus_HVLog] FOREIGN KEY ([HVLogFK]) REFERENCES [dbo].[HVLog] ([HVLogPK])
GO
