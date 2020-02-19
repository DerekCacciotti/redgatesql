SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC	[dbo].[spGetContractManagers] AS

SELECT * FROM listContractManager lcm ORDER BY lcm.listContractManagerPK
GO
