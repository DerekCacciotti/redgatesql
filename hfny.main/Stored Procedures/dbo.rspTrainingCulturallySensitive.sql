SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Report Training Culturally Sensitive
-- Edited by Benjamin Simmons
-- Edit Date: 8/17/17
-- Edit Reason: Optimized stored procedure so that it works better on Azure
-- =============================================
CREATE procedure [dbo].[rspTrainingCulturallySensitive]
	
	-- Add the parameters for the stored procedure here
	@sdate AS DATETIME,
	@edate AS DATETIME,
	@progfk AS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--after timing out on 2/20/2014 added these new variables to deal with parameter sniffing slowdown issues
declare @sdate2 as datetime = @sdate
declare @edate2 as datetime = @edate
declare @progfk2 as int = @progfk

if object_id('tempdb..#cteEventDates') is not null drop table #cteEventDates
create table #cteEventDates (
	workerpk int
	, wrkrLName char(30)
	, MyWrkrCount char(1)
	, WorkerName varchar(60)
	, HireDate datetime
)

--Get FAW's in time period

--Get FAW's in time period
insert into #cteEventDates
	SELECT workerpk, wrkrLName
	, '1' AS MyWrkrCount
	, rtrim(wrkrFname) + ' ' + rtrim(wrkrLName) as WorkerName
	, HireDate FROM [dbo].[fnGetWorkerEventDatesALL](@progfk2, NULL, NULL)
	WHERE TerminationDate IS NULL
	AND (FSWInitialStart IS NOT NULL OR FAWInitialStart IS NOT NULL OR SupervisorInitialStart IS NOT NULL OR ProgramManagerStartDate IS NOT Null)
	AND DATEDIFF(d,HireDate, @edate2) > 365

;with cteCultureSensitive as (
	select WorkerPK
	, WorkerName
	, HireDate
	, Mywrkrcount
	, min(TrainingDate) as CulturallySensitiveDate
	, CulturalCompetency
	, row_number() over ( partition by workerpk order by CulturalCompetency desc ) as 'RowNumber'
	, TrainingPK
	from #cteEventDates
	left join TrainingAttendee ta on #cteEventDates.WorkerPK = ta.WorkerFK 
	left join Training t on ta.TrainingFK = t.TrainingPK
	left join TrainingDetail td on td.TrainingFK=t.TrainingPK
	left join codeTopic cdT on cdT.codeTopicPK=td.TopicFK
	where --CulturalCompetency = 1
	TrainingDate between @sdate2 and @edate2
	group by WorkerPK
	, CulturalCompetency
	, WorkerName
	, HireDate, MyWrkrCount, TrainingPK
)

, cteWorkerCount as (
	select WorkerPK
	, count(WorkerPK) over (partition by MyWrkrCount) as WorkerCount
	from #cteEventDates
	)

,  cteCultSenses as (
	select WorkerPK
	, WorkerName
	, HireDate
	, count(workerpk) over (partition by MyWrkrCount) as WorkerCount
	, CulturallySensitiveDate
	, CulturalCompetency
	, TrainingPK
	from cteCultureSensitive
	where RowNumber=1
)


, cteCultSense2 as (
	select cteCultSenses.WorkerPK
	, WorkerName
	, HireDate
	, CulturallySensitiveDate
	, min(TrainingTitle) as TrainingTitle
	, cteCultSenses.CulturalCompetency
	, cteCultSenses.TrainingPK
	from cteCultSenses
	left join TrainingAttendee ta on cteCultSenses.WorkerPK = ta.WorkerFK
	left join Training t on ta.TrainingFK = t.TrainingPK and cteCultSenses.TrainingPK = t.TrainingPK
	left join TrainingDetail td on td.TrainingFK=t.TrainingPK
	where --CulturalCompetency = 1
	TrainingDate between @sdate2 and @edate2
	group by cteCultSenses.WorkerPK
	, WorkerName
	, HireDate
	, CulturallySensitiveDate
	, cteCultSenses.CulturalCompetency
	, cteCultSenses.TrainingPK
)


, cteCultSense as (
  
	select #cteEventDates.WorkerPK
	, #cteEventDates.WorkerName
	, #cteEventDates.HireDate
	, CulturallySensitiveDate
	, TrainingTitle
	, CulturalCompetency
	, TrainingPK
	from #cteEventDates
	LEFT JOIN  cteCultSense2 ON #cteEventDates.WorkerPK = cteCultSense2.WorkerPK	
)


, cteFinal as (
		SELECT WorkerPK, workername, HireDate
		, CASE 
				WHEN CulturalCompetency Is Null THEN NULL
				when CulturalCompetency = 0 then NULL
				ELSE CulturallySensitiveDate
			END AS CulturallySensitiveDate
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
		INNER JOIN cteWorkerCount wc ON wc.WorkerPK = cteFinal.WorkerPK
		WHERE MeetsTarget='T'
		GROUP BY ALL WorkerCount
)

 SELECT cteFinal.workername, HireDate, CulturallySensitiveDate, MeetsTarget, cteCountMeeting.workercount, totalmeetingcount, TrainingTitle
 ,  CASE WHEN cast(totalmeetingcount AS DECIMAL) / cast(cteCountMeeting.workercount AS DECIMAL) = 1 THEN '3' 
	ELSE '1' --New standards, everyone needs it or you get a 1 rating
	END AS Rating
,	'5.3 - All Staff receive training related to the unique characteristics of the service population at least annually.' AS CSST
, cast(totalmeetingcount AS DECIMAL) / cast(cteCountMeeting.workercount AS DECIMAL) AS PercentMeeting
FROM cteFinal, cteCountMeeting
--LEFT JOIN cteCountMeeting ON cteCountMeeting.WorkerCount = cteFinal.WorkerCount

drop table #cteEventDates
END

GO
