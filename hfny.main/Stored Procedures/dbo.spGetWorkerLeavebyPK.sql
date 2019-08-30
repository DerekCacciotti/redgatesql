SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetWorkerLeavebyPK]

(@WorkerLeavePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM WorkerLeave
WHERE WorkerLeavePK = @WorkerLeavePK
GO
