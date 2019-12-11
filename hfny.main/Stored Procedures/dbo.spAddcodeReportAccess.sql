SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeReportAccess](@AllowedAccess bit=NULL,
@Creator varchar(256)=NULL,
@ReportFK int=NULL,
@StateFK int=NULL)
AS
INSERT INTO codeReportAccess(
AllowedAccess,
Creator,
ReportFK,
StateFK
)
VALUES(
@AllowedAccess,
@Creator,
@ReportFK,
@StateFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
