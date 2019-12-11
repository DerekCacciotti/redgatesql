SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeReportAccess](@codeReportAccessPK int=NULL,
@AllowedAccess bit=NULL,
@Editor varchar(256)=NULL,
@ReportFK int=NULL,
@StateFK int=NULL)
AS
UPDATE codeReportAccess
SET 
AllowedAccess = @AllowedAccess, 
Editor = @Editor, 
ReportFK = @ReportFK, 
StateFK = @StateFK
WHERE codeReportAccessPK = @codeReportAccessPK
GO
