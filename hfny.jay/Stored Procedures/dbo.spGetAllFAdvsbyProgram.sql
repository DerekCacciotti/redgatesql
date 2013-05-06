
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: July 17, 2012
-- Edited by: Chris Papas
-- Edite Date: May 6, 2013
-- Description:	Return Father Advocate workers, who are working at a specified date from a specified program
-- Edit Reason: As per John, we are to return all Father Advocates who were either working at the
--              time the form was created OR are currently working
-- =============================================

CREATE procedure [dbo].[spGetAllFAdvsbyProgram]
    @ProgramFK int      = null,
    @EventDate datetime = null
as
begin
	set nocount on;

	--exec spGetAllWorkersbyProgram @ProgramFK, @EventDate, 'FAdv'

	select WorkerPK,FirstName,LastName
		from Worker w
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK
		AND (TerminationDate IS NULL OR FatherAdvocateStartDate < @EventDate)
		AND FatherAdvocate=1
		order by LastName
end
GO
