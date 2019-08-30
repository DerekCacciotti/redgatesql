SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spGetWorkerLeaveByWorkerAndProgram](@WorkerFK int,@ProgramFK int)  

AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [dbo].[WorkerLeave]
	WHERE WorkerFK = @WorkerFK 
	AND ProgramFK = @ProgramFK

END
GO
