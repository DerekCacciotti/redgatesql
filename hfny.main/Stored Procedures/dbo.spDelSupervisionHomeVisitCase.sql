SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionHomeVisitCase](@SupervisionHomeVisitCasePK int)

AS


DELETE 
FROM SupervisionHomeVisitCase
WHERE SupervisionHomeVisitCasePK = @SupervisionHomeVisitCasePK
GO
