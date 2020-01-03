SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAllSupervisionsforSupervisionReview] @ProgramFK INT AS 
--DECLARE @ProgramFK INT = 1 

SELECT FORMAT(s.SupervisionDate,'MM/dd/yy')  AS SupervisionDate, s.SupervisionStartTime, s.SupervisionSessionType, 
LTRIM(RTRIM(w.LastName)) + ', ' + LTRIM(RTRIM(w.FirstName)) AS WorkerName,
LTRIM(RTRIM(super.LastName)) + ', ' + LTRIM(RTRIM(w.FirstName)) AS SupervisorName,
 CASE WHEN s.SupervisionSessionType = '1' THEN 'Scheduled Session' WHEN s.SupervisionSessionType = '2' THEN 'Pre-Supervision Planning' 
		WHEN s.SupervisionSessionType = '3' THEN 'Group Session' ELSE 'Missed Session' END as SupervisionType,s.SupervisionPK
 FROM Supervision s 
INNER JOIN Worker w ON w.WorkerPK = s.WorkerFK
INNER JOIN Worker super ON super.WorkerPK = s.SupervisorFK
WHERE s.ProgramFK = @ProgramFK AND s.FormComplete = 0
GO
