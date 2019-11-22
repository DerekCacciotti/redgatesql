SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 11/22/2019
-- Description:	BPS 12-2.B Supervisor Observation of Home Visits and Parent Surveys
-- =============================================
CREATE proc [dbo].[rspObservationBySupervisor]
(
    @StartDate DATETIME,
	@EndDate DATETIME,
	@ProgramFK VARCHAR(MAX),
	@SiteFK INT = NULL,
	@WorkerFK INT = NULL,
	@CaseFiltersPositive VARCHAR(100) = ''
)
AS
	IF @ProgramFK is null
	BEGIN
		SELECT @ProgramFK = substring((SELECT ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   FROM HVProgram
										   FOR XML PATH ('')),2,8000)
	END

	SET @ProgramFK = REPLACE(@ProgramFK,'"','')
	SET @SiteFK = CASE WHEN dbo.IsNullOrEmpty(@SiteFK) = 1 THEN 0 ELSE @SiteFK END;
	SET @CaseFiltersPositive = CASE WHEN @CaseFiltersPositive = '' THEN NULL
									ELSE @CaseFiltersPositive
							   END

	DECLARE @tblWorkers AS TABLE (
	WorkerPK INT
	,FirstName VARCHAR(MAX)
	,LastName VARCHAR(MAX)
	,WorkerType VARCHAR(32)
	,FirstParentSurvey DATETIME
	,LastParentSurvey DATETIME
	,FirstHomeVisit DATETIME
	,LastHomeVisit DATETIME
	,DisplayOrder INT
	)

	INSERT INTO	@tblWorkers
	(
	    WorkerPK,
	    FirstName,
	    LastName,
		WorkerType
	)

	SELECT WorkerPK
		,w.FirstName
		,w.LastName
		--label workers according to documentation
	    ,CASE WHEN
				FAWStartDate IS NOT NULL AND
				(FSWStartDate IS NULL OR FSWStartDate > @EndDate) AND (FSWEndDate IS NULL OR FSWEndDate < @StartDate) And
				(SupervisorStartDate IS NULL OR SupervisorStartDate > @EndDate) AND (SupervisorEndDate IS NULL OR SupervisorEndDate < @StartDate) AND
				(ProgramManagerStartDate IS NULL OR ProgramManagerStartDate > @EndDate) AND (ProgramManagerEndDate IS NULL OR ProgramManagerEndDate < @StartDate)
			THEN 'FRS'
			WHEN	
				FSWStartDate IS NOT NULL AND
				(FAWStartDate IS NULL OR FAWStartDate > @EndDate) AND (FAWEndDate IS NULL OR FAWEndDate < @StartDate) And
                (SupervisorStartDate IS NULL OR SupervisorStartDate > @EndDate) AND (SupervisorEndDate IS NULL OR SupervisorEndDate < @StartDate) AND
                (ProgramManagerStartDate IS NULL OR ProgramManagerStartDate > @EndDate) AND (ProgramManagerEndDate IS NULL OR ProgramManagerEndDate < @StartDate)
			THEN 'FSS'
			WHEN 
				FSWStartDate IS NOT NULL AND FAWStartDate IS NOT NULL AND	
                (SupervisorStartDate IS NULL OR SupervisorStartDate > @EndDate) AND (SupervisorEndDate IS NULL OR SupervisorEndDate < @StartDate) AND
                (ProgramManagerStartDate IS NULL OR ProgramManagerStartDate > @EndDate) AND (ProgramManagerEndDate IS NULL OR ProgramManagerEndDate < @StartDate)
			THEN 'Dual Role'
			WHEN 
				SupervisorStartDate IS NOT NULL OR 
				ProgramManagerStartDate IS NOT NULL OR
				SupervisorEndDate > @StartDate OR
				ProgramManagerEndDate > @StartDate
			THEN 'Supervisor / Program Manager'
		END				
	FROM Worker w INNER JOIN dbo.WorkerProgram wp ON w.WorkerPK = wp.WorkerFK
	inner join dbo.SplitString(@ProgramFK,',') on wp.programfk = ListItem

	--filter workers according to documentation
	WHERE((wp.FAWStartDate < @StartDate AND (wp.FAWEndDate IS NULL OR wp.FAWEndDate > @EndDate)) OR
		  (wp.FSWStartDate < @StartDate AND (wp.FSWEndDate IS NULL OR wp.FSWEndDate > @EndDate)) OR
		  (wp.ProgramManagerStartDate < @StartDate AND (wp.ProgramManagerEndDate IS NULL OR wp.ProgramManagerEndDate > @EndDate)) OR
		  (wp.SupervisorStartDate < @StartDate AND (wp.SupervisorEndDate IS NULL OR wp.SupervisorEndDate > @EndDate)))
		AND
		(wp.TerminationDate IS NULL OR wp.TerminationDate > @EndDate)
		AND WorkerPK = ISNULL(@WorkerFK, WorkerPK)
		AND FirstName <> 'Out of State'

	--set ordinal for display in report
	UPDATE @tblWorkers SET DisplayOrder = CASE WHEN WorkerType = 'FRS' THEN 1
											   WHEN WorkerType = 'FSS' THEN 2
											   WHEN WorkerType = 'Dual Role' THEN 3
											   WHEN WorkerType = 'Supervisor / Program Manager' THEN 4
										   END 

	--get all the parent surveys administered in the period
	DECLARE @tblKempesInPeriod AS TABLE (
		HVCaseFK INT
		,PC1ID CHAR(13)
		,KempeDate DATETIME
		,FAWFK INT
		,SupervisorObservation bit
	)

	INSERT INTO @tblKempesInPeriod
	(
	    HVCaseFK,
		PC1ID,
	    KempeDate,
	    FAWFK,
	    SupervisorObservation
	)

	SELECT k.HVCaseFK
		,PC1ID
	    ,KempeDate
	    ,FAWFK
		,SupervisorObservation 	
	FROM Kempe k
	INNER JOIN dbo.SplitString(@ProgramFK,',') on k.programfk = ListItem
	INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = k.HVCaseFK
	INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = k.HVCaseFK
	WHERE KempeDate BETWEEN @StartDate AND @EndDate


	--get all the home visits performed in the period
	DECLARE @tblHomeVisitsInPeriod AS TABLE (
		HVCaseFK INT
		,PC1ID CHAR(13)
		,VisitStartTime DATETIME
		,FSWFK INT
		,SupervisorObservation BIT
    )

	INSERT INTO @tblHomeVisitsInPeriod
	(
	    HVCaseFK,
		PC1ID,
	    VisitStartTime,
	    FSWFK,
	    SupervisorObservation
	)

	SELECT hv.HVCaseFK
		,PC1ID
		,VisitStartTime
		,FSWFK
		,SupervisorObservation
	FROM HVLog hv
	INNER JOIN dbo.SplitString(@ProgramFK,',') on hv.programfk = ListItem
	INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = hv.HVCaseFK
	INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = hv.HVCaseFK
	WHERE VisitStartTime BETWEEN @StartDate AND @EndDate

	--find the first and last parent survey conducted by each worker, observed or not.
	UPDATE @tblWorkers SET FirstParentSurvey = kempes.firstParentSurvey
						 , LastParentSurvey = kempes.lastParentSurvey   FROM
    @tblWorkers tw INNER JOIN (SELECT MIN(kempedate) AS firstParentSurvey, MAX(KempeDate) AS lastParentSurvey, FAWFK FROM @tblKempesInPeriod GROUP BY FAWFK) AS kempes
	ON tw.WorkerPK = kempes.FAWFK
	
	--find the first and last home visit conducted by each worker, observed or not.
	UPDATE @tblWorkers SET FirstHomeVisit = hv.firstVisit
						  ,LastHomeVisit = hv.lastVisit FROM
	@tblWorkers tw INNER JOIN (SELECT MIN(VisitStartTime) AS firstVisit, MAX(VisitStartTime) AS lastVisit , FSWFK FROM @tblHomeVisitsInPeriod GROUP BY FSWFK) AS hv
	ON tw.WorkerPK = hv.FSWFK

	--put all the observed parent surveys and home visits into one table
	DECLARE @tblObservedEventsInPeriod AS TABLE (
	HVCaseFK INT
	,PC1ID CHAR(13)
	,EventDate DATETIME
	,WorkerFK INT
	,isHomeVisit BIT
	,Meets INT
	)
	
	INSERT INTO @tblObservedEventsInPeriod
	(
	    HVCaseFK,
		PC1ID,
	    EventDate,
	    WorkerFK,
	    isHomeVisit,
	    Meets
	)
	--first the parent surveys. 
	--The partition groups by YYYY/MM, so row number of 1 meets the once a month requirement. row numbers > 1 are extra in the month and don't count.
	SELECT tkip.HVCaseFK
		   ,tkip.PC1ID
           ,tkip.KempeDate
           ,tkip.FAWFK
		   ,0
		   ,ROW_NUMBER() OVER (PARTITION BY FAWFK, CONCAT(DATEPART(YEAR,tkip.KempeDate) ,DATEPART(MONTH, tkip.KempeDate)) ORDER BY FAWFK, tkip.KempeDate)
           FROM @tblKempesInPeriod tkip WHERE tkip.SupervisorObservation = 1

	UNION ALL
    --next sort out the observed home visits same as above, partitioning by YYYY/MM.
	SELECT thvip.HVCaseFK
	       ,thvip.PC1ID
           ,thvip.VisitStartTime
           ,thvip.FSWFK
           , 1
		   ,ROW_NUMBER() OVER (PARTITION BY FSWFK, CONCAT(DATEPART(YEAR,thvip.VisitStartTime) ,DATEPART(MONTH, thvip.VisitStartTime)) ORDER BY fswfk, thvip.VisitStartTime)
	FROM @tblHomeVisitsInPeriod thvip WHERE thvip.SupervisorObservation = 1

	--bring the worker table together with the observed events.
	DECLARE @tblResults AS TABLE (
		WorkerPK INT,
		FirstName VARCHAR(MAX),
		LastName VARCHAR(MAX),
		FirstParentSurvey DATETIME,
		LastParentSurvey DATETIME,
		FirstHomeVisit DATETIME,
		LastHomeVisit DATETIME,
        WorkerType VARCHAR(32),
		DisplayOrder INT,
		PC1ID CHAR(13),
        EventDate DATETIME,
		isHomeVisit BIT,	
        FirstObservationOfMonth INT,
		EligibleFRS INT,
		EligibleFSS INT,
		EligibleDual INT,
		MeetsRequirementsFRS INT,
		MeetsRequirementsFSS INT,
		MeetsRequirementsDual INT  
	)
	INSERT INTO @tblResults
	(
	    WorkerPK,
	    FirstName,
	    LastName,
	    FirstParentSurvey,
	    LastParentSurvey,
	    FirstHomeVisit,
	    LastHomeVisit,
	    WorkerType,
		DisplayOrder,
	    PC1ID,
	    EventDate,
	    isHomeVisit,
	    FirstObservationOfMonth
	)

	SELECT tw.WorkerPK
           ,tw.FirstName
           ,tw.LastName
		   ,tw.FirstParentSurvey
		   ,tw.LastParentSurvey
		   ,tw.FirstHomeVisit
		   ,tw.LastHomeVisit
           ,tw.WorkerType
		   ,tw.DisplayOrder
		   ,oeip.PC1ID
           ,oeip.EventDate
           ,oeip.isHomeVisit
		   --convert the row number into a bit. Row = 1 meets, ie. first observation of month, Row > 1 does not meet
           ,CASE 
			     WHEN oeip.Meets = 1 THEN 1 
				 WHEN oeip.Meets > 1  THEN 0
				 ELSE oeip.Meets
			END
		   FROM @tblWorkers tw
	left JOIN @tblObservedEventsInPeriod oeip ON tw.WorkerPK = oeip.WorkerFK
	--only keep results where worker performed an event, observed or not.
	WHERE  (tw.WorkerType = 'FRS' AND tw.FirstParentSurvey IS NOT NULL)
	    OR (tw.WorkerType = 'FSS' AND tw.FirstHomeVisit IS NOT NULL)
		OR (tw.WorkerType = 'Dual Role' AND tw.FirstHomeVisit IS NOT NULL AND tw.FirstParentSurvey IS NOT NULL)
		OR (tw.WorkerType = 'Supervisor / Program Manager' AND (tw.FirstHomeVisit IS NOT NULL OR tw.FirstParentSurvey IS NOT NULL))

	--get counts of worker types. Eligible means you performed an event, so just count distinct according to worker type
	UPDATE @tblResults SET EligibleFRS = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'FRS')

	UPDATE @tblResults SET EligibleFSS = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'FSS')

	UPDATE @tblResults SET EligibleDual = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'Dual Role')

    --calculate meeting requirements by summing the first observed events of each month (row = 1 from the partition way back when)
	--if an frs has two observed parent surveys, they meet.
	UPDATE @tblResults SET MeetsRequirementsFRS = (SELECT COUNT(DISTINCT sub.workerpk) FROM 
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'FRS' AND isHomeVisit = 0 
													 GROUP BY WorkerPK ) sub
													 WHERE sub.firstObs >= 2
													 ) 

	--if an fss has four observed home visits, they meet.
	UPDATE @tblResults SET MeetsRequirementsFSS = (SELECT COUNT(DISTINCT sub.workerpk) FROM 
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'FSS' AND isHomeVisit = 1 
													 GROUP BY WorkerPK ) sub
													 WHERE sub.firstObs >= 4
													 ) 

    --dual workers need one parent survey observation and two home visit observations
	UPDATE @tblResults SET MeetsRequirementsDual =  (SELECT DISTINCT COUNT(PSObs.workerPK) FROM
													--sum the ps observations for dual rollers
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstPSObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'Dual Role' AND isHomeVisit = 0 
													 GROUP BY WorkerPK) PSObs												 
													 INNER JOIN 		
													 --join on summed hv observations for dualies										
													(SELECT DISTINCT workerPK, SUM(FirstObservationOfMonth) AS firstHVObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'Dual Role' AND isHomeVisit = 1 
													 GROUP BY WorkerPK ) HVObs
													 ON PSobs.workerPK = HVobs.workerPK
													 --meeting is one ps obs and 2 hv obs 
													 WHERE PSObs.firstPSObs >= 1 AND HVObs.firstHVObs >=2)
													  
	SELECT * FROM @tblResults tr

GO
