SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/03/2013
-- Description:	Training [NYS 3 IFSP] New York State Required Trainings
-- EXEC rspTraining_10_2_Orientation @progfk = 30, @sdate = '07/01/2008'
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_10_2_Orientation]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@sdate AS date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


;WITH  cteMain AS (
	SELECT g.WorkerPK, g.WrkrLName, g.FirstHomeVisitDate
	, g.FirstKempeDate, g.SupervisorFirstEvent
	, g.FirstEvent
		, w.FirstName + ' ' + w.LastName AS WorkerName
		, wp.Supervisor
		, wp.FSW
		, wp.FAW
		, ROW_NUMBER() OVER(ORDER BY g.workerpk DESC) AS 'RowNumber'
	FROM dbo.fnGetWorkerEventDatesALL(@progfk, NULL, NULL) g
	INNER JOIN Worker w ON w.WorkerPK = g.WorkerPK
	INNER JOIN WorkerProgram wp ON g.WorkerPK = wp.WorkerFK
	WHERE g.FirstEvent > @sdate
	AND ((wp.FAW = 1 AND wp.FAWEndDate IS NULL)
	OR (wp.FSW = 1 AND wp.FSWEndDate IS NULL)
	OR (wp.Supervisor =1 AND wp.SupervisorEndDate IS NULL))
	AND wp.HireDate > @sdate
	AND wp.TerminationDate IS NULL
	
)
 
--Now we get the trainings (or lack thereof) for topic code 1.0
, cte10_2a AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=1.0
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)

--Now we get the trainings (or lack thereof) for topic code 2.0
, cte10_2b AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=2.0
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)

--Now we get the trainings (or lack thereof) for topic code 3.0
, cte10_2c AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=3.0
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)

--Now we get the trainings (or lack thereof) for topic code 4.0
, cte10_2d AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=4.0
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)

--Now we get the trainings (or lack thereof) for topic code 5.0
, cte10_2e AS (
	SELECT RowNumber
		, cteMain.workerpk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, FirstHomeVisitDate
		, FirstKempeDate
		, SupervisorFirstEvent
		, FirstEvent
		, WorkerName
		, Supervisor
		, FSW
		, FAW
	FROM cteMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteMain.WorkerPK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=5.0
	GROUP BY WorkerPK, WrkrLName, FirstHomeVisitDate
	, FirstKempeDate, SupervisorFirstEvent, FirstEvent
			, t1.TopicCode
			, t1.topicname
			, WorkerName
			, Supervisor
			, FSW
			, FAW
			, rownumber
)

, cteUNION AS(
	SELECT * FROM cte10_2a
	UNION
	SELECT * FROM cte10_2b
	UNION	
	SELECT * FROM cte10_2c
	UNION	
	SELECT * FROM cte10_2d
	UNION	
	SELECT * FROM cte10_2e
)

, cteMeetTarget AS (
	SELECT MAX(RowNumber) OVER(PARTITION BY TopicCode) as TotalWorkers
	, cteunion.WorkerPK
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, TopicCode
	, TopicName
	, TrainingDate
	, FirstHomeVisitDate
	, FirstKempeDate
	, cteunion.SupervisorFirstEvent
	, FirstEvent
	, CASE WHEN TrainingDate <= dateadd(day, 183, FirstEvent) THEN 'Meeting' ELSE 'Not Meeting' END AS 'Meets Target'
	FROM cteUNION
	GROUP BY cteunion.WorkerPK
	, WorkerName
	, Supervisor
	, FSW
	, FAW
	, TopicCode
	, TopicName
	, TrainingDate
	, FirstHomeVisitDate
	, FirstKempeDate
	, cteunion.SupervisorFirstEvent
	, FirstEvent
	, rownumber
)

--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT TopicCode, count(*) AS totalmeetingcount
		FROM cteMeetTarget
		WHERE [Meets Target]='Meeting'
		GROUP BY TopicCode
)

SELECT *, CAST(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)) AS MeetingPercent
,	CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) > .9 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) < .9 THEN '1'
	END AS Rating
FROM cteMeetTarget
INNER JOIN cteCountMeeting ON cteCountMeeting.TopicCode = cteMeetTarget.TopicCode
ORDER BY cteCountMeeting.topiccode


END
GO
