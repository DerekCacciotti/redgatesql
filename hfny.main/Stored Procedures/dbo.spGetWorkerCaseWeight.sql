SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jayrobot>
-- Create date: <Sep 19, 2018>
-- Description:	Gets the passed workers' case weight for the passed program
-- exec spGetWorkerCaseWeight @WorkerFK = 2147, @ProgramFK = 17
-- exec spGetWorkerCaseWeight @WorkerFK = 943, @ProgramFK = 17
-- =============================================
CREATE procedure [dbo].[spGetWorkerCaseWeight]
	(@WorkerFK int, 
		@ProgramFK int
	)	
as

select sum(cl.CaseWeight) as WorkerCaseWeight
from CaseProgram cp
inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
where cp.CurrentFSWFK = @WorkerFK
GO
