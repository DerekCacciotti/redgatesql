SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--[spGetWorkersbyProgramPK] 1

CREATE PROCEDURE [dbo].[spGetWorkersbyProgramPK]
(@ProgramPK int)
AS
SET NOCOUNT ON;

SELECT w.LastName, w.FirstName, w.WorkerPK  FROM Worker w 
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK
WHERE w.LoginCreated = 0 AND  wp.ProgramFK = @ProgramPK and w.FirstName NOT IN ('Historical','Rensselaer','In State','Out of State') AND wp.TerminationDate IS NULL 





GO
