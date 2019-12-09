SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeReportAccess](@codeReportAccessPK int=NULL,
@StartDate datetime=NULL,
@EndDate datetime=NULL,
@ReportFK int=NULL,
@StateFK int=NULL)
AS
UPDATE codeReportAccess
SET 
StartDate = @StartDate, 
EndDate = @EndDate, 
ReportFK = @ReportFK, 
StateFK = @StateFK
WHERE codeReportAccessPK = @codeReportAccessPK
GO
