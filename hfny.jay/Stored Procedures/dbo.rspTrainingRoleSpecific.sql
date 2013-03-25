SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 03/22/2013
-- Description:	Training [10-3] Credential Evidence (Intensive Role Specific Training)
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingRoleSpecific]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--Get FAW's in time period
;WITH  cteFAWMain AS (
	SELECT DISTINCT wp.workerfk
	, 'FAW' AS CurrentRole
	, wp.FAWStartDate AS StartDate
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FAWStartDate BETWEEN @sdate AND @edate
	AND (FAWEndDate IS NULL OR FAWEndDate > dateadd(day, 180, FAWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > @edate)
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FAWStartDate
)

--Get FSW's in time period
, cteFSWMain AS (

	SELECT DISTINCT wp.workerfk, 'FSW' AS CurrentRole
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
    , wp.FSWStartDate AS StartDate
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FSWStartDate BETWEEN @sdate AND @edate
	AND (FSWEndDate IS NULL OR FSWEndDate > dateadd(day, 180, FSWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > @edate)
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FSWStartDate
)

--Get Supervisor's in time period
, cteSupMain AS (

	SELECT DISTINCT wp.workerfk
	, wp.SupervisorStartDate AS StartDate
	, 'Supervisor' AS CurrentRole
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) AS WorkerName
    , ROW_NUMBER() OVER(ORDER BY workerfk DESC) AS 'RowNumber'
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE SupervisorStartDate BETWEEN @sdate AND @edate
	AND (SupervisorEndDate IS NULL OR SupervisorEndDate > dateadd(day, 180, SupervisorStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > @edate)
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, SupervisorStartDate
)

--Now we get the trainings (or lack thereof)
, cteFAWMainTraining AS (
	SELECT cteFAWMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteFAWMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteFAWMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=10.0
	GROUP BY RowNumber, CurrentRole, cteFAWMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

, cteFSWMainTraining AS (
	SELECT cteFSWMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteFSWMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteFSWMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=11.0
	GROUP BY RowNumber, CurrentRole, cteFSWMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

, cteSuperMainTraining AS (
	SELECT cteSupMain.workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM cteSupMain
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = cteSupMain.WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=12.0
	GROUP BY RowNumber, CurrentRole, cteSupMain.workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

--Put it all together, just before calculating Meeting, %'s and Standard Rating
, cteDetails AS (
		SELECT RowNumber, CurrentRole, cteFAWMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteFAWMain
		LEFT JOIN cteFAWMainTraining ON cteFAWMainTraining.WorkerFK = cteFAWMain.WorkerFK

		UNION

		SELECT RowNumber, CurrentRole, cteFSWMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteFSWMain
		LEFT JOIN cteFSWMainTraining ON cteFSWMainTraining.WorkerFK = cteFSWMain.WorkerFK

		UNION

		SELECT RowNumber, CurrentRole, cteSupMain.workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
		FROM cteSupMain
		LEFT JOIN cteSuperMainTraining ON cteSuperMainTraining.WorkerFK = cteSupMain.WorkerFK
)

--add in the "MEETING" Target and Total workers.  Basically each training must occur within 6 months of start
, cteAggregates AS (
		SELECT RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, CASE WHEN TrainingDate <= dateadd(day, 183, startdate) THEN 'Meeting' ELSE 'Not Meeting' END AS 'Meets Target'
				, MAX(RowNumber) OVER(PARTITION BY CurrentRole) as TotalWorkers
		FROM cteDetails
		GROUP BY RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
)

--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT CurrentRole, count(*) AS totalmeetingcount
		FROM cteAggregates
		WHERE [Meets Target]='Meeting'
		GROUP BY CurrentRole
)

--now put it all together
SELECT *, CAST(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)) AS MeetingPercent
,	CASE WHEN totalmeetingcount/TotalWorkers = 1 THEN '3' 
	WHEN totalmeetingcount/TotalWorkers BETWEEN .9 AND .99 THEN '2'
	WHEN totalmeetingcount/TotalWorkers < .9 THEN '1'
	END AS Rating
FROM cteAggregates
INNER JOIN cteCountMeeting ON cteCountMeeting.CurrentRole = cteAggregates.CurrentRole
ORDER BY cteAggregates.CurrentRole, RowNumber

END
GO
