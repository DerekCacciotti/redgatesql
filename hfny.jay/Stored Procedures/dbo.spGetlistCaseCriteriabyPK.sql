SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistCaseCriteriabyPK]

(@listCaseCriteriaPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listCaseCriteria
WHERE listCaseCriteriaPK = @listCaseCriteriaPK
GO
