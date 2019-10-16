SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spGetAllWorkerProgrambyWorkerFK](@WorkerFK int)  

AS

BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM [dbo].[WorkerProgram]
	WHERE WorkerFK = @WorkerFK 
END
GO
