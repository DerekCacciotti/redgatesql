CREATE TABLE [dbo].[codeReportCatalog]
(
[codeReportCatalogPK] [int] NOT NULL IDENTITY(1, 1),
[CriteriaOptions] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Defaults] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Keywords] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldReportFK] [int] NULL,
[OldReportID] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportCategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDescription] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/11/2019
-- Description:	This trigger removes the related rows in the database
-- =============================================
CREATE TRIGGER [dbo].[TR_DeleteCodeReportCatalog] ON [dbo].[codeReportCatalog]
INSTEAD OF DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Delete any report access rows for the report
	DELETE cra FROM dbo.codeReportAccess cra 
		INNER JOIN Deleted d ON d.codeReportCatalogPK = cra.ReportFK

	--Delete the report catalog row
	DELETE crc FROM dbo.codeReportCatalog crc
		INNER JOIN Deleted d ON d.codeReportCatalogPK = crc.codeReportCatalogPK

END
GO
ALTER TABLE [dbo].[codeReportCatalog] ADD CONSTRAINT [PK_codeReportCatalog] PRIMARY KEY CLUSTERED  ([codeReportCatalogPK]) ON [PRIMARY]
GO
