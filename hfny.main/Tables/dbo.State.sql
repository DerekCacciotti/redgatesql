CREATE TABLE [dbo].[State]
(
[StatePK] [int] NOT NULL IDENTITY(1, 1),
[Abbreviation] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/19/2019
-- Description:	This trigger removes the related codeReportAccess and codeFormAccess rows in the database
-- =============================================
CREATE TRIGGER [dbo].[TR_DeleteState] ON [dbo].[State]
INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Delete any form access rows for the state
	DELETE cfa FROM dbo.codeFormAccess cfa  
		INNER JOIN Deleted d ON d.StatePK = cfa.StateFK
		
	--Delete any report access rows for the state
	DELETE cra FROM dbo.codeReportAccess cra  
		INNER JOIN Deleted d ON d.StatePK = cra.StateFK

	--Delete the state row
	DELETE s FROM dbo.State s
		INNER JOIN Deleted d ON d.StatePK = s.StatePK

END
GO
ALTER TABLE [dbo].[State] ADD CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED  ([StatePK]) ON [PRIMARY]
GO
