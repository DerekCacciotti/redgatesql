SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionHomeVisitCaseDeletedbyPK]

(@SupervisionHomeVisitCaseDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionHomeVisitCaseDeleted
WHERE SupervisionHomeVisitCaseDeletedPK = @SupervisionHomeVisitCaseDeletedPK
GO
