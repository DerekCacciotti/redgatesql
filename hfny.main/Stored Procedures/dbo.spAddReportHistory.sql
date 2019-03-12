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
IF NOT EXISTS (SELECT TOP(1) ReportHistoryPK
FROM ReportHistory lastRow
WHERE 
@ProgramFK = lastRow.ProgramFK AND
@ReportCategory = lastRow.ReportCategory AND
@ReportFK = lastRow.ReportFK AND
@ReportName = lastRow.ReportName AND
@ReportType = lastRow.ReportType AND
@TimeRun = lastRow.TimeRun AND
@ReportFK_old = lastRow.ReportFK_old AND
@UserName = lastRow.UserName
ORDER BY ReportHistoryPK DESC) 
BEGIN
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

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
