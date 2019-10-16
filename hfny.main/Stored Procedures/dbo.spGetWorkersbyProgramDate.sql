SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: June 26, 2012
-- Description:	Return all workers by date by program
-- Edit date: 03/19/2013
-- Edited by: Chris Papas
-- Edit Reason: Needed = next to @thedate because workers who started on the date aren't appearing

-- Edit date: 10/10/2019
-- Edited by: Bill O'Brien
-- Edit Reason: With Worker Redesign, need to account for role end dates and worker leave periods.
-- =============================================

CREATE PROCEDURE [dbo].[spGetWorkersbyProgramDate]
@progFK int = NULL,
@theDate datetime = NULL

AS
BEGIN
SET NOCOUNT ON;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

SELECT WorkerPK, rtrim(FirstName) + ' ' + rtrim(LastName) AS WorkerName FROM Worker w
INNER JOIN WorkerProgram wp ON w.WorkerPK = wp.WorkerFK
LEFT JOIN fnWorkersOnLeave(@theDate, @progFK) wol on wol.WorkerFK = WorkerPK
WHERE (TerminationDate IS NULL OR TerminationDate > @theDate)
AND ProgramFK = @progfk
AND wol.WorkerFK is null
AND 
(
	(wp.FAWStartDate <= dateadd(mm, 36, @theDate) AND (wp.FAWEndDate is null or wp.FAWEndDate > @theDate))
	OR 
	(wp.FSWStartDate<= dateadd(mm, 36, @theDate) AND (wp.FSWEndDate is null or wp.FSWEndDate > @theDate))
	OR 
	(wp.SupervisorStartDate<= dateadd(mm, 36, @theDate) AND (wp.SupervisorEndDate is null or wp.SupervisorEndDate > @theDate))
	OR 
	(wp.ProgramManagerStartDate<= dateadd(mm, 36, @theDate) AND (wp.ProgramManagerEndDate is null or wp.ProgramManagerEndDate > @theDate))
)
END




GO
