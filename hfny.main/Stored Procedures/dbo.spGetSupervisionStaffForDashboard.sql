SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetSupervisionStaffForDashboard] @workerfk INT, @programfk INT as
SELECT w.FirstName, w.LastName, CASE WHEN w.SupervisionScheduledDay = 2 THEN 'Monday'
 WHEN w.SupervisionScheduledDay = 3 THEN 'Tuesday' WHEN w.SupervisionScheduledDay = 4 THEN 'Wednesday' 
 WHEN w.SupervisionScheduledDay = 5 THEN 'Thursday' WHEN w.SupervisionScheduledDay = 6 THEN 'Friday' ELSE 'Monday' END AS SupervisionDay
FROM Worker w INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK WHERE wp.SupervisorFK = @workerfk AND wp.TerminationDate IS NULL
AND wp.ProgramFK = @programfk

-- excludes the passed in worker fk if they happen to be there own supervisor
AND w.WorkerPK != @workerfk

ORDER BY w.FirstName
GO
