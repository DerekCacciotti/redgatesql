SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[rspBirthOutcomes] @startdate DATETIME, @enddate DATETIME, @sitefk INT, @programfk VARCHAR(200),
@WorkerFK INT,  @CaseFiltersPostive VARCHAR(100) AS





 --SET @programfk = '1'
 DECLARE @countoftcs INT = 0
 DECLARE @countofmultiples INT = 0
 IF @ProgramFK IS NULL
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @ProgramFK = replace(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK END

	SET @CaseFiltersPostive = CASE WHEN @CaseFiltersPostive = '' THEN NULL ELSE @CaseFiltersPostive end


	--SET @startdate = '1-1-18'
	--SET @enddate = '12-31-18'



-- cohort 
 DECLARE @tblallcases TABLE(
 Tcpk INT,
 PC1ID CHAR(13),
 Ocpk INT,
 ProgramFK INT,
 hvcasefk INT,
 tcdob DATETIME,
 ocdob DATETIME,
 conceptionDate DATETIME,
 intakedate DATETIME,
 hvlogpk INT,
 hvlogdate DATETIME,
 rownumber INT,
 ismultiple BIT,
 numofpc1sinperiod INT,
 numborninperiod INT,
 isrecevingprenatalcare CHAR(1),
 birthtermType varchar(MAX),
 birththweightType VARCHAR(max),
 numofocborninperiod INT,
 isocmultiple BIT, 
 toatalofocmutiples INT,
 OCBirthTermType VARCHAR(max),
 OCBirthWeightType VARCHAR(MAX),
 TrimesterTypeAtIntake VARCHAR(max),
 numoftcmultiples INT,
 numofpc1sthatrecivedprenatalcare INT,
 numoffulltermtcs INT,
 numofprematuretcs INT, 
 numofmissingbirthtermtcs INT,
 numofnormalbirthweight int,
 numoflowbirthweight INT,
 numofmissingbirthweight INT,
 numoffulltermocs INT,
numofprematureocs INT,
numofmissingbirthtermocs INT,
numofnormalocbirthweight int,
numoflowocbirthweight INT,
numofmissingocbirthweight INT,
numofpc1senrolledinFirstTrimester INT,
numofpc1senrolledinSecondTrimester INT,
numoftcbornenrolledatFirstTrimester INT,
numoftcbornenrolledatSecondTrimester INT,
numoftcmultiplesenrolledtFirstTrimester INT,
numoftcmultiplesenrolledtSecondTrimester INT,
numofpc1srecevingprenatalcareenrolledatFirstTrimester INT,
numofpc1srecevingprenatalcareenrolledatSecondTrimester INT,
numofFulltermtcsenrolledatFirstTrimester int,
numofprematuretcsenrolledatFirstTrimester INT, 
numofmissingbirthweightenrolledatFirstTrimester INT,
numofFulltermtcsenrolledatSecondTrimester int,
numofprematuretcsenrolledatSecondTrimester INT, 
numofmissingbirthweightenrolledatSceondTrimester INT,
numofnormalbirthweighttcsenrolledatFirstTrimester int,
numoflowbirthweighttcsenrolledatFirstTrimester INT,
numofmissingbirthweighttcsenrolledatFirstTrimester INT,
numofnormalbirthweighttcsenrolledatSecondTrimester int,
numoflowbirthweighttcsenrolledatSecondTrimester INT,
numofmissingbirthweighttcsenrolledatSecondTrimester INT, 
numofpc1senrolledinThirdTrimester INT,
numoftcbornenrolledintheThirdTrimester INT,
numofmultipletcbornintheThirdTrimester INT,
numofpc1sthatrecivedprenatalcareenrolledintheThirdTrimester INT,
numoffulltermtcsenrolledatThirdTrimester INT,
numofprematuretcsenrolledatThirdTrimester INT,
numofmissingbirthtermenrolledatThirdTrimester INT,
numofnormalbirthweighttcsenrolledatThirdTrimester INT,
numoflowbirthweighttcenrolledatThirdTrimester INT,
numofmissingbirthweightenrolledatThirdTrimester INT,
numofpc1enrolledpostnatally INT,
numoftcsbornenrolledpostnatally INT,
numofmultipletcsbornpostnatally INT,
numofpc1sreciveingprenatalcareenrolledpostnatally INT,
numoffulltermtcsenrolledpostnatally INT,
numofprematuretcsenrolledpostnatally INT,
numofmissingbirthTermtcsenrolledpostnatally INT,
numofnormalbrithweighttcsenrolledPostnatally INT,
numoflowbrithweighttcsenrolledPostnatally INT,
numofmissingbirthweighttcsenrolledPostnatally int
 )


 INSERT INTO @tblallcases
 (
     
     Tcpk,
	 PC1ID,
	 Ocpk,
     ProgramFK,
     hvcasefk,
     tcdob,
	 ocdob,
	 conceptionDate,
	 intakedate,
	 hvlogpk,
	 hvlogdate,
	 rownumber, 
	 ismultiple,
	 isrecevingprenatalcare,
	 birthtermType,
	 birththweightType,
	 isocmultiple,
	 OCBirthTermType,
	 OCBirthWeightType

	 
	 

	 
	 

 )



 SELECT tc.TCIDPK,cp.PC1ID, oc.OtherChildPK, tc.ProgramFK, tc.HVCaseFK, tc.TCDOB, oc.DOB, case when tc.TCDOB is null then dateadd(week, -40, hvc.EDC) 
						when tc.HVCaseFK is null and tc.TCDOB is not null
							then dateadd(week, -40, tc.TCDOB)
						when tc.HVCaseFK is not NULL and tc.TCDOB is not null 
							then dateadd(week, -40, dateadd(week, (40 - isnull(GestationalAge, 40)), tc.TCDOB) )
					END AS conceptiondate,
  hvc.IntakeDate, hvl.HVLogPK, hvl.VisitStartTime, ROW_NUMBER()
 OVER (PARTITION BY tc.TCIDPK, oc.OtherChildPK ORDER BY hvl.VisitStartTime DESC), tc.MultipleBirth, 
  commapp.ReceivingPreNatalCare,
 CASE WHEN tc.BirthTerm = 1 OR tc.GestationalAge  >= 37 THEN 'Full Term' WHEN tc.BirthTerm = 2 
												OR tc.GestationalAge < 37 THEN 'Premature' ELSE 'Missing Birth Term' END,

CASE WHEN tc.BirthWtLbs > 5 OR (tc.BirthWtLbs = 5 AND tc.BirthWtOz >= 8) THEN 'Normal' WHEN tc.BirthWtLbs < 5 OR 
(tc.BirthWtOz < 8) THEN 'Low' ELSE 'Missing' END, CASE WHEN oc.MultiBirth IS NULL THEN 0 ELSE oc.MultiBirth END,

CASE WHEN oc.BirthTerm = 1 OR oc.GestationalWeeks > 37 THEN 'Full Term'
 WHEN oc.BirthTerm = 2 OR oc.GestationalWeeks < 37 THEN 'Premature' ELSE 'Missing Birth Term' END,

 CASE WHEN oc.BirthWtLbs > 5 OR (oc.BirthWtLbs = 5 AND oc.BirthWtOz >= 8) THEN 'Normal'
 WHEN oc.BirthWtLbs < 5 OR (oc.BirthWtOz =5 AND oc.BirthWtOz < 8) THEN 'Low' ELSE 'Missing' END


 FROM dbo.TCID tc 
 INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = tc.HVCaseFK
 INNER JOIN dbo.OtherChild oc ON oc.HVCaseFK = tc.HVCaseFK 
 INNER JOIN dbo.HVCase hvc ON hvc.HVCasePK = tc.HVCaseFK 
 inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
inner join dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
INNER JOIN dbo.HVLog hvl ON hvl.HVCaseFK = tc.HVCaseFK AND hvl.VisitStartTime > hvc.TCDOB
INNER JOIN dbo.CommonAttributes commapp ON  commapp.FormFK = tc.TCIDPK AND commapp.FormType = 'TC'
-- get tcs born within the time period 
 WHERE tc.TCDOB BETWEEN @startdate AND @enddate
 -- might not need
  AND hvc.IntakeDate IS NOT NULL 
  AND hvc.IntakeDate <= @enddate
  AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= @startdate)



  AND cp.ProgramFK = @programfk
  	and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	AND cp.CurrentFSWFK = ISNULL(@WorkerFK,cp.CurrentFSWFK)

	UPDATE @tblallcases SET TrimesterTypeAtIntake = CASE WHEN intakedate >= tcdob THEN 'Postnatal' WHEN
	intakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) > round(30.44*6,0) THEN 'Third Trimester' WHEN
    intakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) between round(30.44*3,0)+1 and round(30.44*6,0) 
	THEN 'Second Trimester' WHEN intakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) < 3*30.44 
	THEN 'First Trimester' ELSE NULL END

	-- update the table with the counts 
	UPDATE @tblallcases SET numofpc1sinperiod = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases)
	UPDATE @tblallcases SET numborninperiod = (SELECT  COUNT( DISTINCT Tcpk) FROM @tblallcases)

	


	UPDATE @tblallcases SET numoftcmultiples = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE ismultiple = 1)

	UPDATE @tblallcases SET numofpc1sthatrecivedprenatalcare = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases 
	WHERE isrecevingprenatalcare = 1)


	UPDATE @tblallcases SET numoffulltermtcs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases 
	WHERE birthtermType = 'Full Term')

	UPDATE @tblallcases SET numofprematuretcs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases 
	WHERE birthtermType = 'Premature')

	UPDATE @tblallcases SET numofmissingbirthtermtcs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases 
	WHERE birthtermType = 'Missing Birth Term')



	UPDATE @tblallcases SET numofnormalbirthweight = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE birththweightType = 'Normal')

	
	UPDATE @tblallcases SET numoflowbirthweight = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE birththweightType = 'Low')

	
	UPDATE @tblallcases SET numofmissingbirthweight = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE birththweightType = 'Missing')

	UPDATE @tblallcases SET numofocborninperiod = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases 
	WHERE ocdob BETWEEN @startdate AND @enddate)

	UPDATE @tblallcases SET toatalofocmutiples = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases 
	WHERE isocmultiple = 1 AND ocdob BETWEEN @startdate AND @enddate)


	UPDATE @tblallcases SET numoffulltermocs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases
	WHERE OCBirthTermType = 'Full Term' AND ocdob BETWEEN @startdate AND @enddate)

	UPDATE @tblallcases SET numofprematureocs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases
	WHERE OCBirthTermType = 'Premature' AND ocdob BETWEEN @startdate AND @enddate)

	UPDATE @tblallcases SET numofmissingbirthtermocs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases
	WHERE OCBirthTermType = 'Missing Birth Term' AND ocdob BETWEEN @startdate AND @enddate)


	UPDATE @tblallcases SET numofnormalocbirthweight = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases 
	WHERE OCBirthWeightType = 'Normal' AND ocdob BETWEEN @startdate AND @enddate)


	UPDATE @tblallcases SET numoflowocbirthweight = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases 
	WHERE OCBirthWeightType = 'Low' AND ocdob BETWEEN @startdate AND @enddate)

	UPDATE @tblallcases SET numofmissingocbirthweight = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases 
	WHERE OCBirthWeightType = 'Missing' AND ocdob BETWEEN @startdate AND @enddate)



	UPDATE @tblallcases SET numofpc1senrolledinFirstTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester')

	UPDATE @tblallcases SET numofpc1senrolledinSecondTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases 
	WHERE TrimesterTypeAtIntake = 'Second Trimester')


	UPDATE @tblallcases SET numoftcbornenrolledatFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester')
	UPDATE @tblallcases SET numoftcbornenrolledatSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester')

	UPDATE @tblallcases SET numoftcmultiplesenrolledtFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND ismultiple = 1)

	UPDATE @tblallcases SET numoftcmultiplesenrolledtSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND ismultiple = 1)


	UPDATE @tblallcases SET numofpc1srecevingprenatalcareenrolledatFirstTrimester = (SELECT COUNT( DISTINCT PC1ID) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND isrecevingprenatalcare = 1 )


	UPDATE @tblallcases SET numofpc1srecevingprenatalcareenrolledatSecondTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND isrecevingprenatalcare = 1)


	
	UPDATE @tblallcases SET numofFulltermtcsenrolledatFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birthtermType = 'Full Term')


		UPDATE @tblallcases SET numofprematuretcsenrolledatFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birthtermType = 'Premature')


		UPDATE @tblallcases SET numofmissingbirthweightenrolledatFirstTrimester = 
		(SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birthtermType = 'Missing Birth Term')






	UPDATE @tblallcases SET numofFulltermtcsenrolledatSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND birthtermType = 'Full Term')


		UPDATE @tblallcases SET numofprematuretcsenrolledatSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND birthtermType = 'Premature')


		UPDATE @tblallcases SET numofmissingbirthweightenrolledatSceondTrimester = 
		(SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND birthtermType = 'Missing Birth Term')


	UPDATE @tblallcases SET numofnormalbirthweighttcsenrolledatFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birththweightType = 'Normal')


	UPDATE @tblallcases SET numoflowbirthweighttcsenrolledatFirstTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birththweightType = 'Low')


	UPDATE @tblallcases SET numofmissingbirthweighttcsenrolledatFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'First Trimester' AND birththweightType = 'Missing')


	UPDATE @tblallcases SET numofnormalbirthweighttcsenrolledatSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Secomd Trimester' AND birththweightType = 'Normal')


	UPDATE @tblallcases SET numoflowbirthweighttcsenrolledatSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND birththweightType = 'Low')


	UPDATE @tblallcases SET numofmissingbirthweighttcsenrolledatSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Second Trimester' AND birththweightType = 'Missing')


	UPDATE @tblallcases SET numofpc1senrolledinThirdTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester')


	UPDATE @tblallcases SET numoftcbornenrolledintheThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester')

	UPDATE @tblallcases SET numofmultipletcbornintheThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND ismultiple = 1)

	UPDATE @tblallcases SET numofpc1sthatrecivedprenatalcareenrolledintheThirdTrimester = (SELECT COUNT(DISTINCT PC1ID)
	FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester' AND isrecevingprenatalcare = 1)


	UPDATE @tblallcases SET numoffulltermtcsenrolledatThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birthtermType = 'Full Term')

	UPDATE @tblallcases SET numofprematuretcsenrolledatThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birthtermType = 'Premature')

	UPDATE @tblallcases SET numofmissingbirthtermenrolledatThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birthtermType = 'Missing Birth Term')

	UPDATE @tblallcases SET numofnormalbirthweighttcsenrolledatThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birththweightType = 'Normal')

	UPDATE @tblallcases SET numoflowbirthweighttcenrolledatThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birththweightType = 'Low')


	UPDATE @tblallcases SET numofmissingbirthweightenrolledatThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Third Trimester' AND birththweightType = 'Missing')

	UPDATE @tblallcases SET numofpc1enrolledpostnatally = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal')

	

	UPDATE @tblallcases SET numoftcsbornenrolledpostnatally  = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal')


	UPDATE @tblallcases SET numofmultipletcsbornpostnatally = (SELECT COUNT(DISTINCT tcpk ) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND ismultiple = 1)


	UPDATE @tblallcases SET numofpc1sreciveingprenatalcareenrolledpostnatally = (SELECT COUNT(DISTINCT PC1ID) 
	FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal' AND isrecevingprenatalcare = 1)

	UPDATE @tblallcases SET numoffulltermtcsenrolledpostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases 
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birthtermType = 'Full Term')


	UPDATE @tblallcases SET numofprematuretcsenrolledpostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases 
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birthtermType = 'Premature')


	UPDATE @tblallcases SET numofmissingbirthTermtcsenrolledpostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birthtermType = 'Missing Birth Term')


	UPDATE @tblallcases SET numofnormalbrithweighttcsenrolledPostnatally = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birththweightType = 'Normal')


	UPDATE @tblallcases SET numoflowbrithweighttcsenrolledPostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birththweightType = 'Low')


	UPDATE @tblallcases SET numofmissingbirthweighttcsenrolledPostnatally = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases
	WHERE TrimesterTypeAtIntake = 'Postnatal' AND birththweightType = 'Missing')



















	










	--UPDATE @tblallcases SET numoffulltermtcsinfirstandsecondTrim

	 -- select everything with the row number of 1 to ge the latest data
	SELECT * FROM @tblallcases WHERE rownumber = 1


	--SELECT * FROM @tblallcases WHERE ocdob BETWEEN @startdate AND @enddate AND rownumber = 1
GO
