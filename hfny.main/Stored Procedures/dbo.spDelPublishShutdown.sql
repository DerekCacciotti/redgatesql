SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPublishShutdown](@PublishShutdownPK int)

AS


DELETE 
FROM PublishShutdown
WHERE PublishShutdownPK = @PublishShutdownPK
GO
