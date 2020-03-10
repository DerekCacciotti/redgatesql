SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--DECLARE @ProgramFK INT = 1
--DECLARE @WorkerFK INT = 105
CREATE PROC [dbo].[spGetAllPartialSupervisionsForDashboard] @ProgramFK INT, @WorkerFK INT AS
DECLARE @DaystoLoad int = 30
SELECT hl.HVLogPK, cp.PC1ID, cp.CurrentFSWFK, hl.VisitStartTime, CONCAT(LTRIM(RTRIM(w.FirstName)), ' ', LTRIM(RTRIM(w.LastName))) AS WorkerName,
CONCAT(LTRIM(RTRIM(wsup.FirstName)), ' ', LTRIM(RTRIM(wsup.LastName))) AS SupervisorName
FROM FormReview fr 
INNER JOIN FormReviewOptions fro ON fro.FormType = fr.FormType AND fro.ProgramFK = fr.ProgramFK
INNER JOIN HVLog hl ON hl.HVCaseFK = fr.HVCaseFK AND hl.HVLogPK = fr.FormFK
inner join CaseProgram cp on cp.HVCaseFK = fr.HVCaseFK
									and cp.ProgramFK = fr.ProgramFK AND cp.CurrentFSWFK = @WorkerFK
									INNER JOIN WorkerProgram wp ON wp.WorkerFK = @WorkerFK AND wp.ProgramFK = @ProgramFK
									INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK	
									INNER JOIN Worker wsup ON wsup.WorkerPK = wp.SupervisorFK
									where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)
								
				and fr.FormType = 'VL'
				and FormComplete = 0
				and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
				and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp)
				
GO
