SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionDeleted](@SupervisionDeletedPK int)

AS


DELETE 
FROM SupervisionDeleted
WHERE SupervisionDeletedPK = @SupervisionDeletedPK
GO
