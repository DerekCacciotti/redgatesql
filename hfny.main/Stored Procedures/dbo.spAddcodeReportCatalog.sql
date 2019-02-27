SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeReportCatalog](@CriteriaOptions varchar(25)=NULL,
@Defaults varchar(20)=NULL,
@Keywords varchar(max)=NULL,
@OldReportFK int=NULL,
@OldReportID nchar(5)=NULL,
@ReportCategory varchar(20)=NULL,
@ReportClass varchar(50)=NULL,
@ReportDescription varchar(1000)=NULL,
@ReportName varchar(100)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeReportCatalogPK
FROM codeReportCatalog lastRow
WHERE 
@CriteriaOptions = lastRow.CriteriaOptions AND
@Defaults = lastRow.Defaults AND
@Keywords = lastRow.Keywords AND
@OldReportFK = lastRow.OldReportFK AND
@OldReportID = lastRow.OldReportID AND
@ReportCategory = lastRow.ReportCategory AND
@ReportClass = lastRow.ReportClass AND
@ReportDescription = lastRow.ReportDescription AND
@ReportName = lastRow.ReportName
ORDER BY codeReportCatalogPK DESC) 
BEGIN
INSERT INTO codeReportCatalog(
CriteriaOptions,
Defaults,
Keywords,
OldReportFK,
OldReportID,
ReportCategory,
ReportClass,
ReportDescription,
ReportName
)
VALUES(
@CriteriaOptions,
@Defaults,
@Keywords,
@OldReportFK,
@OldReportID,
@ReportCategory,
@ReportClass,
@ReportDescription,
@ReportName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
