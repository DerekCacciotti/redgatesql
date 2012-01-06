
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditReportHistory](@ReportHistoryPK int=NULL,
@ProgramFK int=NULL,
@ReportCategory char(2)=NULL,
@ReportName char(100)=NULL,
@ReportType char(2)=NULL,
@TimeRun datetime=NULL,
@UserFK char(10)=NULL)
AS
UPDATE ReportHistory
SET 
ProgramFK = @ProgramFK, 
ReportCategory = @ReportCategory, 
ReportName = @ReportName, 
ReportType = @ReportType, 
TimeRun = @TimeRun, 
UserFK = @UserFK
WHERE ReportHistoryPK = @ReportHistoryPK
GO
