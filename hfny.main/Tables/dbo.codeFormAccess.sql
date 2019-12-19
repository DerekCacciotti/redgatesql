CREATE TABLE [dbo].[codeFormAccess]
(
[codeFormAccessPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedAccess] [bit] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_codeFormAccess_CreateDate] DEFAULT (getdate()),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[codeFormFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/13/2019
-- Description:	This trigger updates the edit date in the table
-- =============================================
CREATE TRIGGER [dbo].[TR_codeFormAccessEditDate] ON [dbo].[codeFormAccess]
FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Update the edit date
    UPDATE dbo.codeFormAccess SET EditDate = GETDATE()
	FROM dbo.codeFormAccess cfa INNER JOIN Inserted i ON i.codeFormAccessPK = cfa.codeFormAccessPK

END
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [PK_codeFormAccess] PRIMARY KEY CLUSTERED  ([codeFormAccessPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [FK_codeFormAccess_codeForm] FOREIGN KEY ([codeFormFK]) REFERENCES [dbo].[codeForm] ([codeFormPK])
GO
ALTER TABLE [dbo].[codeFormAccess] ADD CONSTRAINT [FK_codeFormAccess_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO
