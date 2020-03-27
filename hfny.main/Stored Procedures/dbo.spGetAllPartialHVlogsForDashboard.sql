SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetAllPartialHVlogsForDashboard] @ProgramFK INT, @WorkerFK INT AS
DECLARE @DaystoLoad int = 30
SELECT hl.HVLogPK, cp.PC1ID, cp.CurrentFSWFK, hl.VisitStartTime, CONCAT(LTRIM(RTRIM(w.FirstName)), ' ', LTRIM(RTRIM(w.LastName))) AS WorkerName,
CONCAT(LTRIM(RTRIM(wsup.FirstName)), ' ', LTRIM(RTRIM(wsup.LastName))) AS SupervisorName FROM HVLog hl 
INNER JOIN CaseProgram cp ON cp.ProgramFK = hl.ProgramFK AND hl.HVCaseFK = cp.HVCaseFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = hl.FSWFK AND wp.ProgramFK = @ProgramFK
INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
INNER JOIN Worker wsup ON wsup.WorkerPK = wp.SupervisorFK
WHERE hl.ProgramFK = @ProgramFK 
		and hl.FSWFK = @WorkerFK 
		and hl.FormComplete = 0 
		and cp.DischargeDate IS null 
		and hl.VisitStartTime > DATEADD(day, -@DaystoLoad, getdate())

--SELECT hl.HVLogPK, cp.PC1ID, cp.CurrentFSWFK, hl.VisitStartTime, CONCAT(LTRIM(RTRIM(w.FirstName)), ' ', LTRIM(RTRIM(w.LastName))) AS WorkerName,
--CONCAT(LTRIM(RTRIM(wsup.FirstName)), ' ', LTRIM(RTRIM(wsup.LastName))) AS SupervisorName
--FROM FormReview fr 
--INNER JOIN HVLog hl ON hl.HVCaseFK = fr.HVCaseFK AND hl.HVLogPK = fr.FormFK
--inner join CaseProgram cp on cp.HVCaseFK = fr.HVCaseFK
--									and cp.ProgramFK = fr.ProgramFK AND cp.CurrentFSWFK = @WorkerFK
--									INNER JOIN WorkerProgram wp ON wp.WorkerFK = @WorkerFK AND wp.ProgramFK = @ProgramFK
--									INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK	
--									INNER JOIN Worker wsup ON wsup.WorkerPK = wp.SupervisorFK
--									where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)
								
--				and fr.FormType = 'VL'
--				and FormComplete = 0
				
GO
