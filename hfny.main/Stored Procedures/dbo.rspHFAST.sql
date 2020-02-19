SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rspHFAST]
(
    @sDate AS DATETIME,
	@eDate AS DATETIME,
	@programfk  AS VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	IF @programfk IS NULL BEGIN
		SELECT @programfk = 
			SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
						FROM HVProgram
						FOR XML PATH('')),2,8000)
	END

	SET @programfk = REPLACE(@programfk,'"','')

	DECLARE @tblFinalExport AS TABLE(
	RowNumber INT
	, ItemNumber VARCHAR(4)
	, Item VARCHAR(MAX)
	, Response VARCHAR(MAX)
	, PCID_Response CHAR(13)
	, Header BIT
	, Detail BIT
	)

	--B3 - B9 Cohort Workers
	DECLARE @tblWorkers AS TABLE (
		WorkerProgramPK INT
		,FAWStartDate DATE
		,FAWEndDate DATE
		,FSWStartDate DATE
		,FSWEndDate DATE
		,FTE NUMERIC(5,2)
		,Race VARCHAR(MAX)
		,RaceSpecify VARCHAR(MAX)
		,Gender CHAR(2)
	)
	INSERT INTO @tblWorkers
		(
		  WorkerProgramPK
		, FAWStartDate
		, FAWEndDate
		, FSWStartDate
		, FSWEndDate
		, FTE
		, Race
		, RaceSpecify
		, Gender
		)	
	SELECT WorkerProgramPK
		, FAWStartDate
		, FAWEndDate
		, FSWStartDate
		, FSWEndDate
		, CASE FTE
			WHEN '01' THEN 1.0
			WHEN '02' THEN 0.5
			WHEN '03' THEN 0.25
		  END AS FTE
		, Race
		, RaceSpecify
		, Gender
		FROM dbo.WorkerProgram wp
		inner join dbo.Worker w ON w.WorkerPK = wp.WorkerFK
		inner join dbo.SplitString(@programfk,',') ON wp.programfk  = listitem
		and 
		(
			(wp.FAWStartDate < @eDate and (wp.FAWEndDate is null or wp.FAWEndDate > @eDate))
			or
			(wp.FSWStartDate < @eDate and (wp.FSWEndDate is null or wp.FSWEndDate > @eDate))
		)
		and (wp.TerminationDate is null or wp.TerminationDate > @eDate)

	--Cohort All home visit logs in period
	DECLARE @tblHomeVisits AS TABLE (
		hvcasefk INT INDEX  idx1 NONCLUSTERED
		,hvlogpk INT
		,VisitStartTime DATE
		,FirstHomeVisit DATE
		,IntakeDate DATE
		,EDC DATE
		,TCDOB DATE
		,TCNumber  INT
		,PC1Participated BIT
		,OBPParticipated BIT
		,PCDOB DATE
		,Gender CHAR(2)
		,GenderOBP CHAR(2)
		,Race CHAR(2)
		,Ethnicity VARCHAR(MAX)
		,PC1Relation2TC  INT
		,RowNum  INT
	)

	INSERT INTO @tblHomeVisits(
	  hvcasefk
	 ,hvlogpk
	 ,VisitStartTime
	 ,IntakeDate
	 ,EDC
	 ,TCDOB
	 ,TCNumber
	 ,PC1Participated
	 ,OBPParticipated 
	 ,Gender
	 ,GenderOBP
	 ,Race
	 ,Ethnicity
	 ,PCDOB
	 ,PC1Relation2TC
	 ,RowNum
	)
	SELECT hv.hvcasefk
	      , hv.hvlogpk
	      , hv.VisitStartTime
		  , hc.IntakeDate
		  , hc.EDC
		  , hc.TCDOB
		  , hc.TCNumber
		  , hv.PC1Participated
		  , hv.OBPParticipated 
		  , pc.Gender
		  , obp.Gender
		  , pc.Race
		  , pc.Ethnicity
		  , pc.PCDOB
		  , hc.PC1Relation2TC
		  , ROW_NUMBER() OVER(PARTITION BY hv.hvcasefk ORDER BY hv.VisitStartTime ASC)
	FROM hvlog hv
	inner join dbo.HVCase hc ON hc.HVCasePK = hv.HVCaseFK
	inner join pc ON PC.PCPK = hc.PC1FK
	left join pc obp ON obp.pcpk = hc.OBPFK
	inner join dbo.CaseProgram cp ON cp.HVCaseFK = hc.HVCasePK
	inner join dbo.SplitString(@programfk,',') ON hv.programfk  = listitem

	WHERE SUBSTRING(VisitType, 4, 1) <> '1'
	      and VisitStartTime BETWEEN @sDate AND @eDate
		  AND cp.TransferredtoProgramFK IS NULL -- Weed out transfer cases
    OPTION (OPTIMIZE FOR (@sDate UNKNOWN, @eDate UNKNOWN))	

	--Cohort - Current PC1IDs - removes duplicates eg. transfer back and forth
	DECLARE @tblPC1IDs AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,PC1ID CHAR(13)
	)
	INSERT INTO @tblPC1IDs (
		hvcasefk
		, PC1ID
	)
	SELECT sub.hvcasefk,
		   sub.PC1ID
	FROM
	(SELECT PC1ID
		, thv.hvcasefk
		,ROW_NUMBER() OVER (PARTITION BY thv.hvcasefk ORDER BY cp.CaseStartDate DESC) AS [row]
    FROM caseprogram cp
	inner join @tblHomeVisits thv ON thv.hvcasefk = cp.HVCaseFK 
	) AS sub
	WHERE sub.[row] = 1

	--add first home visit date to cohort
	DECLARE @tblFirstVisit AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
	  , FirstHomeVisit DATE
	);

	INSERT INTO @tblFirstVisit
	 (hvcasefk
	 , FirstHomeVisit
	 )
	SELECT DISTINCT hl.hvcasefk, MIN(hl.VisitStartTime)
	FROM dbo.HVLog hl
	inner join @tblHomeVisits thv ON thv.hvcasefk = hl.HVCaseFK
	GROUP BY hl.hvcasefk

	UPDATE @tblHomeVisits
	 SET FirstHomeVisit = tfv.FirstHomeVisit
     FROM @tblHomeVisits thv
	 inner join @tblFirstVisit tfv ON tfv.hvcasefk = thv.hvcasefk
	
	--Cohort last home visit in period
	DECLARE @tblLastHomeVisit AS TABLE (
		    hvcasefk  INT INDEX  idx1 NONCLUSTERED
	      , VisitStartTime DATE
		  , EDC DATE
		  , TCDOB DATE
		  , TCNumber  INT
		  , Gender CHAR(2)
	)
	INSERT INTO @tblLastHomeVisit (
		hvcasefk
		, VisitStartTime
		, EDC
		, TCDOB
		, TCNumber
		, Gender
	)
	SELECT sub.hvcasefk
		   ,sub.VisitStartTime
		   ,sub.EDC
		   ,sub.TCDOB
		   ,sub.TCNumber
		   ,sub.Gender
    FROM(
	SELECT thv.hvcasefk
	       , VisitStartTime
		   , EDC
		   , TCDOB
		   , TCNumber
		   , Gender
		   , ROW_NUMBER() OVER (PARTITION BY thv.hvcasefk ORDER BY thv.VisitStartTime DESC) [row]
	FROM @tblHomeVisits thv) sub
	WHERE sub.row = 1

	--Cohort Parity
	DECLARE @tblParity AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,Parity  INT
		,KempeDate DATE
		,TCDOB DATE
	)
	INSERT INTO @tblParity (
		hvcasefk
		, Parity
		, KempeDate
		, TCDOB
	)
	SELECT ca.HVCaseFK
		   ,ca.Parity AS ParityKE
		   ,ca.FormDate AS KempeDate
		   ,thv.TCDOB
		    FROM dbo.CommonAttributes ca
			inner join @tblHomeVisits thv ON thv.hvcasefk = ca.HVCaseFK
	WHERE ca.formtype = 'KE'
	
	--Cohort Intake Info
	DECLARE @tblIntakeInfo AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,HighestGrade CHAR(2)
		,MaritalStatus CHAR(2)
		,PrimaryLanguage CHAR(2)
		,PC1FamilyArmedForces CHAR(1)
	)
	INSERT INTO @tblIntakeInfo (
	    hvcasefk
		,HighestGrade
		,MaritalStatus
		,PrimaryLanguage
		,PC1FamilyArmedForces	
	)

	SELECT intake.hvcasefk
		, HighestGrade
		, MaritalStatus
		, PrimaryLanguage
		, PC1FamilyArmedForces
    FROM dbo.CommonAttributes
	inner join intake ON Intake.HVCaseFK = CommonAttributes.HVCaseFK and Intake.IntakePK = CommonAttributes.FormFK
	WHERE formtype = 'IN-PC1'
	and intake.hvcasefk in (SELECT hvcasefk FROM @tblHomeVisits) 

	--Cohort followups for this years cases
	DECLARE @tblFollowUpInfo AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,FollowUpPK  INT
		,FollowUPDATE DATE
		,DevelopmentalDisability CHAR(1)
		,SubstanceAbuse CHAR(1)
		,PC1FamilyArmedForces CHAR(1)
		,RowNum  INT
	)
	INSERT INTO @tblFollowUpInfo (
		hvcasefk
		, FollowUpPK
		, FollowUPDATE
		, DevelopmentalDisability
		, SubstanceAbuse
		, PC1FamilyArmedForces
		, RowNum
	)
	SELECT  fu.hvcasefk
		   ,fu.FollowUpPK
		   ,fu.FollowUPDATE
		   ,pci.DevelopmentalDisability
		   ,pci.SubstanceAbuse
		   ,fu.PC1FamilyArmedForces
		   ,ROW_NUMBER() OVER (PARTITION BY fu.hvcasefk ORDER BY fu.FollowUPDATE DESC)
	FROM dbo.FollowUp fu
	inner join dbo.PC1Issues pci ON pci.PC1IssuesPK = fu.PC1IssuesFK
	WHERE fu.hvcasefk in (SELECT hvcasefk FROM @tblHomeVisits)

	--Cohort Kempe Info
	DECLARE @tblKempeInfo AS TABLE (
		hvcasefk int INDEX  idx1 NONCLUSTERED
		,PC1Neglected CHAR(1)
		,PC1PhysicallyAbused CHAR(1)
		,PC1SexuallyAbused CHAR(1)
		,MomScore CHAR(3)
		,MomCPSArea CHAR(2)
		,DadScore CHAR(3)

	)
	INSERT INTO @tblKempeInfo (
		hvcasefk
		, PC1Neglected
		, PC1PhysicallyAbused
		, PC1SexuallyAbused
		, MomScore
		,MomCPSArea
		, DadScore 
	)
	SELECT DISTINCT
	     hvcasefk
		,PC1Neglected
		,PC1PhysicallyAbused
		,PC1SexuallyAbused
		, MomScore
		,MomCPSArea
		, DadScore 
	FROM Kempe
	WHERE hvcasefk in (SELECT hvcasefk FROM @tblHomeVisits)
	
	--Cohort PC1 Health Insurance assessments in given year
	DECLARE @tblPC1Insurance AS TABLE (
		 FormDate DATE
	   , HIFamilyChildHealthPlus BIT
	   , HIOther BIT
	   , HIPCAP BIT
	   , HIPrivate BIT
	   , HIUninsured BIT
	   , HIUnknown BIT
	   , HVCaseFK  INT
	   , NumberInHouse  INT
	   , AvailableMonthlyIncome NUMERIC(5,0)
	   , PBEmergencyAssistance CHAR(1)
	   , PBFoodStamps CHAR(1)
	   , PBSSI CHAR(1)
	   , PBTANF CHAR(1)
	   , PBWIC CHAR(1)
	   , PC1ReceivingMedicaid_IN CHAR(1)
	   , PC1ReceivingMedicaid_FU CHAR(1)
	   , RowNum  INT
	)
	INSERT INTO @tblPC1Insurance (
		FormDate
	   , HIFamilyChildHealthPlus
	   , HIOther
	   , HIPCAP
	   , HIPrivate
	   , HIUninsured
	   , HIUnknown
	   , HVCaseFK
	   , NumberInHouse
	   , AvailableMonthlyIncome
	   , PBEmergencyAssistance
	   , PBFoodStamps
	   , PBSSI
	   , PBTANF
	   , PBWIC
	   , PC1ReceivingMedicaid_IN
	   , PC1ReceivingMedicaid_FU
	   , RowNum 
	)
	SELECT ca.FormDate
	   , ca.HIFamilyChildHealthPlus
	   , ca.HIOther
	   , ca.HIPCAP
	   , ca.HIPrivate
	   , ca.HIUninsured
	   , ca.HIUnknown
	   , ca.HVCaseFK
	   , ca.NumberInHouse
	   , ca.AvailableMonthlyIncome
	   , ca.PBEmergencyAssistance
	   , ca.PBFoodStamps
	   , ca.PBSSI
	   , ca.PBTANF
	   , ca.PBWIC
	   , ca.PC1ReceivingMedicaid
	   , ca2.PC1ReceivingMedicaid
	   , ROW_NUMBER() OVER (PARTITION BY ca.hvcasefk ORDER BY ca.FormDate DESC) AS [row]  
	   FROM commonattributes ca
	   left join commonattributes ca2 ON  ca2.FormType = 'FU-PC1' and ca.FormType = 'FU' and ca.FormFK = ca2.FormFK and ca.HVCaseFK = ca2.HVCaseFK
	   WHERE ca.FormType in ('FU', 'IN', 'KE') and ca.HVCaseFK in (select hvcasefk from @tblHomeVisits)

	--Cohort TC Health insurance assessments in given year
	DECLARE @tblTCInsurance AS TABLE (
		HVCaseFK int INDEX  idx1 NONCLUSTERED
		,FormDate DATE
		,TCHIFamilyChildHealthPlus BIT
		,TCHIPrivateInsurance BIT
		,TCHIOther BIT
		,TCHIUninsured BIT
		,TCHIUnknown BIT
		,TCReceivingMedicaid CHAR(1)
		,TCNumber  INT
		,RowNum  INT
	)
	INSERT INTO @tblTCInsurance (
	      HVCaseFK
		, FormDate
		, TCHIFamilyChildHealthPlus
		, TCHIPrivateInsurance
		, TCHIOther
		, TCHIUninsured
		, TCHIUnknown
		, TCReceivingMedicaid
		, TCNumber
		, RowNum
		)
	SELECT ca.HVCaseFK
	    , FormDate
		, TCHIFamilyChildHealthPlus
		, TCHIPrivateInsurance
		, TCHIOther
		, TCHIUninsured
		, TCHIUnknown
		, TCReceivingMedicaid
		, hc.TCNumber
		, ROW_NUMBER() OVER (PARTITION BY ca.hvcasefk ORDER BY ca.FormDate DESC)
	FROM dbo.CommonAttributes ca
	inner join HVCase hc ON hc.HVCasePK = ca.HVCaseFK
	WHERE FormType in ('TC', 'FU') and ca.HVCaseFK in (select hvcasefk from @tblHomeVisits)

--Cohort TC Birth Info
    DECLARE @tblTCBirthInfo AS TABLE (
		hvcasefk int INDEX  idx1 NONCLUSTERED
		,TCDOB DATE
		,BirthWtLbs  INT
		,BirthWtOz  INT
		,GestationalAge  INT
	)
	INSERT INTO @tblTCBirthInfo (
		hvcasefk
		, TCDOB
		, BirthWtLbs
		, BirthWtOz
		, GestationalAge
	)
	SELECT t.hvcasefk
		   ,t.TCDOB
		   , BirthWtLbs
		   , BirthWtOz
		   , GestationalAge
	FROM dbo.TCID t 
	inner join @tblPC1IDs tpid ON tpid.hvcasefk = t.HVCaseFK
	
--Cohort Living Arrangement assessments in given year
	DECLARE @tblLivingArrangement AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,LivingArrangement CHAR(2)
		,LivingArrangementSpecific CHAR(2)
		,FormDate DATE
		,RowNum  INT
	)
	INSERT INTO @tblLivingArrangement (
		hvcasefk
		, LivingArrangement
		, LivingArrangementSpecific
		, FormDate
		, RowNum
	)
	SELECT ca.hvcasefk
		,LivingArrangement
		,LivingArrangementSpecific
		,FormDate
		,ROW_NUMBER() OVER(PARTITION BY ca.hvcasefk ORDER BY FormDate DESC)
		FROM dbo.CommonAttributes ca
		WHERE ca.FormType in ('IN', 'FU') and ca.HVCaseFK in (select hvcasefk from @tblHomeVisits)

--Cohort Employment assessments in given year
	DECLARE @tblEmployment AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,EmploymentMonthlyHours  INT
		,HoursPerMonth  INT
		,IsCurrentlyEmployed CHAR(1)
		,FormDate DATE
		,RowNum  INT
	)
	INSERT INTO @tblEmployment (
		hvcasefk
		, EmploymentMonthlyHours
		, HoursPerMonth
		, IsCurrentlyEmployed
		, FormDate	
		, RowNum	
	)
	SELECT thv.hvcasefk
		, e.EmploymentMonthlyHours
		, ca.HoursPerMonth
		, ca.IsCurrentlyEmployed
		, ca.FormDate	
		,ROW_NUMBER() OVER(PARTITION BY thv.hvcasefk ORDER BY ca.FormDate DESC)
	FROM @tblPC1IDs thv	
	left join dbo.CommonAttributes ca ON thv.hvcasefk = ca.HVCaseFK and ca.FormType in ('FU-PC1', 'IN-PC1', 'KE')
	left join Employment e ON e.FormFK = ca.FormFK and ca.FormType like (e.FormType + '%')

	--Referral Source
	DECLARE @tblReferrals AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		,ReferralSource CHAR(2)
	)
	INSERT INTO @tblReferrals (hvcasefk, ReferralSource)
	SELECT hv.hvcasefk ,
		   ReferralSource
	FROM hvscreen hv
	inner join @tblPC1IDs tpid ON tpid.hvcasefk = hv.HVCaseFK

	--ASQ Under Cutoff
	DECLARE @tblASQ AS TABLE (
		hvcasefk  INT INDEX  idx1 NONCLUSTERED
		, TCIDFK  INT
		, UnderCommunication BIT
		 , UnderFineMotor BIT
		 , UnderGrossMotor BIT
		 , UnderPersonalSocial BIT
		 , UnderProblemSolving BIT
	)
	INSERT INTO @tblASQ (
			hvcasefk
		  , TCIDFK
		  , UnderCommunication
		  , UnderFineMotor
		  , UnderGrossMotor
		  , UnderPersonalSocial
		  , UnderProblemSolving
	)
   SELECT HVCaseFK
	     , TCIDFK
		 , UnderCommunication
		 , UnderFineMotor
		 , UnderGrossMotor
		 , UnderPersonalSocial
		 , UnderProblemSolving
    FROM (
	SELECT ASQ.HVCaseFK
	     , TCIDFK
		 , UnderCommunication
		 , UnderFineMotor
		 , UnderGrossMotor
		 , UnderPersonalSocial
		 , UnderProblemSolving
		 , ROW_NUMBER() OVER(PARTITION BY tcidfk ORDER BY DateCompleted DESC) AS [row]
	FROM ASQ inner join @tblPC1IDs tpid ON tpid.hvcasefk = ASQ.HVCaseFK
	WHERE DateCompleted < @eDate
    ) sub
	WHERE sub.[row] = 1

--Begin filling in results table
-----------------				
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(
			10, 'B2', 'Number of home visits completed:', 0, 0,
			(SELECT COUNT(hvcasefk) 
			 FROM @tblHomeVisits thv
			 WHERE thv.VisitStartTime between @sDate and @eDate)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(20, 'B3', 'How many PEOPLE worked in Family Resource Specialist role at the end of last year?', 0, 0,
		  (SELECT COUNT(workerprogrampk) 
		   FROM @tblWorkers 
		   WHERE [@tblWorkers].FAWStartDate < @eDate 
				and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
		)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(30, 'B4', 'What was your total FTEs in Family Resource Specialist role?', 0, 0,
	( SELECT sum([@tblWorkers].FTE) 
					FROM @tblWorkers 
					WHERE [@tblWorkers].FAWStartDate < @eDate 
							and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
    )
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(40, 'B5', 'How many PEOPLE worked in Family Support Specialist role at the end of last year?', 0, 0,
	( SELECT COUNT(workerprogrampk) 
					  FROM @tblWorkers 
					  WHERE [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(50, 'B6', 'What was your total FTEs in Family Support Specialist role?', 0, 0,
	( SELECT sum([@tblWorkers].FTE) 
					FROM @tblWorkers 
					WHERE [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
    )
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
	VALUES(55, 'B7', 'What is your Site''s definition of Full-time hours per week, excluding required lunch hour (select closest option)', 0,0)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(60, NULL, 'Ethnicity: Number of Family Support Specialists who are:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(70, 'B8', 'Hispanic', 0, 0,
	( SELECT COUNT(Race) 
						 FROM @tblWorkers
						 WHERE Race = '03'
						 and (
								[@tblWorkers].FSWStartDate < @eDate 
								and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							  ) 
						) 
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(80, 'B8', 'Non-Hispanic', 0, 0,
	( SELECT COUNT(Race) 
					        FROM @tblWorkers
						    WHERE Race <> '03'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(90, 'B8', 'Ethnicity Unknown', 0, 0,
		( SELECT COUNT(*) 
		  FROM @tblWorkers
		  WHERE Race is Null
			AND ([@tblWorkers].FSWStartDate < @eDate 
			and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
			)
		)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(100, NULL, 'Race: Number of Family Support Specialists who are:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(110, 'B9', 'White', 0, 0,
	   (SELECT COUNT(Race) 
		FROM @tblWorkers
		WHERE Race = '01'
		and ( [@tblWorkers].FSWStartDate < @eDate  and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate) )
	   )
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(120, 'B9', 'African-American', 0, 0,
		(	SELECT COUNT(Race) 
			FROM @tblWorkers
			WHERE Race = '02'
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
	    )
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(130, 'B9', 'Asian', 0, 0, 
		( SELECT COUNT(Race) 
		  FROM @tblWorkers
		  WHERE Race = '04'
			 and ([@tblWorkers].FSWStartDate < @eDate AND ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate) )
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(140, 'B9', 'American Indian/Alaskan Native', 0, 0,
		(	SELECT COUNT(Race) 
			FROM @tblWorkers
			WHERE Race = '05'
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)  )
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
	VALUES(150, 'B9', 'Native Hawaiian/Pacific Islander', 0, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(160, 'B9', 'Multi-race', 0, 0,
		(	SELECT COUNT(Race) 
			FROM @tblWorkers
			WHERE Race = '06'
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(170, 'B9', 'Race Unknown', 0, 0,
		(	SELECT COUNT(*) 
			FROM @tblWorkers
			WHERE Race is null
				and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(180, 'B9', 'Other Race', 0, 0,
		(	SELECT COUNT(Race) 
			FROM @tblWorkers
			WHERE Race = '07'
				and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(190, NULL, 'Gender: Number of Family Support Specialists who are:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(200, 'B10', 'Women', 0, 0, 
		(	SELECT COUNT(Gender)
			FROM @tblWorkers
			WHERE Gender = '01'
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(210, 'B10', 'Men', 0, 0, 
		(	SELECT COUNT(Gender)
			FROM @tblWorkers
			WHERE Gender = '02'
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(220, 'B10', 'Other Gender', 0, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(230, 'B10', 'Unknown', 0, 0, 
		(	SELECT COUNT(Gender)
			FROM @tblWorkers
			WHERE Gender is null
			and ([@tblWorkers].FSWStartDate < @eDate and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
		)
	)

-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(240, NULL, 'How many families:', 1, 0)
-----------------	
	--This pattern is used for all questions with drill downs
	--First we INSERT the detail rows for the question			
    INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
    SELECT 250, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (SELECT DISTINCT hvcasefk FROM @tblHomeVisits)

	--Then we INSERT the aggregate row for the above detail rows, counting the detail rows. 
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(250, 'B11', 'Received at least 1 home visit?', 0, 0,
		(	SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 250 and Detail = 1))
-----------------

	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 260, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.PC1ID in ( SELECT DISTINCT me.PC1ID FROM MIECHVEligible me )
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(260, 'B12', 'Were MIECHV funded (at least 25%)?', 0, 0, 
	(	SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 260 and Detail = 1))
-----------------
    INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 270, tpid.PC1ID, 0, 1	
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in 
		(	SELECT thv.hvcasefk FROM @tblHomeVisits thv
			WHERE thv.FirstHomeVisit >= @sDate)
						   
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(270, 'B13', 'Received their first home visit?', 0, 0,
		(	SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 270 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 280, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in
		(	SELECT thv.hvcasefk FROM @tblHomeVisits thv
			WHERE thv.FirstHomeVisit >= @sDate AND isnull(EDC, TCDOB) > thv.FirstHomeVisit)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(280, 'B14', 'Received their first home visit prenatally?', 0, 0,
		(	SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 280 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 290, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in
		(	SELECT thv.hvcasefk FROM @tblHomeVisits thv
			WHERE thv.FirstHomeVisit >= @sDate
				and dateadd(day, -54 , isnull(EDC, TCDOB)) >= thv.FirstHomeVisit)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(290, 'B15', 'Received their first home visit prenatally before 31 weeks?', 0, 0,
		(	SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 290 and Detail = 1)
	)
-----------------
	--ToDo
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(300, 'B16', 'Families enrolled as "Accelerated"', 0, 0)
	--End ToDo
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 310, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblReferrals tr
		WHERE tr.ReferralSource = '05'
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(310, 'B17', 'Referrals from Child Welfare', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport WHERE RowNumber = 310 AND Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 320, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in
		(	SELECT sub.hvcasefk from
				(	SELECT hvcasefk
						,VisitStartTime
						,ROW_NUMBER() OVER (PARTITION BY hvcasefk ORDER BY VisitStartTime ASC) AS [row]						   
					FROM @tblHomeVisits
					WHERE (PC1Participated = 1 and PC1Relation2TC = '01' and Gender = '02')										 
				) AS sub WHERE sub.[row] = 2

			UNION

			SELECT sub.hvcasefk from
				(	SELECT hvcasefk
						,VisitStartTime
						,ROW_NUMBER() OVER (PARTITION BY hvcasefk ORDER BY VisitStartTime ASC) AS [row]						   
					FROM @tblHomeVisits
					WHERE (OBPParticipated = 1 and GenderOBP = '02')
				) AS sub WHERE sub.[row] = 2
		)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(320, 'B18', 'With a father involved in home visiting (attended more than 1)?', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 320 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(330, 'B19', 'Number of target children served', 0, 0,
		(	SELECT COUNT(*) 
			FROM TCID INNER join @tblLastHomeVisit thv ON thv.hvcasefk = TCID.HVCaseFK
			WHERE TCID.TCDOB < thv.VisitStartTime					 
		)
		+ 
		(	SELECT COUNT(*) FROM @tblLastHomeVisit
			WHERE TCDOB is null or TCDOB > VisitStartTime  
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(340, 'B20', 'Number of non-target children served', 0, 0,
		(	SELECT COUNT(oc.OtherChildPK)
			FROM OtherChild oc 
			WHERE oc.HVCaseFK in (SELECT hvcasefk FROM @tblHomeVisits)
		)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(350, NULL, 'How many primary participants were:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(360, 'B21', 'Women', 0, 0,
		(	SELECT COUNT(Gender)
			FROM @tblLastHomeVisit
			WHERE Gender = '01'
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(370, 'B22', 'Men', 0, 0,
		(	 SELECT COUNT(Gender)
			 FROM @tblLastHomeVisit
			 WHERE Gender = '02'
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(380, 'B23', 'Other gender', 0, 0, null)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(385, 'B23', 'Unknown gender', 0, 0,
		(	 SELECT COUNT(*)
			FROM @tblLastHomeVisit
			WHERE Gender is null or Gender = ''
		)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 390, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		 SELECT DISTINCT hvcasefk FROM @tblParity
		 WHERE (Parity = 0 and TCDOB is null)
			or (Parity = 0 and KempeDate < TCDOB)
			or (Parity = 1 and TCDOB < KempeDate)
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(390, 'B24', 'First time parent', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 390 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 400, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT hvcasefk FROM @tblHomeVisits
        WHERE PC1Relation2TC = '04'
		)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(400, 'B25', 'Grandparent of target child', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 400 AND Detail = 1)
    )
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 410, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade = '08' 
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(410, 'B26', 'Bachelor''s Degree or Higher', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 410 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 420, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade = '07' 
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(420, 'B27', 'Associate''s Degree', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 420 and Detail = 1)
	)
-----------------
		INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 430, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade = '05' 
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(430, 'B28', 'Technical Training or Certification', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 430 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 440, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade = '06' 
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(440, 'B29', 'Some College/Training', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 430 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 450, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade in ('03', '04', '05', '06', '07', '08') 
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(450, 'B30', 'HS graduate/GED or higher at enrollment', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 450 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 460, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade in ('01', '02')
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(460, 'B31', 'Less than HS Graduate/GED at enrollment', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 460 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 470, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE HighestGrade is null or HighestGrade = ''
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(470, 'B32', 'Education Level Unknown', 0, 0,
			(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 470 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 480, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT hvcasefk FROM @tblFollowUpInfo
		WHERE DevelopmentalDisability = '1'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(480, 'B33', 'Developmentally delayed', 0, 0, 
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 480 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 490, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance 
				WHERE AvailableMonthlyIncome <= 1397 + ((NumberInHouse - 1) * 497)  
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(490, 'B34', 'Medicaid Eligible', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE tfe.RowNumber = 490 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 500, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT fui.hvcasefk FROM @tblFollowUpInfo fui
		inner join @tblIntakeInfo ii ON ii.hvcasefk = fui.hvcasefk
		WHERE fui.PC1FamilyArmedForces = '1' or ii.PC1FamilyArmedForces = '1'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(500, 'B35', 'Military personnel or spouse', 0, 0, 
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 500 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 510, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT hvcasefk FROM @tblFollowUpInfo
		WHERE SubstanceAbuse = '1'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(510, 'B36', 'Have substance abuse history', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 510 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
	VALUES(520, 'B37', 'In need of substance abuse treatment', 0, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 530, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in ( 
		SELECT DISTINCT hvcasefk FROM @tblKempeInfo
		WHERE PC1Neglected = '1' or PC1PhysicallyAbused = '1' or PC1SexuallyAbused = '1'
	)
		
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(530, 'B38', 'Abused or neglected as a child', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 530 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 540, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblKempeInfo
		WHERE MomCPSArea = '05' OR MomCPSArea = '10'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(540, 'B39', 'Involved in Child Welfare System (as caregiver).', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 540 and Detail = 1)	
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 550, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblIntakeInfo
		WHERE MaritalStatus in ('02', '04', '05')
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(550, 'B40', 'Single parent', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 550 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 560, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM phq9 
		WHERE Positive = 1 and hvcasefk in (SELECT hvcasefk FROM @tblHomeVisits) 
    )

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(560, 'B41', 'Over cutoff on depression screen', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 560 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail)
	VALUES(570, NULL, 'Insurance Status of PC1 (when last assessed):', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 580, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance
		WHERE HIUninsured = 1 and RowNum = 1
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(580, 'B42', 'No insurance', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 580 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 590, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance
		WHERE RowNum = 1 and (PC1ReceivingMedicaid_FU = '1' OR PC1ReceivingMedicaid_IN = '1') 
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(590, 'B42', 'Title XIX (Medicaid) / Title XXI (SCHIP) or Tri-Care', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 590 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 600, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance
		WHERE RowNum = 1
		and (HIOther = 1 or HIPrivate = 1 or HIFamilyChildHealthPlus = 1 or HIPCAP = 1)
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(600, 'B42', 'Private or other insurance', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 600 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 610, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance
		WHERE RowNum = 1 and HIUnknown = 1
	)
		
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(610, 'B42', 'Unknown', 0, 0, 
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 610 and Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(620, NULL, 'Insurance Status of TC (when last assessed):', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 630, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCInsurance
		WHERE RowNum = 1 and TCHIUninsured = 1
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(630, 'B43', 'No insurance', 0, 0, 
		(SELECT COUNT(*) 
		 FROM @tblTCInsurance tci
		 INNER join @tblTCBirthInfo ttbi ON ttbi.hvcasefk = tci.HVCaseFK
		 WHERE RowNum = 1 and TCHIUninsured = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 640, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCInsurance
		WHERE RowNum = 1 and TCReceivingMedicaid = '1'
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(640, 'B43', 'Title XIX (Medicaid) / Title XXI (SCHIP) or Tri-Care', 0, 0,
		(	SELECT COUNT(*) 
			FROM @tblTCInsurance tci
			inner join @tblTCBirthInfo ttbi ON ttbi.hvcasefk = tci.HVCaseFK
			WHERE RowNum = 1 and TCReceivingMedicaid = '1')
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 650, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCInsurance
		WHERE RowNum = 1 
		and (TCHIFamilyChildHealthPlus = 1 or TCHIOther = 1 or TCHIPrivateInsurance = 1)
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(650, 'B43', 'Private or other insurance', 0, 0, 
		(	SELECT COUNT(*) 
			FROM @tblTCInsurance tci
			inner join @tblTCBirthInfo ttbi ON ttbi.hvcasefk = tci.HVCaseFK
			WHERE RowNum = 1 and (TCHIFamilyChildHealthPlus = 1 or TCHIOther = 1 or TCHIPrivateInsurance = 1))
	)	
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 660, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCInsurance
		WHERE RowNum = 1 and TCHIUnknown = 1 
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(660, 'B43', 'Unknown', 0, 0,
		(SELECT COUNT(*) FROM @tblTCInsurance tci
		 INNER join @tblTCBirthInfo ttbi ON ttbi.hvcasefk = tci.HVCaseFK
		 WHERE RowNum = 1 and TCHIUnknown = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(670, NULL, 'Housing Status of PC1 (when last assessed):', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 680, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '01'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(680, 'B44', 'Own/share ownership of their home', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 680 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 690, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '02'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(690, 'B44', 'Rent/share rent of their home', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 690 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 700, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '03'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(700, 'B44', 'Live in public housing', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 700 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 705, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '04'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(705, 'B44', 'Live with parent or family member', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 705 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 710, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '05'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(710, 'B44', 'Other arrangement (not homeless)', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 710 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 720, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '06'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(720, 'B44', 'Homeless - sharing housing', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 720 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 730, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '07'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(730, 'B44', 'Homeless - emergency or transitional shelter', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 730 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 740, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangementSpecific = '08'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(740, 'B44', 'Homeless - other arrangement', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 740 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 750, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLivingArrangement
		WHERE RowNum = 1 and LivingArrangement = '03'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(750, 'B44', 'Unknown/Did not report', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 750 and Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(760, NULL, 'PC1 employment status:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 770, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblEmployment
		WHERE RowNum = 1 and IsCurrentlyEmployed = '1' and (EmploymentMonthlyHours >= 140 or HoursPerMonth >= 140)
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(770, 'B45', 'employed full time', 0, 0, 
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 770 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 780, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblEmployment
		WHERE RowNum = 1 and IsCurrentlyEmployed = '1' and ((EmploymentMonthlyHours < 140 or EmploymentMonthlyHours is null) or
															(HoursPerMonth < 140 or HoursPerMonth < 140))
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(780, 'B45', 'employed part time', 0, 0, 
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 780 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 790, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblEmployment
		WHERE RowNum = 1 and IsCurrentlyEmployed = '0'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(790, 'B45', 'not employed (whether seeking work or not)', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 790 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 800, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblEmployment
		WHERE RowNum = 1 and (IsCurrentlyEmployed is null or IsCurrentlyEmployed = ' ')
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(800, 'B45', 'unknown employment situation', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 800 and Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(810, NULL, 'For items below, I am using _____ for my initial assessment tool', 1, 0)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
VALUES(820, 'B46', 'Assessment Tool', 0, 0, 'Parent Survey')
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
VALUES(830, 'B47', 'Other assessment tool specify', 0, 0, '')
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(840, 'B48', 'How many PC1s were:', 1, 0)	
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 850, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT tki.hvcasefk FROM @tblKempeInfo tki
		inner join @tblHomeVisits thv ON thv.hvcasefk = tki.hvcasefk
		WHERE (Gender = '01' and MomScore < 25)
		   or (Gender = '02' and DadScore < 25)
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(850, 'B48', 'Low risk on Initial Assessment(Parent Survey < 25)', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 850 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 860, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT tki.hvcasefk FROM @tblKempeInfo tki
		inner join @tblHomeVisits thv ON thv.hvcasefk = tki.hvcasefk
		WHERE (Gender = '01' and MomScore between 25 and 35)
	       or (Gender = '02' and DadScore between 25 and 35)
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(860, 'B48', 'Medium risk on Initial Assessment(Parent Survey 25-35)', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 860 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 870, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT tki.hvcasefk FROM @tblKempeInfo tki
		inner join @tblHomeVisits thv ON thv.hvcasefk = tki.hvcasefk
		WHERE (Gender = '01' and MomScore >= 40)
		   or (Gender = '02' and DadScore >= 40)
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(870, 'B40', 'Higher risk on Initial Assessment(Parent Survey 40+)', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 870 and Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(880, NULL, 'TC age at Last Home Visit:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 890, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE TCDOB is null or TCDOB > VisitStartTime  
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(890, 'B49', 'Prenatal', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE tfe.RowNumber = 890 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 900, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE   DATEDIFF(day, TCDOB, VisitStartTime) >= 0
			and	datediff(day, TCDOB, VisitStartTime) < 183
			and TCDOB < @eDate
	)
		
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(900, 'B49', '0-5 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 0
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 183
			and TCID.TCDOB < @eDate)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 910, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 183 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 365
			and TCDOB < @eDate
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(910, 'B49', '6-11 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 183 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 365
			and tlhv.TCDOB < @eDate)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 920, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 365 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 730
			and TCDOB < @eDate
	)
		
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(920, 'B49', '12-23 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 365 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 730
			and tlhv.TCDOB < @eDate)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 930, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 730 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 1095
			and TCDOB < @eDate
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(930, 'B49', '24-35 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 730 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 1095
			and tlhv.TCDOB < @eDate)
	) 
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 940, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 1095 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 1460
			and TCDOB < @eDate
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(940, 'B49', '36-47 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 1095 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 1460
			and tlhv.TCDOB < @eDate)
	) 
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 950, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 1460 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 1825
			and TCDOB < @eDate
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response)
	VALUES(950, 'B49', '48-59 months', 0, 0,
		 (	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 1460 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 1825
			and tlhv.TCDOB < @eDate)
	) 
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 960, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 1825 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 2190
			and TCDOB < @eDate
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(960, 'B49', '60-71 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 1825 
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 2190
			and tlhv.TCDOB < @eDate)
	) 
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 970, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE DATEDIFF(day, TCDOB, VisitStartTime) >= 2190 
			and DATEDIFF(day, TCDOB, VisitStartTime) < 2555
			and TCDOB < @eDate
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(970, 'B49', '72-83 months', 0, 0,
		(	SELECT COUNT(*) FROM @tblLastHomeVisit tlhv
			left join TCID ON TCID.HVCaseFK = tlhv.hvcasefk
			WHERE DATEDIFF(day, tlhv.TCDOB, VisitStartTime) >= 2190  
			and DATEDIFF(day, tlhv.TCDOB, VisitStartTime) < 2555
			and tlhv.TCDOB < @eDate)
	) 
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 980, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid 
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblLastHomeVisit
		WHERE TCDOB is null and EDC is null
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(980, 'B49', 'Unknown', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE tfe.RowNumber = 980 and tfe.Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(990, NULL, 'Child Issues: Number of children who were:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1000, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCBirthInfo
						WHERE BirthWtLbs <= 4 or (BirthWtLbs = 5 and BirthWtOz < 8)
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1000, 'B50', 'Born at low birth weight, less than 2500 grams or 5lbs 8oz', 0, 0,
		(	SELECT COUNT(*) FROM @tblTCBirthInfo
						WHERE BirthWtLbs <= 4 or (BirthWtLbs = 5 and BirthWtOz < 8))
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1010, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblTCBirthInfo
		WHERE GestationalAge < 37
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1010, 'B50', 'Born premature, born before 37 weeks completed', 0, 0,
		(SELECT COUNT(*) FROM @tblTCBirthInfo WHERE GestationalAge < 37)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1020, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblASQ WHERE UnderCommunication = 1 or UnderFineMotor = 1 
		or UnderGrossMotor = 1 or UnderPersonalSocial = 1 or UnderProblemSolving = 1
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1020, 'B50', 'Developmentally delayed or disabled (known or suspected)', 0, 0,
		(SELECT COUNT(distinct tcidfk) FROM @tblASQ WHERE UnderCommunication = 1 or UnderFineMotor = 1 
		or UnderGrossMotor = 1 or UnderPersonalSocial = 1 or UnderProblemSolving = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1030, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid WHERE tpid.hvcasefk in (
		SELECT DISTINCT hvcasefk FROM @tblPC1Insurance 
				WHERE AvailableMonthlyIncome <= 1558 + ((NumberInHouse - 1) * 555) --children to 18
				
				--WHERE AvailableMonthlyIncome <= 2257 + ((NumberInHouse - 1) * 803)  --children up to one year
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1030, 'B50', 'Medicaid eligible', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE tfe.RowNumber = 1030 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(1040, NULL, 'PC1 Age at Enrollment:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1045, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) < 18
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1045, 'B51', 'Less than 18', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1045 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1050, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 18 and (datediff(dd, PCDOB, IntakeDate)/365) <= 19
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1050, 'B51', '18-19 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1050 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1060, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 20 and (datediff(dd, PCDOB, IntakeDate)/365) <= 21
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1060, 'B51', '20-21 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1060 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1070, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 22 and (datediff(dd, PCDOB, IntakeDate)/365) <= 24
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1070, 'B51', '22-24 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1070 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1080, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 25 and (datediff(dd, PCDOB, IntakeDate)/365) <= 29
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1080, 'B51', '25-29 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1080 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1090, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 30 and (datediff(dd, PCDOB, IntakeDate)/365) <= 34
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1090, 'B51', '30-34 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1090 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1100, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 35 and (datediff(dd, PCDOB, IntakeDate)/365) <= 44
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1100, 'B51', '35-44 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1100 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1110, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 45 and (datediff(dd, PCDOB, IntakeDate)/365) <= 54
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1110, 'B51', '45-54 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1110 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1120, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 55 and (datediff(dd, PCDOB, IntakeDate)/365) <= 64
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1120, 'B51', '55-64 years', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1120 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1125, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (datediff(dd, PCDOB, IntakeDate)/365) >= 65
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1125, 'B51', '65 or more', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1125 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1130, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE PCDOB is null
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1130, 'B51', 'Unknown', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1130 and Detail = 1)
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(1140, NULL, 'Ethnicity: Number of Primary Participants who are:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1150, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '03'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1150, 'B52', 'Hispanic', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1150 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1160, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race <> '03'
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1160, 'B52', 'Non-Hispanic', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1160 and Detail = 1) 
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1165, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE (Race is null or Race = '') and (Ethnicity is null or Ethnicity = '')
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1165, 'B52', 'Unknown', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1165 and Detail = 1) 
    )
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) 
VALUES(1170, NULL, 'Race: Number of Primary Participants who are:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1180, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		 SELECT hvcasefk FROM @tblHomeVisits
		 WHERE Race = '01'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1180, 'B53', 'White', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1180 and Detail = 1) 
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1190, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '02'
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1190, 'B53', 'African-American', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1190 and Detail = 1)  
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1200, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '04'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1200, 'B53', 'Asian', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1200 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1210, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '05'
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1210, 'B53', 'American Indian/Alaskan Native', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1210 and Detail = 1) 
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(1220, 'B53', 'Native Hawaiian/Pacific Islander', 0, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1230, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '06'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1230, 'B53', 'Multi-race', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1230 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1240, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race is null or Race = ' ' 
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1240, 'B53', 'Unknown', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1240 and Detail = 1) 
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1250, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblHomeVisits
		WHERE Race = '07'
	)
	
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1250, 'B53', 'Other race', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1250 and Detail = 1)  
	)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(1260, 'B53', 'Other race specify', 0, 0)
-----------------
INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) VALUES(1270, NULL, 'Primary Participant Language:', 1, 0)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1280, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblIntakeInfo
		WHERE PrimaryLanguage = '01'
	)

	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1280, 'B54', 'Primary Language English', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1280 and Detail = 1) 
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1290, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblIntakeInfo
		WHERE PrimaryLanguage = '02'
	)
		
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1290, 'B54', 'Primary Language Spanish', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1290 and Detail = 1)
	)
-----------------
	INSERT INTO @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	SELECT 1300, tpid.PC1ID, 0, 1
	FROM @tblPC1IDs tpid
	WHERE tpid.hvcasefk in (
		SELECT hvcasefk FROM @tblIntakeInfo
		WHERE PrimaryLanguage = '03'
	)
	INSERT INTO @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail, Response) 
	VALUES(1300, 'B54', 'Primary Language not English nor Spanish', 0, 0,
		(SELECT COUNT(*) FROM @tblFinalExport tfe WHERE RowNumber = 1300 and Detail = 1) 
	)
-----------------
				
SELECT * FROM @tblFinalExport ORDER BY RowNumber ASC, Detail ASC


end
GO
