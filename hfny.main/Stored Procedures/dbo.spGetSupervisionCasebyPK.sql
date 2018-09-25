SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionCasebyPK]

(@SupervisionCasePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionCase
WHERE SupervisionCasePK = @SupervisionCasePK
GO
