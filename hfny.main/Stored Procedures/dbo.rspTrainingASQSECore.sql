SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 07/08/2019
-- Description:	ASQSE Training Data : New York State Required Trainings
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingASQSECore]
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@progfk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	;WITH  cteEventDate AS (
	SELECT workerpk, wrkrLName
	, '1' AS MyWrkrCount
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName
	, FirstASQSEDate FROM [dbo].[fnGetWorkerEventDates](@progfk, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND (FirstASQSEDate > @sdate AND FirstASQSEDate >= '02/01/2019') --this training did NOT go into effect until this date. 
		--As per conversation with CNoble, only pull workers completing an ASQ SE after the date this training went into effect
	AND FirstASQSEDate IS NOT null
)

, cteEventDates AS (
	SELECT WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstASQSEDate
	, min(PC1ID) AS PC1ID
	 FROM cteEventDate
	 INNER JOIN ASQSE a ON a.FSWFK=WorkerPK
	 INNER JOIN CaseProgram cp ON cp.HVCaseFK=a.HVCaseFK
	 WHERE a.ASQSEDateCompleted = FirstASQSEDate AND a.FSWFK=WorkerPK
	 GROUP BY WorkerPK
	, wrkrLName
	, MyWrkrCount
	, WorkerName
	, FirstASQSEDate
)

, cteASQSECore AS (
	select WorkerPK, WorkerName
	, FirstASQSEDate
	, PC1ID
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, (Select MIN(trainingdate) as TrainingDate 
									from TrainingAttendee ta
									LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
									LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
									LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
									where TopicCode = 13.1 AND ta.WorkerFK=workerpk
									)
		AS ASQSECoreDate
	from cteEventDates
	GROUP BY WorkerPK, WorkerName, FirstASQSEDate, MyWrkrCount, PC1ID
)


, cteFinal as (
	SELECT WorkerPK, workername, FirstASQSEDate, ASQSECoreDate, WorkerCount, PC1ID
		, MeetsTarget =
			CASE 
				WHEN ASQSECoreDate Is Null THEN 'F'
				WHEN ASQSECoreDate > FirstASQSEDate THEN 'F'
				ELSE 'T'
			END
	From cteASQSECore
 )

 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, FirstASQSEDate, ASQSECoreDate, MeetsTarget, cteFinal.workercount, ISNULL(totalmeetingcount,0)
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .9 THEN '1'
	WHEN cteCountMeeting.totalmeetingcount IS NULL THEN '1'
	END AS Rating
,	'6-5.E Those who administer developmental screenings have been trained in the use of the tool before administering it.' AS CSST
, cast(ISNULL(totalmeetingcount, 0) AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
, PC1ID
FROM cteFinal
LEFT JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername
END
GO
