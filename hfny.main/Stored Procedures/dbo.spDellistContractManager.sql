SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistContractManager](@listContractManagerPK int)

AS


DELETE 
FROM listContractManager
WHERE listContractManagerPK = @listContractManagerPK
GO
