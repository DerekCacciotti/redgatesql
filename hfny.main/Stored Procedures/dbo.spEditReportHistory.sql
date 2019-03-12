SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditReportHistory](@ReportHistoryPK int=NULL,
@ProgramFK int=NULL,
@ReportCategory varchar(50)=NULL,
@ReportFK int=NULL,
@ReportName char(100)=NULL,
@ReportType char(20)=NULL,
@TimeRun datetime=NULL,
@ReportFK_old int=NULL,
@UserName varchar(50)=NULL)
AS
UPDATE ReportHistory
SET 
ProgramFK = @ProgramFK, 
ReportCategory = @ReportCategory, 
ReportFK = @ReportFK, 
ReportName = @ReportName, 
ReportType = @ReportType, 
TimeRun = @TimeRun, 
ReportFK_old = @ReportFK_old, 
UserName = @UserName
WHERE ReportHistoryPK = @ReportHistoryPK
GO
