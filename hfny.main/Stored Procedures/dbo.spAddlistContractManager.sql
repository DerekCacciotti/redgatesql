SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistContractManager](@ContractManagerName varchar(max)=NULL,
@listContractManagerCreator varchar(max)=NULL)
AS
INSERT INTO listContractManager(
ContractManagerName,
listContractManagerCreator
)
VALUES(
@ContractManagerName,
@listContractManagerCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
