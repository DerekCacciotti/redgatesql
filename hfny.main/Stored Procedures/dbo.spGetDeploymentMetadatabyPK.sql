SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetDeploymentMetadatabyPK]

(@DeploymentMetadataPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM DeploymentMetadata
WHERE DeploymentMetadataPK = @DeploymentMetadataPK
GO
