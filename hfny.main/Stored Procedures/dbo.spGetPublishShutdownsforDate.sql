SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetPublishShutdownsforDate] @date DATETIME as

SELECT ps.PublishShutdownPK FROM PublishShutdown ps WHERE  CONVERT(DATE, ps.PublishShutdownStart) = @date
ORDER BY ps.PublishShutdownStart DESC 
GO
