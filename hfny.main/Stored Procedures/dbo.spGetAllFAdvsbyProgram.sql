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

-- Edit date: 10/10/2019
-- Edited by: Bill O'Brien
-- Edit Reason: With Worker Redesign, need to account for role end dates and worker leave periods.
-- =============================================

CREATE procedure [dbo].[spGetAllFAdvsbyProgram]
    @ProgramFK int      = null,
    @EventDate datetime = null
AS
begin
	set nocount on;

	--exec spGetAllWorkersbyProgram @ProgramFK, @EventDate, 'FAdv'

	select WorkerPK,FirstName,LastName
		from Worker w
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
			left join fnWorkersOnLeave(@EventDate, @ProgramFK) wol on wol.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK
		--AND (TerminationDate IS NULL OR FatherAdvocateStartDate < @EventDate)
		AND	@EventDate between FatherAdvocateStartDate AND isnull(FatherAdvocateEndDate, isnull(TerminationDate,dateadd(dd,1,datediff(dd,0,getdate()))))
		AND wol.WorkerFK is null
		order by LastName
end
GO
