SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetActiveShutdowns] @date VARCHAR(max) AS

SELECT * FROM PublishShutdown ps WHERE @date BETWEEN ps.PublishShutDownStartDate AND ps.PublishShutdownEndDate
GO
