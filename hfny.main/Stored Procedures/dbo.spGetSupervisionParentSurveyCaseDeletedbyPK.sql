SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionParentSurveyCaseDeletedbyPK]

(@SupervisionParentSurveyCaseDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionParentSurveyCaseDeleted
WHERE SupervisionParentSurveyCaseDeletedPK = @SupervisionParentSurveyCaseDeletedPK
GO
