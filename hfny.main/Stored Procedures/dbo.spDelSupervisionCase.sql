SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionCase](@SupervisionCasePK int)

AS


DELETE 
FROM SupervisionCase
WHERE SupervisionCasePK = @SupervisionCasePK
GO
