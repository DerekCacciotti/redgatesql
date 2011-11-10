SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistCaseCriteria](@listCaseCriteriaPK int)

AS


DELETE 
FROM listCaseCriteria
WHERE listCaseCriteriaPK = @listCaseCriteriaPK
GO
