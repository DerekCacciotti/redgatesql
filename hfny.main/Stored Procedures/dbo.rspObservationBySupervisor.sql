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
	,PerformedHomeVisit BIT
	,PerformedParentSurvey BIT
	,FirstParentSurvey DATETIME
	,LastParentSurvey DATETIME
	,FirstHomeVisit DATETIME
	,LastHomeVisit DATETIME
	,ProgramManagerStartDate DATETIME
	,ProgramManagerEndDate DATETIME
	,SupervisorStartDate DATETIME
	,SupervisorEndDate DATETIME
	,DisplayOrder INT
	)

	INSERT INTO	@tblWorkers
	(
	    WorkerPK,
	    FirstName,
	    LastName,
		ProgramManagerStartDate,
		ProgramManagerEndDate,
		SupervisorStartDate,
		SupervisorEndDate
	)

	SELECT 
		WorkerPK,
		w.FirstName,
		w.LastName,
		wp.ProgramManagerStartDate,
		wp.ProgramManagerEndDate,
		wp.SupervisorStartDate,
		wp.SupervisorEndDate			
	FROM Worker w INNER JOIN dbo.WorkerProgram wp ON w.WorkerPK = wp.WorkerFK
	INNER JOIN dbo.SplitString(@ProgramFK,',') on wp.programfk = ListItem
	WHERE
		(wp.TerminationDate IS NULL OR wp.TerminationDate > @EndDate)
		AND WorkerPK = ISNULL(@WorkerFK, WorkerPK)
		AND FirstName not in ( 'Out of State', 'In State')
		AND (
			(FAWStartDate < @EndDate and (FAWEndDate is null or FAWEndDate > @EndDate))
			or
			(FSWStartDate < @EndDate and (FSWEndDate is null or FSWEndDate > @EndDate))
			or
			(SupervisorStartDate < @EndDate and (SupervisorEndDate is null or SupervisorEndDate > @EndDate))
			or
			(ProgramManagerStartDate < @EndDate and (ProgramManagerEndDate is null or ProgramManagerEndDate > @EndDate))
			)
		
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
    @tblWorkers tw INNER JOIN (SELECT MIN(kempedate) AS firstParentSurvey, MAX(KempeDate) AS lastParentSurvey, FAWFK FROM Kempe GROUP BY FAWFK) AS kempes
	ON tw.WorkerPK = kempes.FAWFK
	
	--find the first and last home visit conducted by each worker, observed or not.
	UPDATE @tblWorkers SET FirstHomeVisit = hv.firstVisit
						  ,LastHomeVisit = hv.lastVisit FROM
	@tblWorkers tw INNER JOIN (SELECT MIN(VisitStartTime) AS firstVisit, MAX(VisitStartTime) AS lastVisit , FSWFK FROM HVLog GROUP BY FSWFK) AS hv
	ON tw.WorkerPK = hv.FSWFK

	--figure out whether or not they performed an event
	UPDATE @tblWorkers 
	Set PerformedHomeVisit = 1 
	FROM @tblWorkers tw	INNER JOIN @tblHomeVisitsInPeriod thvp on tw.WorkerPK = thvp.FSWFK

	UPDATE @tblWorkers 
	Set PerformedParentSurvey = 1 
	FROM @tblWorkers tw	INNER JOIN @tblKempesInPeriod tkip on tw.WorkerPK = tkip.FAWFK

	--figure out worker type based on sup/pm dates and whether or not they performed an event
	UPDATE @tblWorkers
	Set WorkerType = 
		CASE WHEN (SupervisorStartDate is null or SupervisorEndDate < @StartDate) and (ProgramManagerStartDate is null or ProgramManagerEndDate < @StartDate) 
				THEN 
					CASE WHEN PerformedHomeVisit = 1 and PerformedParentSurvey = 1 THEN 'Dual Role'
						 WHEN PerformedHomeVisit = 1 and PerformedParentSurvey IS NULL THEN 'FSS'
						 WHEN PerformedHomeVisit IS NULL and PerformedParentSurvey = 1 THEN 'FRS'
						 
				    END
			 ELSE 'Supervisor / Program Manager'
		END

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
		MeetsRequirementsDual INT,
		ProgramManagerStartDate DATETIME,
		ProgramManagerEndDate DATETIME,
		SupervisorStartDate DATETIME,
		SupervisorEndDate DATETIME  
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
	    FirstObservationOfMonth,
		ProgramManagerStartDate,
		ProgramManagerEndDate,
		SupervisorStartDate,
		SupervisorEndDate
	)

	SELECT 
		tw.WorkerPK,
        tw.FirstName,
        tw.LastName,
		tw.FirstParentSurvey,
		tw.LastParentSurvey,
		tw.FirstHomeVisit,
		tw.LastHomeVisit,
		tw.WorkerType,
		tw.DisplayOrder,		
		oeip.PC1ID,
		oeip.EventDate,
		oeip.isHomeVisit,
		--convert the row number into a bit. Row = 1 meets, ie. first observation of month, Row > 1 does not meet
        CASE 
		     WHEN oeip.Meets = 1 THEN 1 
			 WHEN oeip.Meets > 1  THEN 0
			 ELSE oeip.Meets
		END,
		tw.ProgramManagerStartDate,
		tw.ProgramManagerEndDate,
		tw.SupervisorStartDate,
		tw.SupervisorEndDate
		FROM @tblWorkers tw
		left JOIN @tblObservedEventsInPeriod oeip ON tw.WorkerPK = oeip.WorkerFK
		WHERE (tw.PerformedHomeVisit is not null or tw.PerformedParentSurvey is not null)

	--determine worker types based on whether or not they performed an event in the time period and if they have a supervisor/manager dates
	
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
	
		--set ordinal for display in report
	UPDATE @tblResults SET DisplayOrder = CASE WHEN WorkerType = 'FRS' THEN 1
											   WHEN WorkerType = 'FSS' THEN 2
											   WHEN WorkerType = 'Dual Role' THEN 3
											   WHEN WorkerType = 'Supervisor / Program Manager' THEN 4
										   END
										    												  
	SELECT * FROM @tblResults tr 
 



GO
