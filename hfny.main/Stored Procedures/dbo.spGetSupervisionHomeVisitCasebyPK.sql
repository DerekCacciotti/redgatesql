SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionHomeVisitCasebyPK]

(@SupervisionHomeVisitCasePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionHomeVisitCase
WHERE SupervisionHomeVisitCasePK = @SupervisionHomeVisitCasePK
GO
