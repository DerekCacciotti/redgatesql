SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistContractManagerbyPK]

(@listContractManagerPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listContractManager
WHERE listContractManagerPK = @listContractManagerPK
GO
