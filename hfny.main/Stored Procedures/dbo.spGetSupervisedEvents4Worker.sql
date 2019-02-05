SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--[spGetSupervisedEvents4Worker] 115

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: Oct. 5th, 2011
-- Description:	Return all supervised events for the given worker,
--for use in Supervision and Training
-- spGetSupervisedEvents4Worker 152,1

-- Added 'IsApproved' 02/28/2014 ... Khalsa
-- =============================================

CREATE procedure [dbo].[spGetSupervisedEvents4Worker] (@WorkerFK int, @ProgramFK int)
as
--
set noCount on ;

--declare @intWorkerFK int = try_convert(int, @WorkerFK)

select		IsApproved
		, RowNumber = row_number() over (order by s.WorkerFK)
		, rtrim(w.LastName)+', '+rtrim(w.FirstName) as SupervisorName
		, convert(varchar(10), s.SupervisionDate, 111) as SupervisionDate
		, s.SupervisionPK
		, case s.SupervisionSessionType 
				when '0' 
				then 'Missed Session'
				when '1'
				then 'Scheduled Session'
				when '2'
				then 'Planning'
				when '3'
				then 'Group Session'
			end as SessionType
		-- TakePlace = 1 then 'Yes' else 'No' end as TakePlace
		, case -- convert to string
			when s.SupervisionHours > 0 and s.SupervisionMinutes > 0 then
				convert(varchar(10), s.SupervisionHours) + 
				':' + 
				case when s.SupervisionMinutes < 10
						then '0' 
						else ''
				end + trim(convert(varchar(2), s.SupervisionMinutes))
			when s.SupervisionHours > 0 and (s.SupervisionMinutes = 0 or 
					s.SupervisionMinutes is null) then
				convert(varchar(10), s.SupervisionHours)+':00'
			when (s.SupervisionHours = 0 or s.SupervisionHours is null) and 
					s.SupervisionMinutes > 0 then
				'0:' + 
				case when s.SupervisionMinutes < 10
						then '0' 
						else ''
				end + trim(convert(varchar(2), s.SupervisionMinutes))			
			else ' ' end as HoursMinutes
		, s.WorkerFK
		, s.SupervisorFK
from		Worker w
inner join	Supervision s on s.SupervisorFK = w.WorkerPK
inner join	FormReviewedTableList('SU', @ProgramFK) on FormFK = s.SupervisionPK
where		s.WorkerFK = case when @WorkerFK = -1 
								then s.WorkerFK
								else @WorkerFK
								end 
order by	SupervisionDate desc ;
GO
