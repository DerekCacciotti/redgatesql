SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[rspObservationBySupervisor]
(
    @StartDate DATETIME,
	@EndDate DATETIME,
	@ProgramFK VARCHAR(MAX),
	@SiteFK INT = NULL,
	@WorkerFK int = null
)
as
	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;


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
	WHERE((wp.FAWStartDate < @StartDate AND (wp.FAWEndDate IS NULL OR wp.FAWEndDate > @EndDate)) OR
		  (wp.FSWStartDate < @StartDate AND (wp.FSWEndDate IS NULL OR wp.FSWEndDate > @EndDate)) OR
		  (wp.ProgramManagerStartDate < @StartDate AND (wp.ProgramManagerEndDate IS NULL OR wp.ProgramManagerEndDate > @EndDate)) OR
		  (wp.SupervisorStartDate < @StartDate AND (wp.SupervisorEndDate IS NULL OR wp.SupervisorEndDate > @EndDate)))
		AND
		(wp.TerminationDate IS NULL OR wp.TerminationDate > @EndDate)
		AND WorkerPK = ISNULL(@WorkerFK, WorkerPK)
		AND FirstName <> 'Out of State'

	UPDATE @tblWorkers SET DisplayOrder = CASE WHEN WorkerType = 'FRS' THEN 1
											   WHEN WorkerType = 'FSS' THEN 2
											   WHEN WorkerType = 'Dual Role' THEN 3
											   WHEN WorkerType = 'Supervisor / Program Manager' THEN 4
										   END 

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
	WHERE KempeDate BETWEEN @StartDate AND @EndDate


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
	WHERE VisitStartTime BETWEEN @StartDate AND @EndDate


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
	SELECT tkip.HVCaseFK
		   ,tkip.PC1ID
           ,tkip.KempeDate
           ,tkip.FAWFK
		   ,0
		   ,ROW_NUMBER() OVER (PARTITION BY FAWFK, CONCAT(DATEPART(YEAR,tkip.KempeDate) ,DATEPART(MONTH, tkip.KempeDate)) ORDER BY FAWFK, tkip.KempeDate)
           FROM @tblKempesInPeriod tkip WHERE tkip.SupervisorObservation = 1

	UNION ALL
    
	SELECT thvip.HVCaseFK
	       ,thvip.PC1ID
           ,thvip.VisitStartTime
           ,thvip.FSWFK
           , 1
		   ,ROW_NUMBER() OVER (PARTITION BY FSWFK, CONCAT(DATEPART(YEAR,thvip.VisitStartTime) ,DATEPART(MONTH, thvip.VisitStartTime)) ORDER BY fswfk, thvip.VisitStartTime)
	FROM @tblHomeVisitsInPeriod thvip WHERE thvip.SupervisorObservation = 1


	UPDATE @tblWorkers SET FirstParentSurvey = kempes.firstParentSurvey
						 , LastParentSurvey = kempes.lastParentSurvey   FROM
    @tblWorkers tw INNER JOIN (SELECT MIN(kempedate) AS firstParentSurvey, MAX(KempeDate) AS lastParentSurvey, FAWFK FROM @tblKempesInPeriod GROUP BY FAWFK) AS kempes
	ON tw.WorkerPK = kempes.FAWFK
	
	UPDATE @tblWorkers SET FirstHomeVisit = hv.firstVisit
						  ,LastHomeVisit = hv.lastVisit FROM
	@tblWorkers tw INNER JOIN (SELECT MIN(VisitStartTime) AS firstVisit, MAX(VisitStartTime) AS lastVisit , FSWFK FROM @tblHomeVisitsInPeriod GROUP BY FSWFK) AS hv
	ON tw.WorkerPK = hv.FSWFK


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
           ,CASE 
			     WHEN oeip.Meets = 1 THEN 1 
				 WHEN oeip.Meets > 1  THEN 0
				 ELSE oeip.Meets
			END
		   FROM @tblWorkers tw
	left JOIN @tblObservedEventsInPeriod oeip ON tw.WorkerPK = oeip.WorkerFK
	WHERE  (tw.WorkerType = 'FRS' AND tw.FirstParentSurvey IS NOT NULL)
	    OR (tw.WorkerType = 'FSS' AND tw.FirstHomeVisit IS NOT NULL)
		OR (tw.WorkerType = 'Dual Role' AND tw.FirstHomeVisit IS NOT NULL AND tw.FirstParentSurvey IS NOT NULL)
		OR (tw.WorkerType = 'Supervisor / Program Manager' AND (tw.FirstHomeVisit IS NOT NULL OR tw.FirstParentSurvey IS NOT NULL))


	UPDATE @tblResults SET EligibleFRS = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'FRS')
	UPDATE @tblResults SET EligibleFSS = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'FSS')
	UPDATE @tblResults SET EligibleDual = (SELECT COUNT(DISTINCT WorkerPK) FROM @tblResults tr 
										  WHERE WorkerType = 'Dual Role')

	UPDATE @tblResults SET MeetsRequirementsFRS = (SELECT COUNT(DISTINCT sub.workerpk) FROM 
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'FRS' AND isHomeVisit = 0 
													 GROUP BY WorkerPK ) sub
													 WHERE sub.firstObs >= 2
													 ) 

	UPDATE @tblResults SET MeetsRequirementsFSS = (SELECT COUNT(DISTINCT sub.workerpk) FROM 
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'FSS' AND isHomeVisit = 1 
													 GROUP BY WorkerPK ) sub
													 WHERE sub.firstObs >= 4
													 ) 

	UPDATE @tblResults SET MeetsRequirementsDual =  (SELECT DISTINCT COUNT(PSObs.workerPK) From
												    (SELECT workerPK, SUM(FirstObservationOfMonth) AS firstPSObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'Dual Role' AND isHomeVisit = 0 
													 GROUP BY WorkerPK) PSObs												 
													 INNER JOIN 												
													(SELECT DISTINCT workerPK, SUM(FirstObservationOfMonth) AS firstHVObs
													 FROM @tblResults tr 
													 WHERE WorkerType = 'Dual Role' AND isHomeVisit = 1 
													 GROUP BY WorkerPK ) HVObs
													 ON PSobs.workerPK = HVobs.workerPK
													 WHERE PSObs.firstPSObs >= 1 AND HVObs.firstHVObs >=2)
													  
													 

	SELECT * FROM @tblResults tr 



GO
