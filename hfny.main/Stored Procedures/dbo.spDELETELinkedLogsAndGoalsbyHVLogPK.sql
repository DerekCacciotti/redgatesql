SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDELETELinkedLogsAndGoalsbyHVLogPK](@HVLogPK int)

AS


DELETE 
FROM lnkHVLogGoalPlan
WHERE HVLogFK = @HVLogPK
GO