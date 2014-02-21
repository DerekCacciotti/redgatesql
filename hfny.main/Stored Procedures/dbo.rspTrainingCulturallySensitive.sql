
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Report Training Culturally Sensitive
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainingCulturallySensitive]
	
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@progfk AS int
	
	with recompile
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--after timing out on 2/20/2014 added these new variables to deal with parameter sniffing slowdown issues
declare @sdate2 as datetime = @sdate
declare @edate2 as datetime = @edate
declare @progfk2 as int = @progfk


--Get FAW's in time period
;WITH  cteEventDates AS (
	SELECT workerpk, wrkrLName
	, '1' AS MyWrkrCount
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName
	, HireDate FROM [dbo].[fnGetWorkerEventDates](@progfk2, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND DATEDIFF(d,HireDate, @edate2) > 365
)


, cteCultureSensitive AS (
	select WorkerPK
	, WorkerName
	, HireDate
	, Mywrkrcount
	, MIN(TrainingDate) as CulturallySensitiveDate
	, CulturalCompetency
	, ROW_NUMBER() OVER ( PARTITION BY workerpk ORDER BY CulturalCompetency DESC ) AS 'RowNumber'
	From cteEventDates
	LEFT JOIN TrainingAttendee ta ON cteEventDates.WorkerPK = ta.WorkerFK 
	LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK
	LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
	LEFT join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
	WHERE --CulturalCompetency = 1
	TrainingDate between @sdate2 AND @edate2
	GROUP BY WorkerPK
	, CulturalCompetency
	, WorkerName
	, HireDate, MyWrkrCount
)

,  cteCultSenses as (
	select WorkerPK
	, WorkerName
	, HireDate
	, COUNT(workerpk) OVER (PARTITION BY MyWrkrCount) AS WorkerCount
	, CulturallySensitiveDate
	, CulturalCompetency
	from cteCultureSensitive
	where RowNumber=1
)


, cteCultSense AS (
	select WorkerPK
	, WorkerName
	, HireDate
	, WorkerCount
	, CulturallySensitiveDate
	, MIN(TrainingTitle) AS TrainingTitle
	, cteCultSenses.CulturalCompetency
	from cteCultSenses
	LEFT JOIN TrainingAttendee ta ON cteCultSenses.WorkerPK = ta.WorkerFK
	LEFT JOIN Training t on ta.TrainingFK = t.TrainingPK AND cteCultSenses.CulturallySensitiveDate = t.TrainingDate
	LEFT JOIN TrainingDetail td on td.TrainingFK=t.TrainingPK
	WHERE --CulturalCompetency = 1
	TrainingDate between @sdate2 AND @edate2
	GROUP BY WorkerPK
	, WorkerName
	, HireDate, WorkerCount
	, CulturallySensitiveDate
	, cteCultSenses.CulturalCompetency
)

, cteFinal as (
		SELECT WorkerPK, workername, HireDate
		, CASE 
				WHEN CulturalCompetency Is Null THEN NULL
				when CulturalCompetency = 0 then NULL
				ELSE CulturallySensitiveDate
			END AS CulturallySensitiveDate
		, WorkerCount
		, CASE 
				WHEN CulturalCompetency Is Null THEN ''
				when CulturalCompetency = 0 then ''
				ELSE TrainingTitle
			END AS TrainingTitle
		, MeetsTarget =
			CASE 
				WHEN CulturalCompetency Is Null THEN 'F'
				when CulturalCompetency = 0 then 'F'
				ELSE 'T'
			END
	From cteCultSense
 )
 
 --Now calculate the number meeting count, by currentrole
, cteCountMeeting AS (
		SELECT WorkerCount, count(*) AS totalmeetingcount
		FROM cteFinal
		WHERE MeetsTarget='T'
		GROUP BY WorkerCount
)

 SELECT cteFinal.workername, HireDate, CulturallySensitiveDate, MeetsTarget, cteFinal.workercount, totalmeetingcount, TrainingTitle
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) = 1 THEN '3' 
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) BETWEEN .9 AND .99 THEN '2'
	WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) < .9 THEN '1'
	END AS Rating
,	'NYS4. Those who visit families will have core training before visiting a family.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteFinal.workercount AS DECIMAL) AS PercentMeeting
FROM cteFinal
INNER JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount
ORDER BY cteFinal.workername

END
GO
