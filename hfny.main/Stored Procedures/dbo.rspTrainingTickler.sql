
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 11/15/2013
-- Description:	Training Tickler
-- EXEC rspTrainingTickler @progfk = 1, @workerfk = 154, @supervisorfk = 0
-- exec dbo.rspTrainingTickler @progfk=1,@workerfk=0,@supervisorfk=0
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingTickler]
	-- Add the parameters for the stored procedure here
	@progfk AS INT,
	@workerfk AS INT,
	@supervisorfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

IF @supervisorfk = 0 SET @supervisorfk = NULL
IF @workerfk = 0 SET @workerfk = NULL

; WITH cteTopicList AS (
SELECT DISTINCT codeTopicPK as TopicFK, TopicName, TopicCode, SATCompareDateField
, SATInterval, satname, DaysAfter
, null as SubTopicCode , null as SubTopicName, null as TrainingTickler, null as SubTopicPK
FROM dbo.codeTopic 
WHERE topiccode <=25.0 
)


, cteSubtopicList AS(
SELECT TopicFK 
, TopicName, TopicCode, SATCompareDateField, SATInterval, satname, DaysAfter
, SubTopicCode, SubTopicName, TrainingTickler, SubTopicPK 
FROM dbo.SubTopic 
inner join codeTopic t on t.codeTopicPK = SubTopic.TopicFK
WHERE TrainingTickler='YES'
)

, cteCompleteTopicList AS(
	SELECT * FROM cteTopicList 
	UNION
	select * from cteSubtopicList 
)

, cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent
	, SupervisorInitialStart, FAWInitialStart, FSWInitialStart --these are NOT Intitial Start Dates, the function was modified but the name stayed the same
	, FirstASQDate
	, TerminationDate
	FROM [dbo].[fnGetWorkerEventDatesAll](@progfk, NULL, NULL)
	WHERE (TerminationDate IS NULL OR TerminationDate >=
		CASE @workerfk
			WHEN NULL THEN GETDATE()
			ELSE 0
		END
		)
)


, cteWorkerList AS (
	SELECT workerpk, wrkrLName
	, WorkerName, cteEventDates.hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent, FirstASQDate
	--Need to find the workers FIRST Event (coalesce is required to deal with NULL date values)
	, CASE WHEN FirstKempeDate < COALESCE(FirstHomeVisitDate, DATEADD(dd, 1, FirstKempeDate)) AND FirstKempeDate < COALESCE(SupervisorFirstEvent, DATEADD(dd, 1, FirstKempeDate)) THEN FirstKempeDate
		   WHEN FirstHomeVisitDate < COALESCE(SupervisorFirstEvent, DATEADD(dd, 1, FirstHomeVisitDate)) THEN FirstHomeVisitDate
		ELSE SupervisorFirstEvent
		END AS FirstEvent
	, SupervisorInitialStart, FAWInitialStart, FSWInitialStart
	, cteEventDates.TerminationDate
	, SupervisorFK
	FROM cteEventDates 
	INNER JOIN workerprogram wp ON wp.WorkerFK = cteEventDates.workerpk AND wp.ProgramFK = @progfk
	WHERE CASE when @workerfk IS NULL AND cteEventDates.TerminationDate IS NULL then 1
			   when workerpk=@workerfk then 1
			   else 0 
			   end = 1
		AND supervisorfk = isnull(@supervisorfk,supervisorfk)
)


, cteEverythingRequired AS (
		SELECT workerpk, wrkrLName
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, satname, DaysAfter
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
		FROM cteWorkerList, cteCompleteTopicList 
		WHERE CASE WHEN FAWInitialStart IS NULL AND TopicCode = '9.0' THEN 0 -- Remove topic code 9 if not an FAW
			  WHEN FSWInitialStart IS NULL AND TopicCode = '8.0' THEN 0 -- Remove topic code 8 if not an FSW
			  WHEN SupervisorInitialStart IS NULL AND TopicCode = '9.1' THEN 0 --Remove topic code 9.1 if not a Supervisor
			ELSE 1
			END = 1
)

	
		
, cteReadyForRemoval AS (
		SELECT DISTINCT workerpk, wrkrLName
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, satname, DaysAfter
			, ER.TopicFK
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
			, (SELECT MIN(TrainingDate) FROM dbo.Training
					INNER JOIN TrainingAttendee ta ON dbo.Training.TrainingPK = ta.TrainingFK
					INNER JOIN TrainingDetail td ON ta.TrainingFK = td.TrainingFK
					WHERE TopicFK = er.TopicFK AND ta.WorkerFK=er.workerpk
								AND (case when er.SubTopicPK IS NULL then 1
								when td.SubTopicFK = ER.SubTopicPK then 1
								else 0 end = 1)
						
					) AS TrainingDate
			--, t.TrainingDate
		FROM cteEverythingRequired ER
		)
		
		
, cteFinal AS(		
	SELECT workerpk
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorFirstEvent
			, FirstEvent
			, FirstASQDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TerminationDate
			, SupervisorFK
			, TopicName
			, TopicCode
			, SATCompareDateField
			, SATInterval
			, satname, DaysAfter
			, TopicFK
			, SubTopicCode
			, SubTopicName
			, SubTopicPK
			, TrainingTickler
			, TrainingDate
			--, (SELECT TrainingDate FROM cteReadyForRemoval WHERE Topicfk = 10 AND workerpk=2124) AS testdate
			, CASE WHEN TopicCode<6.0 THEN '    Orientation (Prior to direct work with Families)'
				WHEN TopicCode<10.0 THEN '   NYS Training Requirements'
				WHEN TopicCode<13.0 THEN '  Intensive Role Specific Training'
				WHEN TopicCode<20.0 THEN ' Demonstrated Knowledge by 6 months Training'
				Else 'Demonstrated Knowledge by 12 months Training'
				END AS [theGrouping]
			, CASE  
					--HW997 Training Tickler and Required Topics - Remove Subtopic 82
					--WHEN SubTopicPK = 82 then
					----this first case determines if the initial FAW Core Training is taken, if not then it will simply add the text the training is due 3 months after, otherwise, it adds the 91 days
					--	CASE WHEN (SELECT distinct min(TrainingDate) FROM cteReadyForRemoval WHERE rfr.TopicFK = 10 AND workerpk=rfr.workerpk) IS NULL THEN 'FAW 3 month Follow-up Assessment Review'
					--	ELSE CONVERT(VARCHAR(10)
					--	, DATEADD(dd, 91, (select min(TrainingDate) FROM cteReadyForRemoval WHERE Topicfk = 10 AND workerpk=rfr.workerpk)), 101)
					--	END
					--END HW997
					WHEN SATCompareDateField = 'firstevent' THEN
						CASE WHEN FirstEvent IS NULL THEN 'First Event'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FirstEvent), 101)
						END
					WHEN SATCompareDateField = 'firstASQ' THEN
						CASE WHEN FirstASQDate IS NULL THEN 'First ASQ'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FirstASQDate), 101)
						END
					WHEN SATCompareDateField = 'date_hired' THEN
						CONVERT(VARCHAR(10), DATEADD(dd, daysafter, hiredate), 101)
					WHEN SATCompareDateField = 'faworig' THEN
						CASE WHEN FAWInitialStart IS NULL THEN 'FAW Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FAWInitialStart), 101)
						END
					WHEN SATCompareDateField = 'fsworig' THEN
						CASE WHEN FSWInitialStart IS NULL THEN 'FSW Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, FSWInitialStart), 101)
						END
					WHEN SATCompareDateField = 'suporig' THEN
						CASE WHEN SupervisorInitialStart IS NULL THEN 'Supervisor Start'
						ELSE CONVERT(VARCHAR(10), DATEADD(dd, daysafter, SupervisorInitialStart), 101)
						END
			  END AS [DateDue]
			, CASE  WHEN SATCompareDateField = 'firstevent' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'firstASQ' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'date_hired' THEN
						CASE WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'faworig' THEN
						CASE WHEN FAWInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'fsworig' THEN
						CASE WHEN FSWInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
					WHEN SATCompareDateField = 'suporig' THEN
						CASE WHEN SupervisorInitialStart IS NULL THEN 'Remove'
						WHEN TrainingDate IS NOT NULL THEN 'Remove' END
			  END AS 'Removals'
			FROM cteReadyForRemoval rfr
			)
			
			
		
SELECT workerpk
			, WorkerName
			, hiredate
			, FirstKempeDate
			, FirstHomeVisitDate
			, SupervisorInitialStart
			, FAWInitialStart
			, FSWInitialStart
			, TopicName
			, TopicCode
			, SubTopicCode
			, satname AS CSST
			, SubTopicName
			, TrainingDate
			, [theGrouping] AS [Grouping]
			, [DateDue]	
FROM ctefinal 
WHERE Removals IS NULL 
ORDER BY [theGrouping], TopicCode, SubTopicCode


END
GO
