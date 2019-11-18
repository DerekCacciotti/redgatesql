SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetAllActiveWorkersNotInProgram](@ProgramFK INT, @PointInTime DATETIME)

as
BEGIN
set nocount on

select * from dbo.Worker where workerpk IN
(
	select distinct wp.workerfk from dbo.WorkerProgram wp
	LEFT JOIN dbo.fnWorkersOnLeave(@PointInTime, null)  wol ON wol.WorkerProgramFK = wp.WorkerProgramPK
    where wp.TerminationDate is null and wp.ProgramFK <> @ProgramFK
	AND wol.WorkerProgramFK IS NULL --if its not null then they were on leave at the time
)
order by LastName, FirstName
END	
GO
