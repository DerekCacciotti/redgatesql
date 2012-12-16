
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: June 26, 2012
-- Description:	Return all workers by date by program
-- Edit date: 12/15/2012
-- Edited by: Chris Papas
-- Edit Reason: Needed = next to @thedate because workers who started on the date aren't appearing
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
INNER JOIN WorkerProgram wp ON w.WorkerPK=wp.WorkerFK
WHERE (TerminationDate IS NULL OR TerminationDate >@thedate)
AND ProgramFK=@progfk
AND (wp.FAWStartDate <=@thedate OR wp.FSWStartDate<=@thedate OR wp.SupervisorStartDate<=@thedate OR wp.ProgramManagerStartDate<=@thedate)

END



GO
