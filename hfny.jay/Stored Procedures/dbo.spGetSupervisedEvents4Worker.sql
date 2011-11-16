SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--[spGetSupervisedEvents4Worker] 14

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: Oct. 5th, 2011
-- Description:	Return all supervised events for the given worker,
--for use in Supervision and Training
-- =============================================

CREATE PROCEDURE [dbo].[spGetSupervisedEvents4Worker]
(@WorkerFK int)

AS

SET NOCOUNT ON;

SELECT 
RowNumber = ROW_NUMBER() OVER(Order by s.WorkerFK), 
rtrim(w.LastName) + ' ' + rtrim(w.FirstName) as SupervisorName, s.SupervisionDate,s.SupervisionPK,

CASE
	WHEN s.TakePlace = 1 THEN 'Yes' ELSE 'No' END
as TakePlace,

CASE -- convert into to string
	WHEN s.SupervisionHours > 0 AND s.SupervisionMinutes > 0 THEN CONVERT(varchar(10),s.SupervisionHours) + ':' + CONVERT(varchar(10),s.SupervisionMinutes)
	WHEN s.SupervisionHours > 0 AND s.SupervisionMinutes = 0 THEN CONVERT(varchar(10),s.SupervisionHours) + ':00'
	WHEN s.SupervisionHours = 0 AND s.SupervisionMinutes > 0 THEN '00:' + CONVERT(varchar(10),s.SupervisionMinutes)
	ELSE ' ' END

as HoursMinutes,

s.WorkerFK,s.SupervisorFK FROM Worker w
INNER JOIN Supervision s ON s.SupervisorFK = w.WorkerPK
WHERE s.WorkerFK = @WorkerFK
ORDER BY SupervisionDate DESC
GO
