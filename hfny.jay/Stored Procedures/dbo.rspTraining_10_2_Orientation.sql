
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
		, RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName) AS WorkerName
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
	WHERE t1.TopicCode = 1.0
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

, cteAddMissingWorkers_cte10_2a AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT cteMain.RowNumber
		, cteMain.workerpk
		, '1.0' AS TopicCode
		, cte10_2a.topicname
		, cte10_2a.TrainingDate
		, cte10_2a.FirstHomeVisitDate
		, cte10_2a.FirstKempeDate
		, cte10_2a.SupervisorFirstEvent
		, cte10_2a.FirstEvent
		, cteMain.WorkerName
		, cteMain.Supervisor
		, cteMain.FSW
		, cteMain.FAW
	FROM cte10_2a
	RIGHT JOIN cteMain ON cteMain.WorkerPK = cte10_2a.WorkerPK
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


, cteAddMissingWorkers_cte10_2b AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT cteMain.RowNumber
		, cteMain.workerpk
		, '2.0' AS TopicCode
		, cte10_2b.topicname
		, cte10_2b.TrainingDate
		, cte10_2b.FirstHomeVisitDate
		, cte10_2b.FirstKempeDate
		, cte10_2b.SupervisorFirstEvent
		, cte10_2b.FirstEvent
		, cteMain.WorkerName
		, cteMain.Supervisor
		, cteMain.FSW
		, cteMain.FAW
	FROM cte10_2b
	RIGHT JOIN cteMain ON cteMain.WorkerPK = cte10_2b.WorkerPK
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

, cteAddMissingWorkers_cte10_2c AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT cteMain.RowNumber
		, cteMain.workerpk
		, '3.0' AS TopicCode
		, cte10_2c.topicname
		, cte10_2c.TrainingDate
		, cte10_2c.FirstHomeVisitDate
		, cte10_2c.FirstKempeDate
		, cte10_2c.SupervisorFirstEvent
		, cte10_2c.FirstEvent
		, cteMain.WorkerName
		, cteMain.Supervisor
		, cteMain.FSW
		, cteMain.FAW
	FROM cte10_2c
	RIGHT JOIN cteMain ON cteMain.WorkerPK = cte10_2c.WorkerPK
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

, cteAddMissingWorkers_cte10_2d AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT cteMain.RowNumber
		, cteMain.workerpk
		, '4.0' AS TopicCode
		, cte10_2d.topicname
		, cte10_2d.TrainingDate
		, cte10_2d.FirstHomeVisitDate
		, cte10_2d.FirstKempeDate
		, cte10_2d.SupervisorFirstEvent
		, cte10_2d.FirstEvent
		, cteMain.WorkerName
		, cteMain.Supervisor
		, cteMain.FSW
		, cteMain.FAW
	FROM cte10_2d
	RIGHT JOIN cteMain ON cteMain.WorkerPK = cte10_2d.WorkerPK
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

, cteAddMissingWorkers_cte10_2e AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
	SELECT cteMain.RowNumber
		, cteMain.workerpk
		, '5.0' AS TopicCode
		, cte10_2e.topicname
		, cte10_2e.TrainingDate
		, cte10_2e.FirstHomeVisitDate
		, cte10_2e.FirstKempeDate
		, cte10_2e.SupervisorFirstEvent
		, cte10_2e.FirstEvent
		, cteMain.WorkerName
		, cteMain.Supervisor
		, cteMain.FSW
		, cteMain.FAW
	FROM cte10_2e
	RIGHT JOIN cteMain ON cteMain.WorkerPK = cte10_2e.WorkerPK
)

, cteUNION AS(
	SELECT * FROM cteAddMissingWorkers_cte10_2a
	UNION
	SELECT * FROM cteAddMissingWorkers_cte10_2b
	UNION	
	SELECT * FROM cteAddMissingWorkers_cte10_2c
	UNION	
	SELECT * FROM cteAddMissingWorkers_cte10_2d
	UNION	
	SELECT * FROM cteAddMissingWorkers_cte10_2e
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
	, CASE WHEN TrainingDate <= dateadd(day, 183, FirstEvent) THEN 'T' ELSE 'F' END AS 'Meets Target'
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
		WHERE [Meets Target]='T'
		GROUP BY TopicCode
)


SELECT TotalWorkers
, WorkerPK
, WorkerName
, Supervisor
, FSW
, FAW
, cteMeetTarget.topiccode
, cteCountMeeting.TopicCode
	, CASE WHEN cteCountMeeting.TopicCode = 1.0 THEN '10-2a. Staff (assessment workers, home visitors and supervisors) are oriented
		to their roles as they relate to the programs goals, services policies and operating procedures and philosophy of home visiting
		/family support prior to direct work with children and families' 
	WHEN cteCountMeeting.TopicCode = 2.0 THEN '10-2b. Staff (assessment workers, home visitors and supervisors) are oriented 
		to the programs relationship with other community resources prior to direct work with children and families'  
	WHEN cteCountMeeting.TopicCode = 3.0 THEN '10-2c. Staff (assessment workers, home visitors and supervisors) are oriented
		to child abuse and neglect indicators and reporting requirements prior to direct work with children and families' 
	WHEN cteCountMeeting.TopicCode = 4.0 THEN '10-2d. Staff (assessment workers, home visitors and supervisors) are oriented
		to issues of confidentiality prior to direct work with children and families' 
	WHEN cteCountMeeting.TopicCode = 5.0 THEN '10-2e. Staff (assessment workers, home visitors and supervisors) are oriented
		to issues related to boundaries prior to direct work with children and families' 
	END AS TopicName
, TrainingDate
, FirstHomeVisitDate
, FirstKempeDate
, SupervisorFirstEvent
, FirstEvent
, [Meets Target]
, totalmeetingcount
, CONVERT(VARCHAR(MAX), CONVERT(INT,100*(CAST(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)))))+ '%'  AS MeetingPercent
,	CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) > .9 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(TotalWorkers AS DECIMAL) < .9 THEN '1'
	END AS Rating
FROM cteMeetTarget
INNER JOIN cteCountMeeting ON cteCountMeeting.TopicCode = cteMeetTarget.TopicCode
ORDER BY cteCountMeeting.topiccode

END
GO
