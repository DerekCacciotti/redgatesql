SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelscoreASQ](@scoreASQPK int)

AS


DELETE 
FROM scoreASQ
WHERE scoreASQPK = @scoreASQPK
GO
