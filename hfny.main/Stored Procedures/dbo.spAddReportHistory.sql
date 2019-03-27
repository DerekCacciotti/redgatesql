SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddReportHistory](@ProgramFK int=NULL,
@ReportCategory varchar(50)=NULL,
@ReportFK int=NULL,
@ReportName char(100)=NULL,
@ReportType char(20)=NULL,
@TimeRun datetime=NULL,
@ReportFK_old int=NULL,
@UserName varchar(50)=NULL)
AS
INSERT INTO ReportHistory(
ProgramFK,
ReportCategory,
ReportFK,
ReportName,
ReportType,
TimeRun,
ReportFK_old,
UserName
)
VALUES(
@ProgramFK,
@ReportCategory,
@ReportFK,
@ReportName,
@ReportType,
@TimeRun,
@ReportFK_old,
@UserName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
