SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 03/22/2013
-- Description:	Training [10-3] Credential Evidence (Intensive Role Specific Training)
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- Edit date: 10/23/2017 CP - Removed WHERE clause in CTECountMeeting - this was removing
-- Edit date: 12/19/2018 CP - HFA updated the Best Practice standards
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingRoleSpecific]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @cteDetails AS TABLE (
	RowNumber INT, CurrentRole VARCHAR(15), workerfk INT, WorkerName VARCHAR(35), StartDate DATE
				, TopicCode DECIMAL(3,1)
				, topicname VARCHAR(50)
				, TrainingDate DATE
)


DECLARE @cteMAIN AS TABLE (
	workerfk INT
	, CurrentRole VARCHAR(15)
	,   StartDate DATE
	, WorkerName VARCHAR(35)
	, RowNumber INT
	, TopicCode DECIMAL (3,1)
)

INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                      -- RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk
	, 'FAW' AS CurrentRole
	, FAWInitialStart 
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY workerfk DESC) 
	, 10.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FAWInitialStart BETWEEN @sdate AND dateadd(day, -183, GETDATE())
	AND (FAWEndDate IS NULL OR FAWEndDate > dateadd(day, 180, FAWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FAWInitialStart



--Get FSW's in time period
INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                     --  RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk, 'FSW' 
    , FSWInitialStart 
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY workerfk DESC) 
	, 11.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE FSWInitialStart BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (FSWEndDate IS NULL OR FSWEndDate > dateadd(day, 180, FSWStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, FSWInitialStart


--Get Supervisor's in time period
INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                      -- RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk
	, 'Supervisor' 
	, w.SupervisorInitialStart 
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY workerfk DESC) 
	, 12.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE SupervisorInitialStart BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (SupervisorEndDate IS NULL OR SupervisorEndDate > dateadd(day, 180, SupervisorStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, SupervisorInitialStart



--Get Program Manager's in time period
INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                      -- RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk
	, 'Program Manager' AS CurrentRole
	, wp.ProgramManagerStartDate
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY workerfk DESC) 
	, 10.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE wp.ProgramManagerStartDate BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (wp.ProgramManagerEndDate IS NULL OR ProgramManagerEndDate > dateadd(day, 180, ProgramManagerStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, wp.ProgramManagerStartDate

	

--Do it again, this time for topiccode 11 
INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                      -- RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk
	, 'Program Manager' AS CurrentRole
	, wp.ProgramManagerStartDate
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY workerfk DESC) 
	, 11.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE wp.ProgramManagerStartDate BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (wp.ProgramManagerEndDate IS NULL OR ProgramManagerEndDate > dateadd(day, 180, ProgramManagerStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, wp.ProgramManagerStartDate



--DO IT AGAIN for TOpicCode 12
INSERT INTO @cteMAIN ( workerfk ,
                       CurrentRole ,
                       StartDate ,
                       WorkerName ,
                       --RowNumber ,
					   TopicCode )
	SELECT DISTINCT wp.workerfk
	, 'Program Manager' AS CurrentRole
	, wp.ProgramManagerStartDate
	, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) 
   -- , ROW_NUMBER() OVER(ORDER BY TopicCode DESC) 
	, 12.0
	FROM WorkerProgram wp
	INNER JOIN Worker w ON w.WorkerPK = wp.WorkerFK
	WHERE wp.ProgramManagerStartDate BETWEEN @sdate AND  dateadd(day, -183, GETDATE())
	AND (wp.ProgramManagerEndDate IS NULL OR ProgramManagerEndDate > dateadd(day, 180, ProgramManagerStartDate))
	AND (wp.TerminationDate IS NULL OR wp.TerminationDate > GETDATE())
	AND wp.ProgramFK = @progfk
	GROUP BY wp.WorkerFK, LastName, FirstName, wp.ProgramManagerStartDate


DECLARE @topiccodecount AS TABLE (
	TotalWorkers INT
	, topiccode DECIMAL(3,1)
	)

INSERT INTO @topiccodecount ( TotalWorkers ,
                              topiccode )
SELECT COUNT([@cteMAIN].TopicCode), [@cteMAIN].TopicCode FROM @cteMAIN  GROUP BY TopicCode

UPDATE @cteMAIN SET RowNumber=TotalWorkers
FROM @cteMAIN INNER JOIN @topiccodecount ON [@topiccodecount].topiccode = [@cteMAIN].TopicCode

--Now we get the trainings (or lack thereof)
DECLARE @cteMAINTraining AS TABLE(
		workerfk INT
		, TopicCode DECIMAL(3,1)
		, topicname VARCHAR(50)
		, TrainingDate DATE
		)


; with cteFAWMainTraining AS (
	SELECT [@cteMAIN].workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM @cteMAIN
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = [@cteMAIN].WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=10.0 AND CurrentRole='FAW'
	GROUP BY RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

INSERT INTO @cteMAINTraining ( workerfk ,
                               TopicCode ,
                               topicname ,
                               TrainingDate )
SELECT workerfk ,  TopicCode ,  topicname ,  TrainingDate
FROM cteFAWMainTraining

; WITH cteFSWMainTraining AS (
	SELECT [@cteMAIN].workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM @cteMAIN
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = [@cteMAIN].WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=11.0 AND CurrentRole='FSW'
	GROUP BY RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname
)

INSERT INTO @cteMAINTraining ( workerfk ,
                               TopicCode ,
                               topicname ,
                               TrainingDate )
SELECT workerfk ,  TopicCode ,  topicname ,  TrainingDate
FROM cteFSWMainTraining


--Now add Program Managers for topic code 11
INSERT INTO @cteMAINTraining ( workerfk ,
                               TopicCode ,
                               topicname ,
                               TrainingDate )
SELECT [@cteMAIN].workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
	FROM @cteMAIN
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = [@cteMAIN].WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE t1.TopicCode=11.0 AND CurrentRole='Program Manager'
	GROUP BY RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname



; with cteSuperMainTraining2 AS (
	SELECT [@cteMAIN].workerfk
		, t1.TopicCode
		, t1.topicname
		, MIN(t.TrainingDate) AS TrainingDate
		, ROW_NUMBER() OVER (PARTITION BY [@cteMAIN].workerfk ORDER BY TrainingDate) AS myrow
	FROM @cteMAIN
			LEFT JOIN TrainingAttendee ta ON ta.WorkerFK = [@cteMAIN].WorkerFK
			LEFT JOIN Training t ON t.TrainingPK = ta.TrainingFK
			LEFT JOIN TrainingDetail td ON td.TrainingFK = t.TrainingPK
			LEFT JOIN codeTopic t1 ON td.TopicFK=t1.codeTopicPK
	WHERE (t1.TopicCode=12.0 OR t1.TopicCode=12.1) AND (CurrentRole='Supervisor' OR CurrentRole ='Program Mgr')
	GROUP BY RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate, t.TrainingDate
			, t1.TopicCode
			, t1.topicname
)

, cteSuperMainTraining AS (
	SELECT workerfk
		,TopicCode
		, topicname
		, TrainingDate
	FROM cteSuperMainTraining2
	WHERE cteSuperMainTraining2.myrow = 1
)

INSERT INTO @cteMAINTraining ( workerfk ,
                               TopicCode ,
                               topicname ,
                               TrainingDate )
SELECT workerfk ,  CASE WHEN TopicCode = 12.1 THEN 12.0 ELSE TopicCode END  -- 12.1 is stop gap and counts towards 12.0, the topic codes must match in @cteDetails to count 
,  topicname ,  TrainingDate
FROM cteSuperMainTraining


INSERT INTO @cteDetails ( RowNumber ,
                          CurrentRole ,
                          workerfk ,
                          WorkerName ,
                          StartDate ,
                          TopicCode ,
                          topicname ,
                          TrainingDate )
	SELECT RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate
				, [@cteMAIN].TopicCode
				, t1.topicname
				, TrainingDate
		FROM @cteMAIN
		LEFT JOIN @cteMAINTraining ON [@cteMAINTraining].WorkerFK = [@cteMAIN].WorkerFK AND [@cteMAINTraining].TopicCode = [@cteMAIN].TopicCode
		INNER JOIN codeTopic t1 ON [@cteMAIN].TopicCode=t1.TopicCode


		
		UPDATE @cteDetails SET TopicCode=10.0 WHERE (CurrentRole='FAW' OR CurrentRole='Program Manager') AND TopicCode IS NULL
		UPDATE @cteDetails SET TopicCode=11.0 WHERE (CurrentRole='FSW' OR CurrentRole='Program Manager')  AND TopicCode IS NULL
		UPDATE @cteDetails SET TopicCode=12.0 WHERE (CurrentRole='Supervisor' OR CurrentRole='Program Manager')  AND TopicCode IS NULL

		
--add in the "MEETING" Target and Total workers.  Basically each training must occur within 6 months of start
;with cteAggregates AS (
		SELECT RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, CASE WHEN TrainingDate <= dateadd(day, 183, startdate) THEN 'Meeting' ELSE 'Not Meeting' END AS 'Meets Target'
				, CASE WHEN TrainingDate IS NULL THEN 1 
					WHEN TrainingDate <= dateadd(day, 183, startdate) THEN 3
					WHEN DATEDIFF(DAY, @sdate, [@cteDetails].StartDate) > 546 AND TrainingDate IS NOT NULL THEN 2 
					ELSE 1 END AS 'IndividualRating'


				, MAX(RowNumber) OVER(PARTITION BY TopicCode) as TotalWorkers
		FROM @cteDetails
		GROUP BY RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, StartDate
)



--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT TopicCode, count(*) AS totalmeetingcount
		FROM cteAggregates
		WHERE [Meets Target]='Meeting'
		GROUP BY cteAggregates.TopicCode
)


----now put it all together
SELECT cteAggregates.CurrentRole, cteAggregates.RowNumber, cteAggregates.workerfk
, cteAggregates.WorkerName, cteAggregates.StartDate, cteAggregates.TopicCode, cteAggregates.topicname
, cteAggregates.TrainingDate, cteAggregates.[Meets target], cteAggregates.TotalWorkers
,  case when cteAggregates.CurrentRole is null then cteAggregates.CurrentRole else cteAggregates.CurrentRole end as CurrentRole
,  case when cteCountMeeting.totalmeetingcount is null then 0 else cteCountMeeting.totalmeetingcount end as [totalmeetingcount]
,  case when totalmeetingcount is null then 0 else cast(totalmeetingcount AS decimal(10,2)) / CAST(TotalWorkers AS decimal(10,2)) end AS MeetingPercent
, 	(SELECT TOP 1 IndividualRating FROM cteAggregates cte WHERE cteAggregates.TopicCode = cte.TopicCode ORDER BY IndividualRating) AS Rating
, IndividualRating
,	CASE cteAggregates.CurrentRole 
		WHEN 'FAW' THEN '10-4a. Staff conducting assessments have received intensive role specific training within six months of date of hire to understand the essential components of family assessment'
		WHEN 'FSW' THEN '10-4b. Home Visitors have received intensive role specific training within six months of date of hire to understand the essential components of home visitation'
		WHEN 'Supervisor' THEN '10-4c. Supervisory staff have received intensive role specific training whithin six months of date of hire to understand the essential components of their role within the home visitation program, as well as the role of the family assessment and home visitation'
		WHEN 'Program Manager' THEN
			CASE WHEN cteAggregates.TopicCode = '10.0' THEN '10-4a. Staff conducting assessments have received intensive role specific training within six months of date of hire to understand the essential components of family assessment'
				WHEN cteAggregates.TopicCode = '11.0' THEN '10-4b. Home Visitors have received intensive role specific training within six months of date of hire to understand the essential components of home visitation'
				WHEN cteAggregates.TopicCode = '12.0' THEN '10-4c. Supervisory staff have received intensive role specific training whithin six months of date of hire to understand the essential components of their role within the home visitation program, as well as the role of the family assessment and home visitation'
			END	
	END AS CSST
FROM cteAggregates
LEFT JOIN cteCountMeeting ON cteCountMeeting.TopicCode = cteAggregates.TopicCode
group by cteAggregates.CurrentRole, cteAggregates.RowNumber, cteAggregates.workerfk
, cteAggregates.WorkerName, cteAggregates.StartDate, cteAggregates.TopicCode, cteAggregates.topicname
, cteAggregates.TrainingDate, cteAggregates.[Meets target], cteAggregates.TotalWorkers, cteCountMeeting.TopicCode
, cteCountMeeting.totalmeetingcount, IndividualRating
ORDER BY cteAggregates.CurrentRole,RowNumber



END
GO
