SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetPublishShutdownsforDate] @date VARCHAR(max) AS

SELECT ps.PublishShutdownPK FROM PublishShutdown ps WHERE ps.PublishShutdownStartDate = @date
GO
