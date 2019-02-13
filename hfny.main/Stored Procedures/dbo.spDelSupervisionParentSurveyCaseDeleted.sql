SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionParentSurveyCaseDeleted](@SupervisionParentSurveyCaseDeletedPK int)

AS


DELETE 
FROM SupervisionParentSurveyCaseDeleted
WHERE SupervisionParentSurveyCaseDeletedPK = @SupervisionParentSurveyCaseDeletedPK
GO
