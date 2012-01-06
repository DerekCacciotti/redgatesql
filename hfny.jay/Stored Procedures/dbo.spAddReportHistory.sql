
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddReportHistory](@ProgramFK int=NULL,
@ReportCategory char(2)=NULL,
@ReportName char(100)=NULL,
@ReportType char(2)=NULL,
@TimeRun datetime=NULL,
@UserFK char(10)=NULL)
AS
INSERT INTO ReportHistory(
ProgramFK,
ReportCategory,
ReportName,
ReportType,
TimeRun,
UserFK
)
VALUES(
@ProgramFK,
@ReportCategory,
@ReportName,
@ReportType,
@TimeRun,
@UserFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
