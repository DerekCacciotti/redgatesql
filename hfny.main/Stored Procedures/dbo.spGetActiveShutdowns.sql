SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetActiveShutdowns] @date DATETIME AS

SELECT * FROM PublishShutdown ps WHERE @date BETWEEN ps.PublishShutdownStart AND ps.PublishShutdownEnd
GO
