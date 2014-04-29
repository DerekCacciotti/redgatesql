SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetOpenCaseCountByProgramWorkerFK](@WorkerFK int,@ProgramFK int)  

AS

BEGIN
	SET NOCOUNT ON;

	SELECT count(*) [n]
	FROM dbo.CaseProgram
	WHERE (CurrentFAWFK = @WorkerFK OR CurrentFSWFK = @WorkerFK) AND 
	DischargeDate IS NULL AND ProgramFK = @ProgramFK

END

GO
