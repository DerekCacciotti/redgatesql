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
 NumofTCMultiples INT,
 Numofpc1sReceivingPrenatalCare INT,
 NumofFullTermTCs INT,
 NumofPreMatureTCs INT,
 NumOfMissingBirthTermTCs INT,

 NumOfNormalBirthWeightTCs INT,
 NumOfLowBirthWeightTCs INT,
 NumofMissingBirthWeightTCs INT,

 NumofFullTermOCs INT,
 NumofPrematureOCs INT, 

 NumofMissingBirthTermOCs INT, 
 NumofNormalBirthWeightOCs INT,
 NumofLowBirthWeightOCs INT,
 NumofMissingBirthWeightOCs INT,

 NumOfPC1sEnrolledinFirstTrimester INT,
 NumofPC1sEnrollledinSecondTrimester INT,


 NumOfTCsBorninFirstTrimester INT,
 NumofTCsBorninSecondTrimester INT,


 NumOfTCMutiplesEnrolledinFirstTrimester INT,
 NumOfTCMultiplesEnrolledinSecondTrimester INT, 

 NumofPC1sReceivingPrenatalCareinFirstTrimester INT,
 NumofPC1sReceivingPrenatalCareinSecondTrimester INT,


 NumOfFullTermTCsEnrolledInFirstTrimester INT,
 NumofFullTermTCsEnrolledinSecondTrimester INT,
 NumOfPrematureTCsEnrolledinSecondTrimester INT,
 NumofPrematureTCsEnrolledinFirstTrimester INT,

 NumofMissingBirthTermTCsEnrolledinFirstTrimester INT,
 NumofMissingBirthTermTCEnrolledinSecondTrimester INT,

 NumofNormalBirthWeightTCsEnrolledinFirstTrimester INT,

 NumofNormalBirthWeightTCsEnrolledinSecondTrimester INT,


 NumofLowBirthWeightTCsEnrolledinFirstTrimester INT,
 NumofLowBirthWeigtTCsEnrolledinSecondTriemester INT,

 NumofMissingBirthWeightTCsEnrolledinFirstTrimester INT,
 NumofMissingBirthWeightTCsEnrolledinSecondTrimester INT,


 NumofPC1senrolledintheThirdTrimester INT,
 NumofTCsBornEnrolledintheThirdTrimester INT, 
 NumofTCMultiplesEnrolledintheThirdTrimester INT,
 NumofPC1swhorecivedprenatalcareintheThirdTriemester INT,


 NumofFullTermTCsEnrolledintheThirdTrimester INT,
 NumofPrematureTCsEnrolledintheThirdTrimester INT,
 NumofMissingBirthTermTCsEnrolledintheThirdTrimester INT,


 NumofNormalBirthWeightEnrolledinThridTrimiester INT,
 NumofLowBirthWeightEnrolledinThirdTrimester INT,
 NumofMissingBirthWeightEnrolledintheThirdTrimester INT,


 NumofPC1sEnrolledPostnatally INT,
 NumofTCsBornEnrolledPostnatally INT,
 NumofTCMultipleBornPostNatally INT,
 NumofPC1sReceivingPrenatalCareEnrolledPostNatally INT,


 NumofFullTermTCsBornEnrolledPostnatally INT,
 NumofPreMatureTcsBornEnrolledPostnatally INT,
 NumofMissingBirthTermPostnatally INT,

 NumofNormalBirthWeightTcsBornPostNatally INT,
 NumofLowBirthWeightTcsBornPostNatally INT,
 NumofMissingBirthWeightTcsBornPostNatally INT
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
 LEFT OUTER JOIN dbo.OtherChild oc ON oc.HVCaseFK = tc.HVCaseFK 
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

	--TC
	UPDATE @tblallcases SET numofpc1sinperiod = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases)
	UPDATE @tblallcases SET numborninperiod = (SELECT COUNT(DISTINCT Tcpk) FROM  @tblallcases)
	UPDATE @tblallcases SET NumofTCMultiples =  (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE ismultiple = 1)
	UPDATE @tblallcases SET Numofpc1sReceivingPrenatalCare = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE isrecevingprenatalcare = 1)
	
	-- TC Birth Term
	UPDATE  @tblallcases SET NumofFullTermTCs =  (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE birthtermType = 'Full Term')
	UPDATE @tblallcases SET NumofPreMatureTCs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE birthtermType = 'Premature')
	UPDATE @tblallcases SET NumOfMissingBirthTermTCs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE birthtermType = 'Missing Birth Term')


	-- TC Birth Weight 


		UPDATE @tblallcases SET NumOfNormalBirthWeightTCs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE birththweightType = 'Normal')
		UPDATE @tblallcases SET NumOfLowBirthWeightTCs = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE birththweightType = 'Low')
		UPDATE @tblallcases SET NumofMissingBirthWeightTCs = (SELECT COUNT(DISTINCT Tcpk) FROM  @tblallcases WHERE birththweightType = 'Missing')

		-- OC

		UPDATE @tblallcases SET numofocborninperiod = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases)
		UPDATE @tblallcases SET toatalofocmutiples = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases WHERE isocmultiple = 1)

		--oc birth term

		UPDATE @tblallcases SET NumofFullTermOCs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases WHERE OCBirthTermType = 'Normal')
		UPDATE @tblallcases SET NumofPrematureOCs = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases WHERE OCBirthTermType = 'Premature')
		UPDATE @tblallcases SET NumofMissingBirthTermOCs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases WHERE OCBirthTermType = 'Missing Birth Term')


		-- oc Birth weight 

		UPDATE @tblallcases SET NumofNormalBirthWeightOCs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases WHERE OCBirthWeightType = 'Normal')
		UPDATE @tblallcases SET NumofLowBirthWeightOCs = (SELECT COUNT(DISTINCT ocpk) FROM @tblallcases WHERE OCBirthWeightType = 'Low')
		UPDATE @tblallcases SET NumofMissingBirthWeightOCs = (SELECT COUNT(DISTINCT Ocpk) FROM @tblallcases WHERE OCBirthWeightType = 'Missing')

		
		-- tcs enrolled in first or second trimester 

		UPDATE @tblallcases SET NumOfTCsBorninFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester')
		UPDATE @tblallcases SET NumofTCsBorninSecondTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester')
		
		--pc1s enrolled in the first or second trimester
		
		UPDATE @tblallcases SET NumOfPC1sEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester' )
		UPDATE @tblallcases SET NumofPC1sEnrollledinSecondTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester')


		--pc1 prenatal care first or second trimester 

		UPDATE @tblallcases SET NumofPC1sReceivingPrenatalCareinFirstTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester' 
		AND isrecevingprenatalcare = 1)
		 
		 UPDATE @tblallcases SET NumofPC1sReceivingPrenatalCareinSecondTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		 AND isrecevingprenatalcare = 1)


		 --birth term first or second trimester

		 UPDATE @tblallcases SET NumOfFullTermTCsEnrolledInFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester' 
		 AND birthtermType = 'Full Term')
		 
		 UPDATE @tblallcases SET NumofFullTermTCsEnrolledinSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		 AND birthtermType = 'Full Term')


		  
		 UPDATE @tblallcases SET NumofPrematureTCsEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester'
		 AND birthtermType = 'Premature')
		 UPDATE @tblallcases SET NumOfPrematureTCsEnrolledinSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		 AND birthtermType = 'Premature')


		 UPDATE @tblallcases SET NumofMissingBirthTermTCsEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester' 
		 AND birthtermType = 'Missing Birth Term')

		 UPDATE @tblallcases SET NumofMissingBirthTermTCEnrolledinSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		 AND birthtermType = 'Missing Birth Term')



		 -- mutiples first or second 

		 UPDATE @tblallcases SET NumOfTCMutiplesEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester'
		 AND ismultiple = 1)

		  UPDATE @tblallcases SET NumOfTCMultiplesEnrolledinSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		 AND ismultiple = 1)


		 --brith weight

		 UPDATE @tblallcases SET NumofNormalBirthWeightTCsEnrolledinFirstTrimester  = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester'
		  AND birththweightType = 'Normal')

		  UPDATE @tblallcases SET NumofLowBirthWeightTCsEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'First Trimester'
		  AND birththweightType = 'Low')

		 UPDATE @tblallcases SET NumofMissingBirthWeightTCsEnrolledinFirstTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE  TrimesterTypeAtIntake = 'First Trimester'
		 AND birththweightType = 'Missing')



		 UPDATE @tblallcases SET NumofNormalBirthWeightTCsEnrolledinSecondTrimester  = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		  AND birththweightType = 'Normal')

		  UPDATE @tblallcases SET NumofLowBirthWeigtTCsEnrolledinSecondTriemester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Second Trimester'
		  AND birththweightType = 'Low')

		 UPDATE @tblallcases SET NumofMissingBirthWeightTCsEnrolledinSecondTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE  TrimesterTypeAtIntake = 'Second Trimester'
		 AND birththweightType = 'Missing')

		 -- thrid trimester 

		 UPDATE @tblallcases SET NumofPC1senrolledintheThirdTrimester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester')
		 UPDATE @tblallcases SET NumofTCsBornEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester')
		 UPDATE @tblallcases SET  NumofTCMultiplesEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Thrid Trimester' 
		 AND ismultiple = 1)

		 UPDATE @tblallcases SET NumofPC1swhorecivedprenatalcareintheThirdTriemester = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester' 
		 AND isrecevingprenatalcare = 1)





		 -- third trimester birth term

		 
		 UPDATE @tblallcases SET NumofFullTermTCsEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester' 
		 AND birthtermType = 'Full Term')
		 
		 UPDATE @tblallcases SET NumofPrematureTCsEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester'
		 AND birthtermType = 'Premature')


		  
		 UPDATE @tblallcases SET NumofMissingBirthTermTCsEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester'
		 AND birthtermType = 'Missing Birth Term')




		 -- thrid trimester birth weight
		  UPDATE @tblallcases SET NumofNormalBirthWeightEnrolledinThridTrimiester  = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester'
		  AND birththweightType = 'Normal')

		  UPDATE @tblallcases SET NumofLowBirthWeightEnrolledinThirdTrimester = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Third Trimester'
		  AND birththweightType = 'Low')

		 UPDATE @tblallcases SET NumofMissingBirthWeightEnrolledintheThirdTrimester = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE  TrimesterTypeAtIntake = 'Third Trimester'
		 AND birththweightType = 'Missing')




		 --Postnatal 

		 UPDATE @tblallcases SET NumofPC1sEnrolledPostnatally = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal')
		 UPDATE @tblallcases SET NumofTCsBornEnrolledPostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal')
		UPDATE @tblallcases SET NumofTCMultipleBornPostNatally = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal' AND ismultiple = 1)
		UPDATE @tblallcases SET NumofPC1sReceivingPrenatalCareEnrolledPostNatally = (SELECT COUNT(DISTINCT PC1ID) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal'
		 AND isrecevingprenatalcare = 1)


		--postnatal brith terms

		 
		 UPDATE @tblallcases SET NumofFullTermTCsBornEnrolledPostnatally = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnaatl' 
		 AND birthtermType = 'Full Term')
		 
		 UPDATE @tblallcases SET NumofPreMatureTcsBornEnrolledPostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal'
		 AND birthtermType = 'Premature')


		  
		 UPDATE @tblallcases SET NumofMissingBirthTermPostnatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal'
		 AND birthtermType = 'Missing Birth Term')


		 --postnatal birth weights


		 UPDATE @tblallcases SET NumofNormalBirthWeightTcsBornPostNatally  = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal'
		  AND birththweightType = 'Normal')

		  UPDATE @tblallcases SET NumofLowBirthWeightTcsBornPostNatally = (SELECT COUNT(DISTINCT Tcpk) FROM @tblallcases WHERE TrimesterTypeAtIntake = 'Postnatal'
		  AND birththweightType = 'Low')

		 UPDATE @tblallcases SET NumofMissingBirthWeightTcsBornPostNatally = (SELECT COUNT(DISTINCT tcpk) FROM @tblallcases WHERE  TrimesterTypeAtIntake = 'Postnatal'
		 AND birththweightType = 'Missing')









		 



	










	--UPDATE @tblallcases SET numoffulltermtcsinfirstandsecondTrim

	 -- select everything with the row number of 1 to ge the latest data
	SELECT * FROM @tblallcases WHERE rownumber = 1


	--SELECT * FROM @tblallcases WHERE ocdob BETWEEN @startdate AND @enddate AND rownumber = 1
GO
