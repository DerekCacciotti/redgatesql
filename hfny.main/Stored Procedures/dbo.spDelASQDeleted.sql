SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelASQDeleted](@ASQDeletedPK int)

AS


DELETE 
FROM ASQDeleted
WHERE ASQDeletedPK = @ASQDeletedPK
GO