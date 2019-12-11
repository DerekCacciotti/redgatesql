CREATE TABLE [dbo].[codeReportAccess]
(
[codeReportAccessPK] [int] NOT NULL IDENTITY(1, 1),
[AllowedAccess] [bit] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_codeReportAccess_CreateDate] DEFAULT (getdate()),
[Creator] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EditDate] [datetime] NULL,
[Editor] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportFK] [int] NOT NULL,
[StateFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/11/2019
-- Description:	This trigger updates the edit date in the table
-- =============================================
CREATE TRIGGER [dbo].[TR_codeReportAccessEditDate] ON [dbo].[codeReportAccess]
FOR UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Update the edit date
    UPDATE dbo.codeReportAccess SET EditDate = GETDATE()
	FROM dbo.codeReportAccess cra INNER JOIN Inserted i ON i.codeReportAccessPK = cra.codeReportAccessPK

END
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [PK_codeReportAccess] PRIMARY KEY CLUSTERED  ([codeReportAccessPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [FK_codeReportAccess_codeReportCatalog] FOREIGN KEY ([ReportFK]) REFERENCES [dbo].[codeReportCatalog] ([codeReportCatalogPK])
GO
ALTER TABLE [dbo].[codeReportAccess] ADD CONSTRAINT [FK_codeReportAccess_State] FOREIGN KEY ([StateFK]) REFERENCES [dbo].[State] ([StatePK])
GO
