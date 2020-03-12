SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistContractManager](@listContractManagerPK int=NULL,
@ContractManagerName varchar(max)=NULL,
@listContractManagerEditor varchar(max)=NULL)
AS
UPDATE listContractManager
SET 
ContractManagerName = @ContractManagerName, 
listContractManagerEditor = @listContractManagerEditor
WHERE listContractManagerPK = @listContractManagerPK
GO
