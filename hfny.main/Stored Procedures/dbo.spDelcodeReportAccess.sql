SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeReportAccess](@codeReportAccessPK int)

AS


DELETE 
FROM codeReportAccess
WHERE codeReportAccessPK = @codeReportAccessPK
GO
