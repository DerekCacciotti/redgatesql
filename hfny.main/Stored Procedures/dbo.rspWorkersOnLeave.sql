SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[rspWorkersOnLeave] 
( @ProgramFK int, 
	@sDate  datetime,
	@eDate datetime
)
as
begin
	select FirstName + ' ' + LastName as FullName
			, LeaveStartDate
			, LeaveEndDate
	from WorkerLeave wl
	inner join Worker w on wl.WorkerFK = WorkerPK
	where wl.ProgramFK = isnull(@ProgramFK, wl.ProgramFK)
			and (LeaveStartDate between @sDate and @eDate
					or LeaveEndDate between @sDate and @eDate)
end
GO
