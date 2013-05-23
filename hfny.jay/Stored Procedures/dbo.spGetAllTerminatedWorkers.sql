SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetAllTerminatedWorkers]
  @ProgramFK  int = NULL
as

set nocount on
SELECT c.ProgramName
, a.LastName, a.FirstName
, convert(varchar(12), b.TerminationDate, 101) [TerminationDate]
, CASE WHEN b.FAW = 1 THEN 'FAW ' ELSE '' END +
CASE WHEN b.FAW = 1 THEN 'FAW ' ELSE '' END +
CASE WHEN b.FSW = 1 THEN 'FSW ' ELSE '' END +
CASE WHEN b.FatherAdvocate = 1 THEN 'FAdv ' ELSE '' END +
CASE WHEN b.Supervisor = 1 THEN 'SUP ' ELSE '' END +
CASE WHEN b.ProgramManager= 1 THEN 'PM ' ELSE '' END [Roles]
, b.ProgramFK
, a.WorkerPK
, b.WorkerProgramPK
FROM Worker AS a
JOIN WorkerProgram AS b ON a.WorkerPK = b.WorkerFK
JOIN HVProgram AS c ON c.HVProgramPK = b.ProgramFK
WHERE b.TerminationDate IS NOT NULL
AND ProgramFK = isnull(@ProgramFK, ProgramFK)
ORDER BY c.ProgramName, a.LastName, a.FirstName






GO
