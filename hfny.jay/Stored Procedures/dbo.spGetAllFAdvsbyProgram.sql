SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: July 17, 2012
-- Description:	Return Father Advocate workers, who are working at a specified date from a specified program
-- =============================================

CREATE procedure [dbo].[spGetAllFAdvsbyProgram]
    @ProgramFK int      = null,
    @EventDate datetime = null
as
begin
	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramFK, @EventDate, 'FAdv'

	--select WorkerPK
	--	  ,FirstName
	--	  ,LastName
	--	from Worker w
	--		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
	--	where programfk = @ProgramFK
	--		 and
	--		 @EventDate between FatherAdvocateStartDate and isnull(FatherAdvocateEndDate,dateadd(dd,270,datediff(dd,0,getdate())))
	--	order by LastName
end
GO
