SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeReportCatalog](@ReportName varchar(100)=NULL,
@ReportCategory varchar(20)=NULL,
@ReportDescription varchar(1000)=NULL,
@ReportClass varchar(50)=NULL,
@CriteriaOptions char(7)=NULL,
@Defaults varchar(1000)=NULL)
AS
INSERT INTO codeReportCatalog(
ReportName,
ReportCategory,
ReportDescription,
ReportClass,
CriteriaOptions,
Defaults
)
VALUES(
@ReportName,
@ReportCategory,
@ReportDescription,
@ReportClass,
@CriteriaOptions,
@Defaults
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
