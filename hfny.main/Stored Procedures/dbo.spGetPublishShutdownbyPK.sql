SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPublishShutdownbyPK]

(@PublishShutdownPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM PublishShutdown
WHERE PublishShutdownPK = @PublishShutdownPK
GO
