SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnWorkersOnLeave] (@PointInTime datetime, @ProgramFK int)
   RETURNS @WorkersOnLeave TABLE (WorkerProgramFK INT, WorkerFK INT)
AS

Begin
INSERT INTO @WorkersOnLeave
select WorkerProgramFK, WorkerFK 
from dbo.WorkerLeave wl
where wl.ProgramFK = isnull(@ProgramFK, wl.ProgramFK)
and @PointInTime between wl.LeaveStartDate and wl.LeaveEndDate
 return 
end

GO
