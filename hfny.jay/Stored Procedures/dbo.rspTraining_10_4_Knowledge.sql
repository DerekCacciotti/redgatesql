
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/08/2013
-- Description:	Training [NYS 4] Knowledge Training by 6 Months
-- EXEC rspTraining_10_2_Orientation @progfk = 30, @sdate = '07/01/2008'
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_10_4_Knowledge]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@sdate AS date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


;WITH  cteMain AS (
	SELECT w.WorkerPK
		, RTRIM(w.FirstName) + ' ' + RTRIM(w.LastName) AS WorkerName
		, wp.HireDate
		, wp.Supervisor
		, wp.FSW
		, wp.FAW
		, wp.ProgramManager
		, wp.FatherAdvocate
		, ROW_NUMBER() OVER(ORDER BY w.workerpk DESC) AS 'RowNumber'
	FROM Worker w 
	INNER JOIN WorkerProgram wp ON w.WorkerPK = wp.WorkerFK
	WHERE wp.HireDate > @sdate
	AND ((wp.FAW = 1 AND wp.FAWEndDate IS NULL)
	OR (wp.FSW = 1 AND wp.FSWEndDate IS NULL)
	OR (wp.Supervisor =1 AND wp.SupervisorEndDate IS NULL))
	AND wp.TerminationDate IS NULL
	AND wp.ProgramFK=@progfk
	
)


--GetAll TrainingCodes/subtopics required for this report
, cteCodesSubtopics AS (
SELECT [TopicName]
      ,[TopicCode]
      ,[SATInterval]
      ,[SATName]
      ,[SATReqBy]
      ,[SubTopicPK]
      ,[ProgramFK]
      ,[RequiredBy]
      ,[SATFK]
      ,[SubTopicCode]
      ,[SubTopicName]
      ,[TopicFK]
  FROM codeTopic
  INNER JOIN subtopic on subtopic.topicfk=codetopic.codetopicPK
  where topiccode between 14.0 and 19.0 AND requiredby='HFA'
  )
  
, cteWorkersTopics AS (
	 Select workerpk
		, WorkerName
		, Supervisor
		, cteMain.HireDate
		, FSW
		, FAW
		, ProgramManager
		, FatherAdvocate
		, RowNumber
		, [TopicName]
		, [TopicCode]
		, [SATName]
		, [SubTopicCode]
		, [SubTopicName]
	  from cteMain, cteCodesSubtopics
 )
 
 
--Now we get the trainings (or lack thereof) for topic code 1.0
, cte10_4a AS (
	SELECT workerfk
		, t1.TopicCode
		, t1.topicname
		, s.subtopiccode
		, MIN(trainingdate) AS TrainingDate
		, cteMain.HireDate
		, MAX(CAST(IsExempt as INT)) as IsExempt
	FROM TrainingAttendee ta 
			INNER JOIN Training t ON t.TrainingPK = ta.TrainingFK
			INNER JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			INNER JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
			INNER JOIN Subtopic s ON s.TopicFK=t1.codeTopicPK AND s.SubTopicPK=td.SubTopicFK
			INNER JOIN cteMain on cteMain.WorkerPK = ta.workerfk
	WHERE t1.TopicCode between 14.0 and 19.0 AND requiredby='HFA'
	GROUP BY  workerfk
			, t1.TopicCode
			, t1.topicname
			, HireDate
			, s.subtopiccode

)

, cteAddMissingWorkers AS (
	--if a worker has NO trainings, they won't appear at all, so add them back
		SELECT DISTINCT  workerfk
		, TrainingDate
		, workerpk
		, WorkerName
		, cteWorkersTopics.HireDate
		, Supervisor
		, FSW
		, FAW
		, ProgramManager
		, FatherAdvocate
		, RowNumber
		, cteWorkersTopics.[TopicName]
		, cteWorkersTopics.[TopicCode]
		, [SATName]
		, cteWorkersTopics.[SubTopicCode]
		, [SubTopicName]
		, IsExempt
		FROM cte10_4a
		right JOIN cteWorkersTopics ON cteWorkersTopics.workerpk = cte10_4a.workerfk 
		AND cte10_4a.TopicCode = cteWorkersTopics.TopicCode AND cte10_4a.SubTopicCode = cteWorkersTopics.SubTopicCode
		)


, cteMeetTarget AS (
	SELECT MAX(RowNumber) OVER(PARTITION BY TopicCode) as TotalWorkers
	, cteAddMissingWorkers.WorkerPK
	, WorkerName
	, HireDate
	, Supervisor
	, FSW
	, FAW
	, ProgramManager
	, FatherAdvocate
	, TopicCode
	, subtopiccode
	, TrainingDate
	, CASE WHEN TrainingDate IS NOT NULL THEN 1 END AS ContentCompleted
	, CASE WHEN TrainingDate <= dateadd(day, 183, HireDate) THEN 1 
		when IsExempt='1' then '1'
			ELSE 0 END AS 'Meets Target'
	FROM cteAddMissingWorkers
	GROUP BY WorkerPK
	, WorkerName
	, HireDate
	, Supervisor
	, FSW
	, FAW
	, ProgramManager
	, FatherAdvocate
	, TopicCode
	, TopicName
	, subtopiccode
	, TrainingDate
	, rownumber
	, IsExempt
)

--Now calculate the number meeting count
, cteCountMeeting AS (
		SELECT TopicCode, subtopiccode, workerpk, count(*) OVER (PARTITION BY TopicCode, subtopiccode) AS totalmeetingcount
		FROM cteMeetTarget
		WHERE [Meets Target]=1
		GROUP BY TopicCode, subtopiccode, workerpk
)

--SELECT * FROM cteCountMeeting ORDER BY workerpk, topiccode, subtopiccode
, cteAlmostFinal AS (
		SELECT TotalWorkers
		, cteMeetTarget.WorkerPK
		, WorkerName
		, Supervisor
		, FSW
		, FAW
		, ProgramManager
		, FatherAdvocate
		, cteMeetTarget.topiccode
		, cteMeetTarget.subtopiccode
		, SUM(ContentCompleted) OVER (PARTITION BY cteMeetTarget.Workerpk, cteMeetTarget.TopicCode) AS ContentCompleted	
		, SUM([Meets Target]) OVER (PARTITION BY cteMeetTarget.Workerpk, cteMeetTarget.TopicCode) AS CAMeetingTarget	
		, CASE WHEN cteMeetTarget.TopicCode = 14.0 THEN '10-4a. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Infant Care within six months of the date of hire' 
			WHEN cteMeetTarget.TopicCode = 15.0 THEN '10-4b. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Child Health and Safety within six months of the date of hire'  
			WHEN cteMeetTarget.TopicCode = 16.0 THEN '10-4c. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Maternal and Family Health within six months of the date of hire' 
			WHEN cteMeetTarget.TopicCode = 17.0 THEN '10-4d. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Infant and Child Development within six months of the date of hire' 
			WHEN cteMeetTarget.TopicCode = 18.0 THEN '10-4e. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Role of Culture in Parenting within six months of the date of hire' 
			WHEN cteMeetTarget.TopicCode = 19.0 THEN '10-4f. Staff (assessment workers, home visitors and supervisors) demonstrate knowledge of Supporting the Parent-Child Relationship within six months of the date of hire' 
			END AS TopicName
		, TrainingDate
		, HireDate
		, [Meets Target]
		, sum(TotalMeetingCount) as TotalMeetingCount
		, CASE WHEN 
				CAST(SUM([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS decimal(10,2))
					/ CAST(COUNT([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS decimal(10,2))
				= 1 THEN 1
			END AS MeetsTargetForAll
		, CASE WHEN 
				CAST(SUM([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS decimal(10,2))
					/ CAST(COUNT([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS decimal(10,2))
				BETWEEN .5 AND .99 THEN 1
			END AS MeetsTargetForMajority
		, CAST(COUNT([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS INT) AS TotalContentAreasByTopicAndWorker
		, CASE WHEN 
				CAST(SUM([ContentCompleted]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS decimal(10,2))
					/ CAST(COUNT([Meets Target]) OVER (PARTITION BY cteMeetTarget.WorkerPK, cteMeetTarget.TopicCode) AS INT)
				= 1 then 1
				END AS TotalCompletedToDate
		FROM cteMeetTarget
		LEFT JOIN cteCountMeeting ON cteCountMeeting.TopicCode = cteMeetTarget.TopicCode AND ctecountmeeting.subtopiccode=cteMeetTarget.subtopiccode AND ctecountmeeting.workerpk=cteMeetTarget.workerpk
		GROUP BY TotalWorkers
		, cteMeetTarget.WorkerPK
		, WorkerName
		, Supervisor
		, FSW
		, FAW
		, ProgramManager
		, FatherAdvocate
		, cteMeetTarget.topiccode
		, cteMeetTarget.subtopiccode
		, cteMeetTarget.ContentCompleted
		, cteMeetTarget.[Meets Target]
		, cteMeetTarget.TrainingDate
		, cteMeetTarget.Hiredate
		, cteCountMeeting.totalmeetingcount
)


		
	SELECT DISTINCT TotalWorkers
		, WorkerPK
		, WorkerName
		, Supervisor
		, FSW
		, FAW
		, ProgramManager
		, FatherAdvocate
		, topiccode
		, ContentCompleted AS IndivContentCompleted
		, CAMeetingTarget AS IndivContentMeeting
		, CAST(CAMeetingTarget AS decimal(10,2))/ CAST(TotalContentAreasByTopicAndWorker AS decimal(10,2)) AS IndivPercByTopic
		, TopicName
		, HireDate
		, TotalContentAreasByTopicAndWorker AS SubtopicCA_PerTopic
		,	CASE WHEN CAMeetingTarget = TotalContentAreasByTopicAndWorker THEN '3' 
			WHEN ContentCompleted = TotalContentAreasByTopicAndWorker THEN '2'
			ELSE '1'
			END AS TopicRatingByWorker
		,	CASE WHEN SUM(MeetsTargetForAll) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker = TotalWorkers THEN '3' 
			WHEN (SUM(MeetsTargetForAll) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker) + (SUM(MeetsTargetForMajority) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker) = TotalWorkers THEN '2'
			ELSE '1'
			END AS TopicRatingBySite
		, CASE WHEN SUM(MeetsTargetForAll) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker > .9 THEN SUM(MeetsTargetForAll) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker
		  ELSE 0
		  END AS TotalMeetsTargetForAll
		, CASE WHEN SUM(MeetsTargetForMajority) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker > .9 THEN SUM(MeetsTargetForMajority) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker
		  ELSE 0
		  END AS TotalMeetsTargetForMajority
		, SUM(TotalCompletedToDate) OVER (PARTITION BY topiccode) / TotalContentAreasByTopicAndWorker AS TotalCompletedToDate
		FROM cteAlmostFinal
END
GO
