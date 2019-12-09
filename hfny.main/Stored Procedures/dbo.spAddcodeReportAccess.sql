SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeReportAccess](@StartDate datetime=NULL,
@EndDate datetime=NULL,
@ReportFK int=NULL,
@StateFK int=NULL)
AS
INSERT INTO codeReportAccess(
StartDate,
EndDate,
ReportFK,
StateFK
)
VALUES(
@StartDate,
@EndDate,
@ReportFK,
@StateFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
