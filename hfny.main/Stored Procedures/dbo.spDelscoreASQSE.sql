SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelscoreASQSE](@scoreASQSEPK int)

AS


DELETE 
FROM scoreASQSE
WHERE scoreASQSEPK = @scoreASQSEPK
GO
