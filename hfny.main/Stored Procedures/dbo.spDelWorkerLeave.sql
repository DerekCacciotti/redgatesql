SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelWorkerLeave](@WorkerLeavePK int)

AS


DELETE 
FROM WorkerLeave
WHERE WorkerLeavePK = @WorkerLeavePK
GO
