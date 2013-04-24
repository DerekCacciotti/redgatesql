SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 04/15/2013
-- Description:	Training [NYS 3 IFSP] New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTraining_NYS3IFSP]
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
;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName, hiredate
	, FirstKempeDate, FirstHomeVisitDate, SupervisorFirstEvent FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
)



, cteFAW as (
	Select workerpk, wrkrLName, WorkerName
	, FirstKempeDate as FirstEventDate
	, '1' AS WorkerCounter
	FROM cteEventDates
	WHERE FirstKempeDate >= @sdate
)

, cteFSW as (
	Select workerpk, wrkrLName, WorkerName
	, FirstHomeVisitDate as FirstEventDate
	, '1' AS WorkerCounter
	FROM cteEventDates
	WHERE FirstHomeVisitDate >= @sdate
)

, cteSups as (
	Select workerpk, wrkrLName, WorkerName
	, SupervisorFirstEvent as FirstEventDate
	, '1' AS WorkerCounter
	FROM cteEventDates
	WHERE SupervisorFirstEvent >= @sdate 
)

--because this report is to get IFSP training 3 months after hire to any HFNY position, only get ONE worker per report (get first hire position date)
, ctePutWorkersTogether1 as (
		Select distinct workerpk, wrkrLName, WorkerName, workercounter, FirstEventDate FROM cteFAW
		UNION
		Select distinct workerpk, wrkrLName, WorkerName, workercounter, FirstEventDate FROM cteFSW
		UNION
		Select distinct workerpk, wrkrLName, WorkerName,  workercounter, FirstEventDate FROM cteSups
)

, ctePutWorkersTogether2 AS (
	SELECT DISTINCT workerpk, wrkrLName, WorkerName, workercounter, min(FirstEventDate) AS FirstEventDate
	FROM ctePutWorkersTogether1
	GROUP BY workerpk, wrkrLName, WorkerName, workercounter
)

, ctePutWorkersTogether3 AS (
	--this is where we count the total workers
	SELECT count(workercounter) AS workercount FROM ctePutWorkersTogether2
	GROUP BY WorkerCounter
	)


, cteGetShadowDate AS (
		select WorkerPK, WrkrLName, WorkerName
		, FirstEventDate, workercount
		, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where (TopicCode = 7.0 and ta.WorkerFK=ctePutWorkersTogether2.WorkerPK)
									)
			AS FirstIFSPDate
		 from ctePutWorkersTogether2, ctePutWorkersTogether3
)

, cteFinal as (
	SELECT WorkerPK, workername, firsteventdate, FirstIFSPDate, workercount
		,CASE WHEN FirstIFSPDate Is Null THEN 'F'
		WHEN dateadd(dd, 91, FirstEventDate) > FirstIFSPDate THEN 'T'
		ELSE 'T' END AS MeetsTarget
		, '1' AS GenericColumn --used for next cte cteCountMeeting
	From cteGetShadowDate
 )
 
 
--Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT GenericColumn, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY GenericColumn
)

 SELECT cteFinal.workername, firsteventdate, FirstIFSPDate, MeetsTarget, workercount, totalmeetingcount
 ,  CASE WHEN totalmeetingcount/workercount = 1 THEN '3' 
	WHEN totalmeetingcount/workercount BETWEEN .9 AND .99 THEN '2'
	WHEN totalmeetingcount/workercount < .9 THEN '1'
	END AS Rating
,	'NYS3. Staff (Supervisors and Homve Visitors) receive IFSP training within three months of hire to a HFNY position.' AS CSST
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.GenericColumn = cteFinal.GenericColumn
ORDER BY cteFinal.workername


END
GO
