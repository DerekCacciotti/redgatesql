SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeReportCatalog](@codeReportCatalogPK int=NULL,
@ReportName varchar(100)=NULL,
@ReportCategory varchar(20)=NULL,
@ReportDescription varchar(1000)=NULL,
@ReportClass varchar(50)=NULL,
@CriteriaOptions char(7)=NULL,
@Defaults varchar(1000)=NULL)
AS
UPDATE codeReportCatalog
SET 
ReportName = @ReportName, 
ReportCategory = @ReportCategory, 
ReportDescription = @ReportDescription, 
ReportClass = @ReportClass, 
CriteriaOptions = @CriteriaOptions, 
Defaults = @Defaults
WHERE codeReportCatalogPK = @codeReportCatalogPK
GO
