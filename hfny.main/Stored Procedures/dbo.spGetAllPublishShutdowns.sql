SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAllPublishShutdowns] AS
SELECT * FROM PublishShutdown ps ORDER BY ps.PublishShutDownStart DESC
GO
