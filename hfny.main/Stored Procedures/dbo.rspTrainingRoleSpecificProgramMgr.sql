SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 02/27/2019
-- Description:	Similar to rspTrainingRoleSpecific Training report [10-4], but Program 
--              Managers must get one training in 6 months and all 3 by 12 months of hire date 
--         USE: exec rspTrainingRoleSpecificProgramMgr '01/01/2012', 1
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingRoleSpecificProgramMgr]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @finalaggregates AS TABLE (
	RowNumber INT,
	CurrentRole VARCHAR(30),
	workerfk INT,
	WorkerName VARCHAR(50),
	StartDate DATE,
	TopicCode DECIMAL(4,1),
	TopicName VARCHAR(150),
	TrainingDate DATE,
	IndividualRating INT,
	IndividualRating2 INT,
	TotalWorkers INT,
	CSST varchar(MAX)
)
DECLARE @individualratingtbl AS TABLE (
	RowNumber INT,
	IndividualRating2 INT
)

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


--Now add Program Managers for topic code 10
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
	WHERE t1.TopicCode=10.0 AND CurrentRole='Program Manager'
	GROUP BY RowNumber, CurrentRole, [@cteMAIN].workerfk, WorkerName, StartDate
			, t1.TopicCode
			, t1.topicname


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


--Now add Program Managers for topic code 12
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
	WHERE t1.TopicCode=12.0 AND CurrentRole='Program Manager'
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
	WHERE (t1.TopicCode=12.0 OR t1.TopicCode=12.1) AND (CurrentRole ='Program Mgr')
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


		
		UPDATE @cteDetails SET TopicCode=10.0 WHERE (CurrentRole='Program Manager') AND TopicCode IS NULL
		UPDATE @cteDetails SET TopicCode=11.0 WHERE (CurrentRole='Program Manager')  AND TopicCode IS NULL
		UPDATE @cteDetails SET TopicCode=12.0 WHERE (CurrentRole='Program Manager')  AND TopicCode IS NULL

		
--add in the "MEETING" Target and Total workers.  Basically each training must occur within 6 months of start
DECLARE @cteAggregates AS TABLE  (
	RowNumber INT,
	CurrentRole VARCHAR(30),
	workerfk INT,
	WorkerName VARCHAR(50),
	StartDate DATE,
	TopicCode DECIMAL(4,1),
	TopicName VARCHAR(150),
	TrainingDate DATE,
	IndividualRating INT,
	TotalWorkers INT
)

INSERT INTO @cteAggregates ( RowNumber ,
                             CurrentRole ,
                             workerfk ,
                             WorkerName ,
                             StartDate ,
                             TopicCode ,
                             TopicName ,
                             TrainingDate ,
                             IndividualRating ,
                             TotalWorkers )
		SELECT RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, CASE WHEN GETDATE() >= dateadd(day, 365, startdate) THEN 
						--if at position for more than one year they must have all three trainings
					  CASE WHEN TrainingDate <= dateadd(day, 365, startdate) THEN 3 END
				  WHEN GETDATE() >= dateadd(day, 183, startdate) THEN
					  CASE WHEN TrainingDate <= dateadd(day, 183, startdate) THEN 3 END
				  ELSE
						--No trainings required
						CASE WHEN TrainingDate IS NOT NULL THEN '3' ELSE '2' END
				  END AS 'IndividualRating'

				, MAX(RowNumber) OVER(PARTITION BY TopicCode) as TotalWorkers
		FROM @cteDetails
		GROUP BY RowNumber, CurrentRole, workerfk, WorkerName, StartDate
				, TopicCode
				, topicname
				, TrainingDate
				, StartDate


INSERT INTO @individualratingtbl ( RowNumber ,
                                   IndividualRating2 )
	SELECT  RowNumber ,
  			SUM(IndividualRating)
	 FROM @cteAggregates
	 GROUP BY [@cteAggregates].RowNumber


INSERT INTO @finalaggregates ( RowNumber ,
                               CurrentRole ,
                               workerfk ,
                               WorkerName ,
                               StartDate ,
                               TopicCode ,
                               TopicName ,
                               TrainingDate ,
                               IndividualRating ,
                               IndividualRating2 ,
                               TotalWorkers,
							   CSST )
SELECT	[@individualratingtbl].RowNumber ,
        CurrentRole ,
        workerfk ,
        WorkerName ,
        StartDate ,
        TopicCode ,
        TopicName ,
        TrainingDate ,
        CASE WHEN GETDATE() >= dateadd(day, 365, startdate) THEN
				CASE WHEN IndividualRating2 >= 9 THEN 3 ELSE 1 END
			WHEN GETDATE() >= dateadd(day, 183, startdate) THEN
				CASE WHEN IndividualRating2 >= 5 THEN 3 ELSE 1 END
			WHEN GETDATE() < dateadd(day, 183, startdate) THEN
				CASE WHEN IndividualRating2 >= 5 THEN 3 ELSE 2 END
		END AS IndividualRating,
        (SELECT MIN(IndividualRating) FROM @cteAggregates), --AS IndividualRating2 : The minimum rating is used as the Program Rating on the report,
        TotalWorkers,
		CASE TopicCode 
		WHEN 10.0 THEN '10-4a. Staff conducting assessments have received intensive role specific training within six months of date of hire to understand the essential components of family assessment'
		WHEN 11.0 THEN '10-4b. Home Visitors have received intensive role specific training within six months of date of hire to understand the essential components of home visitation'
		WHEN 12.0 THEN '10-4c. Supervisory staff have received intensive role specific training whithin six months of date of hire to understand the essential components of their role within the home visitation program, as well as the role of the family assessment and home visitation'
		END 
 FROM @cteAggregates
 INNER JOIN @individualratingtbl ON [@individualratingtbl].RowNumber = [@cteAggregates].RowNumber



 SELECT * FROM @finalaggregates

 --exec rspTrainingRoleSpecificProgramMgr '01/01/2012', 1



END
GO
