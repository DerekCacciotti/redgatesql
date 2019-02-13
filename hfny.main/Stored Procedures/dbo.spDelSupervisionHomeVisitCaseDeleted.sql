SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionHomeVisitCaseDeleted](@SupervisionHomeVisitCaseDeletedPK int)

AS


DELETE 
FROM SupervisionHomeVisitCaseDeleted
WHERE SupervisionHomeVisitCaseDeletedPK = @SupervisionHomeVisitCaseDeletedPK
GO
