SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeReportAccessbyPK]

(@codeReportAccessPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeReportAccess
WHERE codeReportAccessPK = @codeReportAccessPK
GO
