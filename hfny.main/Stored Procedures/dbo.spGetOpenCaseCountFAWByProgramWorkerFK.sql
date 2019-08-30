SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetOpenCaseCountFAWByProgramWorkerFK](@WorkerFK int,@ProgramFK int)  

AS

BEGIN
	SET NOCOUNT ON;

--DECLARE @WorkerFK INT = 466;
--DECLARE @ProgramFK INT	= 8;
	SELECT count(*) [n]
	FROM dbo.CaseProgram
	WHERE CurrentFSWFK is null and currentfawfk = @WorkerFK AND 
	DischargeDate IS NULL AND ProgramFK = @ProgramFK

END
GO
