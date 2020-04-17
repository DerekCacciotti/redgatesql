SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetActiveShutdowns] @date DATETIME AS

SELECT * FROM PublishShutdown ps WHERE ps.PublishShutdownStartDate BETWEEN @date AND ps.PublishShutdownEndDate
GO
