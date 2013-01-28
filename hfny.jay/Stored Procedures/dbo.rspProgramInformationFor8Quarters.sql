
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <January 4th, 2013>
-- Description:	<gets you data for Quarterly report i.e. J. Program Information for 8 Quarters>
-- exec [rspProgramInformationFor8Quarters] '5','03/31/13'
-- exec [rspProgramInformationFor8Quarters] '5','12/31/12'
-- exec [rspProgramInformationFor8Quarters] '5','06/30/12'
--

-- =============================================
CREATE procedure [dbo].[rspProgramInformationFor8Quarters](@programfk    varchar(max)    = null,                                                       
                                                        @edate        DATETIME,
                                                        @sitefk int             = 0,
                                                        @casefilterspositive  varchar(100) = ''  
                                                        )

as
BEGIN




    if (@ProgramFK IS not NULL) 
    BEGIN 
		set @ProgramFK = REPLACE(@ProgramFK,',','') -- remove comma's
	END 

	set @ProgramFK = REPLACE(@ProgramFK,'"','')	
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end


---- create a table that will be filled in with data at the end
DECLARE @tblQ8ReportMain TABLE(
			 QuarterNumber  [int]
			, QuarterEndDate [varchar](200) NULL
			, numberOfScreens [varchar](200) NULL		 
			, numberOfKempAssessments [varchar](200) NULL
			, KempPositivePercentage [varchar](200) NULL
			, KempPositiveEnrolled [varchar](200) NULL
			, KempPositivePending [varchar](200) NULL
			, KempPositiveTerminated [varchar](200) NULL
			, AvgPositiveMotherScore [varchar](200) NULL
			, EnrolledAtBeginningOfQrtr [varchar](200) NULL
			, NewEnrollmentsThisQuarter [varchar](200) NULL
			, NewEnrollmentsPrenatal [varchar](200) NULL
			, TANFServicesEligible [varchar](200) NULL
			, FamiliesDischargedThisQuarter [varchar](200) NULL
			, FamiliesCompletingProgramThisQuarter [varchar](200) NULL
			, FamiliesActiveAtEndOfThisQuarter [varchar](200) NULL
			, FamiliesActiveAtEndOfThisQuarterOnLevel1 [varchar](200) NULL
			, FamiliesActiveAtEndOfThisQuarterOnLevelX [varchar](200) NULL
			, FamiliesWithNoServiceReferrals [varchar](200) NULL
			, AverageVisitsPerMonthPerCase [varchar](200) NULL
			, TotalServedInQuarterIncludesClosedCases [varchar](200) NULL
			, AverageVisitsPerFamily [varchar](200) NULL
			, TANFServicesEligibleAtEnrollment [varchar](200) NULL
			, rowBlankforItem9 [varchar](200) NULL			
			, LengthInProgramUnder6Months [varchar](200) NULL
			, LengthInProgramUnder6MonthsTo1Year [varchar](200) NULL
			, LengthInProgramUnder1YearTo2Year [varchar](200) NULL
			, LengthInProgramUnder2YearsAndOver [varchar](200) NULL						
)	





-- Create 8 quarters given a starting quarter end date
DECLARE @tblMake8Quarter TABLE(
	[QuarterNumber] [int],
	[QuarterStartDate] [date],
	[QuarterEndDate] [date]
)

INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 8, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-3,@edate) )+1,0))), @edate AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 7, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-6,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-3,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 6, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-9,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-6,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 5, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-12,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-9,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 4, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-15,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-12,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 3, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-18,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-15,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 2, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-21,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-18,@edate) )+1,0)) AS QuarterEndDate
INSERT INTO @tblMake8Quarter([QuarterNumber],[QuarterStartDate],[QuarterEndDate])SELECT 1, DATEADD(dd,1,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-24,@edate) )+1,0))), DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, DATEADD(mm,-21,@edate) )+1,0)) AS QuarterEndDate

-- SELECT * FROM @tblMake8Quarter  -- equivalent to csr8q cursor
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'


---- ***************** ----
-- Please use Pivot to change columns to rows (hint Pivoted on RowNumber) --- .... khalsa
---- ***************** ----

-- Create a Summary table, where we will store values of all 8 quarters
DECLARE @tblMain8Quarters TABLE(
	[RowNumber] [int],
	[Title] VARCHAR(250),
	[LastDayOfQuarter1] VARCHAR(10),
	[LastDayOfQuarter2] VARCHAR(10),
	[LastDayOfQuarter3] VARCHAR(10),
	[LastDayOfQuarter4] VARCHAR(10),
	[LastDayOfQuarter5] VARCHAR(10),
	[LastDayOfQuarter6] VARCHAR(10),
	[LastDayOfQuarter7] VARCHAR(10),
	[LastDayOfQuarter8] VARCHAR(10)	
)


-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- We will use this cohort starting item # 3
DECLARE @tblInitial_cohort TABLE(
			[HVCasePK] [int],
			[CaseProgress] [numeric](3, 1) NULL,
			[Confidentiality] [bit] NULL,
			[CPFK] [int] NULL,
			[DateOBPAdded] [datetime] NULL,
			[EDC] [datetime] NULL,
			[FFFK] [int] NULL,
			[FirstChildDOB] [datetime] NULL,
			[FirstPrenatalCareVisit] [datetime] NULL,
			[FirstPrenatalCareVisitUnknown] [bit] NULL,
			[HVCaseCreateDate] [datetime] NOT NULL,
			[HVCaseCreator] [char](10) NOT NULL,
			[HVCaseEditDate] [datetime] NULL,
			[HVCaseEditor] [char](10) NULL,
			[InitialZip] [char](10) NULL,
			[IntakeDate] [datetime] NULL,
			[IntakeLevel] [char](1) NULL,
			[IntakeWorkerFK] [int] NULL,
			[KempeDate] [datetime] NULL,
			[OBPInformationAvailable] [bit] NULL,
			[OBPFK] [int] NULL,
			[OBPinHomeIntake] [bit] NULL,
			[OBPRelation2TC] [char](2) NULL,
			[PC1FK] [int] NOT NULL,
			[PC1Relation2TC] [char](2) NULL,
			[PC1Relation2TCSpecify] [varchar](30) NULL,
			[PC2FK] [int] NULL,
			[PC2inHomeIntake] [bit] NULL,
			[PC2Relation2TC] [char](2) NULL,
			[PC2Relation2TCSpecify] [varchar](30) NULL,
			[PrenatalCheckupsB4] [int] NULL,
			[ScreenDate] [datetime] NOT NULL,
			[TCDOB] [datetime] NULL,
			[TCDOD] [datetime] NULL,
			[TCNumber] [int] NULL,
			
			[CaseProgramPK] [int],
			[CaseProgramCreateDate] [datetime] NOT NULL,
			[CaseProgramCreator] [char](10) NOT NULL,
			[CaseProgramEditDate] [datetime] NULL,
			[CaseProgramEditor] [char](10) NULL,
			[CaseStartDate] [datetime] NOT NULL,
			[CurrentFAFK] [int] NULL,
			[CurrentFAWFK] [int] NULL,
			[CurrentFSWFK] [int] NULL,
			[CurrentLevelDate] [datetime] NOT NULL,
			[CurrentLevelFK] [int] NOT NULL,
			[DischargeDate] [datetime] NULL,
			[DischargeReason] [char](2) NULL,
			[DischargeReasonSpecify] [varchar](500) NULL,
			[ExtraField1] [char](30) NULL,
			[ExtraField2] [char](30) NULL,
			[ExtraField3] [char](30) NULL,
			[ExtraField4] [char](30) NULL,
			[ExtraField5] [char](30) NULL,
			[ExtraField6] [char](30) NULL,
			[ExtraField7] [char](30) NULL,
			[ExtraField8] [char](30) NULL,
			[ExtraField9] [char](30) NULL,
			[HVCaseFK] [int] NOT NULL,
			[HVCaseFK_old] [int] NOT NULL,
			[OldID] [char](23) NULL,
			[PC1ID] [char](13) NOT NULL,
			[ProgramFK] [int] NOT NULL,
			[TransferredtoProgram] [varchar](30) NULL,
			[TransferredtoProgramFK] [int] NULL,
			
			[CalcTCDOB] [datetime] NULL			
			
			
)


INSERT INTO @tblInitial_cohort
		SELECT 
			[HVCasePK],
			[CaseProgress],
			[Confidentiality],
			[CPFK],
			[DateOBPAdded],
			[EDC],
			[FFFK],
			[FirstChildDOB],
			[FirstPrenatalCareVisit],
			[FirstPrenatalCareVisitUnknown],
			[HVCaseCreateDate],
			[HVCaseCreator],
			[HVCaseEditDate],
			[HVCaseEditor],
			[InitialZip],
			[IntakeDate],
			[IntakeLevel],
			[IntakeWorkerFK],
			[KempeDate],
			[OBPInformationAvailable],
			[OBPFK],
			[OBPinHomeIntake],
			[OBPRelation2TC],
			[PC1FK],
			[PC1Relation2TC],
			[PC1Relation2TCSpecify],
			[PC2FK],
			[PC2inHomeIntake],
			[PC2Relation2TC],
			[PC2Relation2TCSpecify],
			[PrenatalCheckupsB4],
			[ScreenDate],
			[TCDOB],
			[TCDOD],
			[TCNumber],
			
			[CaseProgramPK],
			[CaseProgramCreateDate],
			[CaseProgramCreator],
			[CaseProgramEditDate],
			[CaseProgramEditor],
			[CaseStartDate],
			[CurrentFAFK],
			[CurrentFAWFK],
			[CurrentFSWFK],
			[CurrentLevelDate],
			[CurrentLevelFK],
			[DischargeDate],
			[DischargeReason],
			[DischargeReasonSpecify],
			[ExtraField1],
			[ExtraField2],
			[ExtraField3],
			[ExtraField4],
			[ExtraField5],
			[ExtraField6],
			[ExtraField7],
			[ExtraField8],
			[ExtraField9],
			cp.[HVCaseFK],
			[HVCaseFK_old],
			[OldID],
			[PC1ID],
			cp.[ProgramFK],
			[TransferredtoProgram],
			[TransferredtoProgramFK],
			
			case
			  when h.tcdob is not null then
				  h.tcdob
			  else
				  h.edc
		    end as [CalcTCDOB]
				
		
		FROM HVCase h           
			inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
			WHERE 
			case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1
			AND 
			cp.CaseStartDate <= @edate



	
	;
	-- 1
	WITH cteScreensFor1 AS
	(	-- "1. Total Screens"
		-- Screens Row 1
	SELECT DISTINCT QuarterNumber,  count(*) over (partition by [QuarterNumber]) as 'numberOfScreens'
		from @tblInitial_cohort h			
			INNER JOIN @tblMake8Quarter q8 ON h.screendate between [QuarterStartDate] and [QuarterEndDate]
	),		

	-- 2
	cteKempAssessmentsFor2 AS
	(	-- "2. Total Kempe Assessments"
		-- Kempe Assessment Row 2
	SELECT DISTINCT QuarterNumber,  count(*) over (partition by [QuarterNumber]) as 'numberOfKempAssessments'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),		

	-- 2a
	cteKempAssessments_For2a AS
	( 	
	-- Kempe Assessment Percentage
	-- It will be done in two steps i.e. 1. Get numbers like KempPositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
	SELECT DISTINCT q8.QuarterNumber
			,count(h.HVCasePK) OVER(PARTITION BY [QuarterNumber]) AS 'TotalKemp'
			,SUM(CASE WHEN k.KempeResult = 1 THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositive'			
			from @tblInitial_cohort h
			LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN @tblMake8Quarter q8 ON h.KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),	
	
	cteKempAssessments_For2a_Calc_Percentage AS
			(	-- "    a. % Positive" 
				-- Kempe Assessment Percentage Row 3				
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,KempPositive) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(KempPositive AS FLOAT) * 100/ NULLIF(TotalKemp,0), 0), 0))  + '%)'	AS KempPositivePercentage
			 FROM cteKempAssessments_For2a
	),		

	-- 2a1
	cteKempAssessments_For2a_1 AS
	( 
	-- Kempe Assessment Percentage - Positive Enrolled
	-- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
	SELECT DISTINCT q8.QuarterNumber	
			,SUM(CASE WHEN ((k.KempeResult = 1) AND (h.IntakeDate IS NOT NULL AND h.IntakeDate <> '' )) THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositiveEnrolled'	
			,SUM(CASE WHEN k.KempeResult = 1 THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositive'			
			from @tblInitial_cohort h
			LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN @tblMake8Quarter q8 ON h.KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),
	
	cteKempAssessments_For2a_1_Calc_Percentage AS
			(	-- "        1. % Positive Enrolled" 
				-- Kempe Assessment Percentage Row 3				
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,KempPositiveEnrolled) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(KempPositiveEnrolled AS FLOAT) * 100/ NULLIF(KempPositive,0), 0), 0))  + '%)'	AS KempPositiveEnrolled
			 FROM cteKempAssessments_For2a_1
	),		

	-- 2a2
	cteKempAssessments_For2a_2 AS
	( 
	-- Kempe Assessment Percentage - Positive Pending Enrollment
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
	SELECT DISTINCT q8.QuarterNumber	
			,SUM(CASE WHEN ((k.KempeResult = 1) AND (h.DischargeDate IS NULL AND h.IntakeDate IS NULL )) THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositivePending'	
			,SUM(CASE WHEN k.KempeResult = 1 THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositive'			
			from @tblInitial_cohort h
			LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN @tblMake8Quarter q8 ON h.KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),
	
	cteKempAssessments_For2a_2_Calc_Percentage AS
			(	--	"        2. % Positive Pending Enrollment" 
				-- Kempe Assessment Percentage Row 3				
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,KempPositivePending) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(KempPositivePending AS FLOAT) * 100/ NULLIF(KempPositive,0), 0), 0))  + '%)'	AS KempPositivePending
			 FROM cteKempAssessments_For2a_2
	),		

	-- 2a3
	cteKempAssessments_For2a_3 AS
	( 
	-- Kempe Assessment Percentage - Positive Terminated
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
	SELECT DISTINCT q8.QuarterNumber	
			,SUM(CASE WHEN ((k.KempeResult = 1) AND (h.DischargeDate IS NOT NULL AND h.IntakeDate IS NULL )) THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositiveTerminated'	
			,SUM(CASE WHEN k.KempeResult = 1 THEN 1 ELSE 0 END ) OVER(PARTITION BY [QuarterNumber]) AS 'KempPositive'			
			from @tblInitial_cohort h
			LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN @tblMake8Quarter q8 ON h.KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),
	
	cteKempAssessments_For2a_3_Calc_Percentage AS
			( --"        3. % Positive Terminated"
			  -- Kempe Assessment Percentage Row 3				
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,KempPositiveTerminated) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(KempPositiveTerminated AS FLOAT) * 100/ NULLIF(KempPositive,0), 0), 0))  + '%)'	AS KempPositiveTerminated
			 FROM cteKempAssessments_For2a_3
	),		

	-- 2b
	cteKempAssessments_For2b AS
	( -- "    b. Average Positive Mother Score"
	-- MomScore
	SELECT DISTINCT q8.QuarterNumber	
			,avg(case when k.MomScore = 'U' then 0 else cast(k.MomScore as DECIMAL) END) OVER(PARTITION BY [QuarterNumber]) AS 'AvgPositiveMotherScore' 
			from @tblInitial_cohort h
			LEFT JOIN Kempe k ON k.HVCaseFK = h.HVCasePK AND k.KempeResult = 1 -- keeping 'k.KempeResult = 1' it here (not as in where clause down), it saved 3 seconds of execution time ... Khalsa
			INNER JOIN @tblMake8Quarter q8 ON h.KempeDate between [QuarterStartDate] and [QuarterEndDate]
	),
	
	-- 3
	cteEnrolledAtBeginingOfQuarter3 AS
	( -- 3. Families Enrolled at Beginning of quarter
		
			SELECT DISTINCT QuarterNumber,  count(HVCasePK) over (partition by [QuarterNumber]) as 'EnrolledAtBeginningOfQrtr'
			from @tblInitial_cohort ic
			INNER JOIN @tblMake8Quarter q8 ON ic.IntakeDate <= [QuarterStartDate] AND ic.IntakeDate IS NOT NULL 
			AND (ic.DischargeDate >= [QuarterStartDate] OR ic.DischargeDate IS NULL)
	
	),
	
	-- 4
	cteNewEnrollmentsThisQuarter4 AS
	( -- "4. New Enrollments this quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]	

	),	
	
	--- 4a
	cteNewEnrollmentsThisQuarter4Again AS
	( -- We will use this one in cteNewEnrollmentsThisQuarter4a. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]	

	),				

	cteNewEnrollmentsThisQuarter4a AS
	( 
	-- "    a. % Prenatal"
	-- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
		SELECT DISTINCT q8.QuarterNumber
		  ,count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'NewEnrollmentsPrenatal'
		  , q8Again.NewEnrollmentsThisQuarter AS NewEnrollmentsThisQuarter
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
			INNER JOIN cteNewEnrollmentsThisQuarter4Again q8Again ON q8Again.QuarterNumber = q8.QuarterNumber
			WHERE h.[CalcTCDOB] > IntakeDate 

	),
	
	cteNewEnrollmentsThisQuarter4a_Calc_Percentage AS		
	(
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,NewEnrollmentsPrenatal) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(NewEnrollmentsPrenatal AS FLOAT) * 100/ NULLIF(NewEnrollmentsThisQuarter,0), 0), 0))  + '%)'	AS NewEnrollmentsPrenatal
			 FROM cteNewEnrollmentsThisQuarter4a
	),	
	
	--- 4b
	cteNewEnrollmentsThisQuarter4Again2 AS
	( -- We will use this one in cteNewEnrollmentsThisQuarter4b. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]	

	),
		
	cteNewEnrollmentsThisQuarter4b AS
	( -- "    b. % TANF Services Eligible at Enrollment**"
		
		SELECT DISTINCT q8.QuarterNumber 
		,count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
		, q8Again2.NewEnrollmentsThisQuarter
		
		from @tblInitial_cohort h 
			INNER JOIN CommonAttributes ca ON ca.HVCaseFK = h.HVCaseFK			
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]	
			INNER JOIN cteNewEnrollmentsThisQuarter4Again2 q8Again2 ON q8Again2.QuarterNumber = q8.QuarterNumber
		WHERE ca.TANFServices = 1
		AND 
		ca.FormType = 'IN'  -- only from Intake form here
		
	),
	
	cteNewEnrollmentsThisQuarter4b_Calc_Percentage AS		
	(
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,TANFServicesEligible) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TANFServicesEligible AS FLOAT) * 100/ NULLIF(NewEnrollmentsThisQuarter,0), 0), 0))  + '%)'	AS TANFServicesEligible
			 FROM cteNewEnrollmentsThisQuarter4b
	),	
	
	-- 5
	cteFamiliesDischargedThisQuarter5 AS
	( -- "5. Families Discharged this quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesDischargedThisQuarter'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]	
			WHERE h.IntakeDate IS NOT NULL

	),	
	
	-- 5a
	cteFamiliesCompletingProgramThisQuarter5a AS
	( -- "    a. Families completing the program"
		-- Discharged after completing the program through Discharge Form
		SELECT DISTINCT QuarterNumber,  sum(
		CASE WHEN DischargeReason IN (27,29) THEN 1 ELSE 0 END 		
		) over (partition by [QuarterNumber]) as 'FamiliesCompletingProgramThisQuarter'
		from @tblInitial_cohort h
			INNER JOIN @tblMake8Quarter q8 ON h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]	
			WHERE h.IntakeDate IS NOT NULL

	),	
	-- 6
	cteFamiliesActiveAtEndOfThisQuarter6 AS
	( -- "6. Families Active at end of this Quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterEndDate)		
	),	
	
	-- 6a
	cteFamiliesActiveAtEndOfThisQuarter6Again AS
	( -- "6. Families Active at end of this Quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterEndDate)		
	),		
	
	
	cteFamiliesActiveAtEndOfThisQuarter6a AS
	( -- "    a. % on Level 1 at end of Quarter"
		
		SELECT DISTINCT q8.QuarterNumber
			, count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
			, q86a.FamiliesActiveAtEndOfThisQuarter AS FamiliesActiveAtEndOfThisQuarter
		from @tblInitial_cohort h 		
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				INNER JOIN cteFamiliesActiveAtEndOfThisQuarter6Again q86a ON q86a.QuarterNumber = q8.QuarterNumber	
				
				LEFT JOIN HVLevelDetail hd ON hd.hvcasefk = h.hvcasefk
				
							
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate > QuarterEndDate)
				AND ((q8.QuarterEndDate BETWEEN hd.StartLevelDate AND hd.EndLevelDate) OR (q8.QuarterEndDate >= hd.StartLevelDate AND hd.EndLevelDate is NULL))  -- note: they still may be on level 1
				AND LevelName IN ('Level 1', 'Level 1-SS')	
					
	),
	
	cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage AS		
	(
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,FamiliesActiveAtEndOfThisQuarterOnLevel1) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(FamiliesActiveAtEndOfThisQuarterOnLevel1 AS FLOAT) * 100/ NULLIF(FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS FamiliesActiveAtEndOfThisQuarterOnLevel1
			 FROM cteFamiliesActiveAtEndOfThisQuarter6a
	),	
	
	-- 6b
	cteFamiliesActiveAtEndOfThisQuarter6Again2 AS
	( -- "    b. % on Level X at end of Quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterEndDate)		
	),		
	
	
	cteFamiliesActiveAtEndOfThisQuarter6b AS
	( -- "    b. % on Level X at end of Quarter"
		
		SELECT DISTINCT q8.QuarterNumber
			, count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevelX'
			, q86b.FamiliesActiveAtEndOfThisQuarter AS FamiliesActiveAtEndOfThisQuarter
		from @tblInitial_cohort h 		
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				INNER JOIN cteFamiliesActiveAtEndOfThisQuarter6Again2 q86b ON q86b.QuarterNumber = q8.QuarterNumber	
				
				LEFT JOIN HVLevelDetail hd ON hd.hvcasefk = h.hvcasefk
				
							
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate > QuarterEndDate)
				AND (q8.QuarterEndDate BETWEEN hd.StartLevelDate AND hd.EndLevelDate)
				AND hd.LevelName like 'Level X'
				
					
	),		
	
	
	cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters AS
	( -- "    b. % on Level X at end of Quarter"
		
		
		SELECT isnull(f6bmissing.QuarterNumber,q8.QuarterNumber) AS QuarterNumber
			 , isnull(FamiliesActiveAtEndOfThisQuarterOnLevelX, 0) AS FamiliesActiveAtEndOfThisQuarterOnLevelX
			 , isnull(FamiliesActiveAtEndOfThisQuarter, 0) AS FamiliesActiveAtEndOfThisQuarter

		 FROM cteFamiliesActiveAtEndOfThisQuarter6b f6bmissing
		RIGHT JOIN @tblMake8Quarter q8 ON q8.QuarterNumber = f6bmissing.QuarterNumber
					
	),	
	
	cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage AS		
	(
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,FamiliesActiveAtEndOfThisQuarterOnLevelX) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(FamiliesActiveAtEndOfThisQuarterOnLevelX AS FLOAT) * 100/ NULLIF(FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS FamiliesActiveAtEndOfThisQuarterOnLevelX
			 FROM cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
	),	
	
	-- 6c
	cteFamiliesActiveAtEndOfThisQuarter6Again3 AS
	( -- "6. Families Active at end of this Quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterEndDate)		
	),		
	
	
	cteFamiliesWithNoServiceReferrals6c AS
	( -- "    c. % Families with no Service Referrals"
	  -- Find those records (hvcasepk) that are in cteFamiliesActiveAtEndOfThisQuarter6 but does not have Service Referral in table i.e.ServiceReferral
		
		SELECT DISTINCT q8.QuarterNumber		
				, count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesWithNoServiceReferrals'
		
		from @tblInitial_cohort h 
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				LEFT JOIN  ServiceReferral sr on sr.HVCaseFK = h.HVCaseFK AND (ReferralDate <= [QuarterEndDate]) -- leave it here the extra condition
				WHERE h.IntakeDate IS NOT NULL 	
				AND h.IntakeDate <= [QuarterEndDate]				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= [QuarterEndDate]	)
				AND ReferralDate IS NULL  -- This is important

	),		
	
	cteFamiliesWithNoServiceReferrals6cMerge AS
	( -- "    c. % Families with no Service Referrals"
	  -- Note: There are quarters which are missing in cteFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
	  -- therefore, we need  to merge to bring back missing quarters
		
		SELECT a.QuarterNumber
			 , FamiliesActiveAtEndOfThisQuarter			 
			 , CASE WHEN FamiliesWithNoServiceReferrals > 0 THEN FamiliesWithNoServiceReferrals ELSE 0 END AS FamiliesWithNoServiceReferrals
			 
			  FROM cteFamiliesActiveAtEndOfThisQuarter6Again3 a		
			LEFT JOIN cteFamiliesWithNoServiceReferrals6c b ON a.QuarterNumber = b.QuarterNumber

	),
	
	cteFamiliesWithNoServiceReferrals6c_Calc_Percentage AS		
	(
			SELECT QuarterNumber		
				,CONVERT(VARCHAR,FamiliesWithNoServiceReferrals) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(FamiliesWithNoServiceReferrals AS FLOAT) * 100/ NULLIF(FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS FamiliesWithNoServiceReferrals
			 FROM cteFamiliesWithNoServiceReferrals6cMerge
	),	
	
	-- 7	
	
	cteFamiliesActiveAtEndOfThisQuarter7LevelRate AS -- calculate level for each case
	( -- "7. Average Visits per Month per Case on Level 1"
		
		SELECT DISTINCT q8.QuarterNumber
			, count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
			
			 , 			 
			 sum(
			    CASE 
				WHEN hd.StartLevelDate <= q8.QuarterStartDate THEN 1
				WHEN  hd.StartLevelDate BETWEEN q8.QuarterStartDate AND q8.QuarterEndDate THEN 			
				
					round(COALESCE(cast(DATEDIFF(dd, hd.StartLevelDate, q8.QuarterEndDate) AS FLOAT) * 100/ NULLIF(datediff(dd,q8.QuarterStartDate,q8.QuarterEndDate),0), 0), 0) / 100

				ELSE 0
				END
				)
				over (partition by q8.[QuarterNumber]) AS 'TotalLevelRate'
				
			 
		from @tblInitial_cohort h 		
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				
				LEFT JOIN HVLevelDetail hd ON hd.hvcasefk = h.hvcasefk
				
							
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate > QuarterEndDate)
				AND ((q8.QuarterEndDate BETWEEN hd.StartLevelDate AND hd.EndLevelDate) OR (q8.QuarterEndDate >= hd.StartLevelDate AND hd.EndLevelDate is NULL))  -- note: they still may be on level 1
				AND LevelName IN ('Level 1', 'Level 1-SS')	
				
				
					
	),
	
	cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits AS -- calculate visits per case
	( -- "7. Average Visits per Month per Case on Level 1"

		SELECT DISTINCT q8.QuarterNumber
			, count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
			,
			sum(		CASE 
						WHEN hd.StartLevelDate <= q8.QuarterStartDate THEN 1    -- count(hvcasepk) over (partition by q8.QuarterNumber) -- count of num of visits for the entire quarter if he was on level 1 before quarterstart
						WHEN VisitStartTime  BETWEEN hd.StartLevelDate AND q8.QuarterEndDate THEN 
							1
						ELSE 0
						END
						
				) over (partition by q8.[QuarterNumber]) AS 'TotalVisitRate'
						
					from @tblInitial_cohort h 	
							
							LEFT JOIN HVLevelDetail hd ON hd.hvcasefk = h.hvcasefk
							left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
										   
							INNER JOIN @tblMake8Quarter q8 ON hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate 	
										
							WHERE h.IntakeDate IS NOT NULL 				
							AND (h.DischargeDate IS NULL OR h.DischargeDate > QuarterEndDate)
							AND ((q8.QuarterEndDate BETWEEN hd.StartLevelDate AND hd.EndLevelDate) OR (q8.QuarterEndDate >= hd.StartLevelDate AND hd.EndLevelDate is NULL))  -- note: they still may be on level 1
							AND LevelName IN ('Level 1', 'Level 1-SS')	
							
					
	
	),
		
	cteFamiliesActiveAtEndOfThisQuarter7 AS -- calculate visits per case
		( -- "7. Average Visits per Month per Case on Level 1"	
		SELECT lr.QuarterNumber
			 --, lr.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalLevelRate
			 ----, nv.QuarterNumber
			 --, nv.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalVisitRate
			 --, ( TotalVisitRate / (3 * TotalLevelRate) ) AS AverageVisitsPerMonthPerCase
			 , round(COALESCE(cast(TotalVisitRate AS FLOAT) * 100/ NULLIF(3 * TotalLevelRate,0), 0), 0) / 100 AS AverageVisitsPerMonthPerCase

			 
			  FROM cteFamiliesActiveAtEndOfThisQuarter7LevelRate lr		 
			INNER JOIN cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits nv ON nv.QuarterNumber = lr.QuarterNumber
	),	
	
	-- 8
	cteTotalServedInQuarterIncludesClosedCases8 AS
	( -- "8. Total Served in Quarter(includes closed cases)"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalServedInQuarterIncludesClosedCases'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterStartDate) -- not discharged or discharged after the quarter start date		
	),
	
	-- 8a
	cteAllFamilies8AgainFor8a AS
	( -- "8    a. Average Visits per Family"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterStartDate) -- not discharged or discharged after the quarter start date		
	),
	
	cteAllFamilies8aVisits AS
	( -- "8    a. Average Visits per Family"
	
		SELECT  DISTINCT QuarterNumber,  count(HVLog.HVLogPK) over (partition by [QuarterNumber]) as 'TotalHVlogActivities'
					from @tblInitial_cohort h 	
							
							LEFT JOIN HVLevelDetail hd ON hd.hvcasefk = h.hvcasefk
							left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
										   
							INNER JOIN @tblMake8Quarter q8 ON hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate 
			
				WHERE h.IntakeDate IS NOT NULL 		
				AND h.IntakeDate <= q8.[QuarterEndDate]			
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= [QuarterStartDate]) -- not discharged or discharged after the quarter start date	
				AND HVLog.VisitType <> '0001'		
	),

	cteAverageVisitsPerFamily8a AS
	(  -- "8    a. Average Visits per Family"
	
		SELECT lr.QuarterNumber
			 --, TotalFamiliesServed
			 ----, nv.QuarterNumber
			 --, TotalHVlogActivities		
			 , round(COALESCE(cast(TotalHVlogActivities AS FLOAT) * 100/ NULLIF(3 * TotalFamiliesServed,0), 0), 0) / 100 AS AverageVisitsPerFamily

			 
			  FROM cteAllFamilies8AgainFor8a lr		 
			INNER JOIN cteAllFamilies8aVisits nv ON nv.QuarterNumber = lr.QuarterNumber	
	
	
	),	
	
	-- 8b	
	cteAllFamilies8AgainFor8b AS
	( -- "8    a. Average Visits per Family"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterStartDate) -- not discharged or discharged after the quarter start date		
	),	
	
	
	-- 8b
	cteAverageVisitsPerFamily8b AS
	(  -- "8    b. % TANF Services Eligible at enrollment**"
	
		SELECT DISTINCT q8.QuarterNumber 
		,count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
		, q8b.TotalFamiliesServed
		
		from @tblInitial_cohort h 
			INNER JOIN CommonAttributes ca ON ca.HVCaseFK = h.HVCaseFK			
			INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
			INNER JOIN cteAllFamilies8AgainFor8b q8b ON q8b.QuarterNumber = q8.QuarterNumber
		WHERE 
		 h.IntakeDate IS NOT NULL 				
		 AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterStartDate) -- not discharged or discharged after the quarter start date	
		 AND 
		ca.TANFServices = 1
		AND 
		ca.FormType = 'IN'  -- only from Intake form here	
	
	),
	-- 8b
	cteAverageVisitsPerFamily8bFinal AS
	(  -- "8    b. % TANF Services Eligible at enrollment**"

		SELECT QuarterNumber
			,CONVERT(VARCHAR,TANFServicesEligible) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(TANFServicesEligible AS FLOAT) * 100/ NULLIF(TotalFamiliesServed,0), 0), 0))  + '%)'	AS TANFServicesEligibleAtEnrollment
			 
			 FROM cteAverageVisitsPerFamily8b
	),	
		
	-- 9
	cteLengthInProgram9 AS
	( -- "9. Length in Program for Active at End of Quarter"
		
		SELECT 
			q8.QuarterNumber
			, CASE WHEN ( datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) BETWEEN 0 AND 182 ) THEN 1 ELSE 0 END  as 'LengthInProgramUnder6Months'
			, CASE WHEN ( datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) BETWEEN 183 AND 365 ) THEN 1 ELSE 0 END  as 'LengthInProgramUnder6MonthsTo1Year'
			, CASE WHEN ( datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) BETWEEN 366 AND 730 ) THEN 1 ELSE 0 END  as 'LengthInProgramUnder1YearTo2Year'
			, CASE WHEN ( datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) > 730 ) THEN 1 ELSE 0 END  as 'LengthInProgramUnder2YearsAndOver'
				
			
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate > [QuarterEndDate] ) -- active cases			
				
	),
		
	cteLengthInProgram9Sum AS
	( -- "9. Length in Program for Active at End of Quarter"
		
		SELECT DISTINCT QuarterNumber
			
			,SUM(LengthInProgramUnder6Months ) OVER(PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder6Months'	
			,SUM(LengthInProgramUnder6MonthsTo1Year ) OVER(PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder6MonthsTo1Year'	
			,SUM(LengthInProgramUnder1YearTo2Year ) OVER(PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder1YearTo2Year'	
			,SUM(LengthInProgramUnder2YearsAndOver ) OVER(PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder2YearsAndOver'
			
			 FROM cteLengthInProgram9
				
	),
			
	cteLengthInProgramAtEndOfThisQuarter9 AS
	( -- "6. Families Active at end of this Quarter"
		
		SELECT DISTINCT QuarterNumber,  count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
		from @tblInitial_cohort h
				INNER JOIN @tblMake8Quarter q8 ON h.IntakeDate <= [QuarterEndDate]	
				WHERE h.IntakeDate IS NOT NULL 				
				AND (h.DischargeDate IS NULL OR h.DischargeDate >= QuarterEndDate)		
	),			
			
				
	cteLengthInProgramFinal AS
	(  -- "9. Length in Program for Active at End of Quarter"

		SELECT cl.QuarterNumber
			,CONVERT(VARCHAR,LengthInProgramUnder6Months) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(LengthInProgramUnder6Months AS FLOAT) * 100/ NULLIF(ct.FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS LengthInProgramUnder6Months
			,CONVERT(VARCHAR,LengthInProgramUnder6MonthsTo1Year) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(LengthInProgramUnder6MonthsTo1Year AS FLOAT) * 100/ NULLIF(ct.FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS LengthInProgramUnder6MonthsTo1Year
			,CONVERT(VARCHAR,LengthInProgramUnder1YearTo2Year) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(LengthInProgramUnder1YearTo2Year AS FLOAT) * 100/ NULLIF(ct.FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS LengthInProgramUnder1YearTo2Year
			,CONVERT(VARCHAR,LengthInProgramUnder2YearsAndOver) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(LengthInProgramUnder2YearsAndOver AS FLOAT) * 100/ NULLIF(ct.FamiliesActiveAtEndOfThisQuarter,0), 0), 0))  + '%)'	AS LengthInProgramUnder2YearsAndOver
			 
			 FROM cteLengthInProgram9Sum cl
			 INNER JOIN cteLengthInProgramAtEndOfThisQuarter9 ct ON ct.QuarterNumber = cl.QuarterNumber
			 
	)			
		


-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'
--SELECT * FROM cteLengthInProgramFinal

	
	-- For report Summary - Just add the new row (add another inner join for a newly created cte for the new row in the report summary) ... Khalsa
	
	INSERT INTO @tblQ8ReportMain
	(
			 QuarterNumber
			, QuarterEndDate						
			, numberOfScreens		 
			, numberOfKempAssessments
			, KempPositivePercentage
			, KempPositiveEnrolled
			, KempPositivePending
			, KempPositiveTerminated
			, AvgPositiveMotherScore
			, EnrolledAtBeginningOfQrtr
			, NewEnrollmentsThisQuarter
			, NewEnrollmentsPrenatal
			, TANFServicesEligible
			, FamiliesDischargedThisQuarter
			, FamiliesCompletingProgramThisQuarter
			, FamiliesActiveAtEndOfThisQuarter
			, FamiliesActiveAtEndOfThisQuarterOnLevel1
			, FamiliesActiveAtEndOfThisQuarterOnLevelX
			, FamiliesWithNoServiceReferrals
			, AverageVisitsPerMonthPerCase
			, TotalServedInQuarterIncludesClosedCases
			, AverageVisitsPerFamily
			, TANFServicesEligibleAtEnrollment
			, rowBlankforItem9			
			, LengthInProgramUnder6Months
			, LengthInProgramUnder6MonthsTo1Year
			, LengthInProgramUnder1YearTo2Year
			, LengthInProgramUnder2YearsAndOver	
	)
	SELECT 
			scrns.QuarterNumber
			, LEFT(CONVERT(VARCHAR, q8.QuarterEndDate, 120), 10)AS QuarterEndDate -- convert into string
			, numberOfScreens		 
			, numberOfKempAssessments
			, q82a.KempPositivePercentage
			, q82a1.KempPositiveEnrolled
			, q82a2.KempPositivePending
			, q82a3.KempPositiveTerminated
			, convert(DECIMAL(4,1),q82b.AvgPositiveMotherScore) AS AvgPositiveMotherScore
			, q83.EnrolledAtBeginningOfQrtr
			, q84.NewEnrollmentsThisQuarter
			, q84a.NewEnrollmentsPrenatal
			, q84b.TANFServicesEligible 
			, q85.FamiliesDischargedThisQuarter
			, q85a.FamiliesCompletingProgramThisQuarter
			, q86.FamiliesActiveAtEndOfThisQuarter
			, q86a.FamiliesActiveAtEndOfThisQuarterOnLevel1
			, q86b.FamiliesActiveAtEndOfThisQuarterOnLevelX
			, q86c.FamiliesWithNoServiceReferrals
			, q87.AverageVisitsPerMonthPerCase
			, q88.TotalServedInQuarterIncludesClosedCases
			, q88a.AverageVisitsPerFamily
			, q88b.TANFServicesEligibleAtEnrollment
			, '' AS rowBlankforItem9			
			, q9.LengthInProgramUnder6Months
			, q9.LengthInProgramUnder6MonthsTo1Year
			, q9.LengthInProgramUnder1YearTo2Year
			, q9.LengthInProgramUnder2YearsAndOver						
			
			
						
			FROM cteScreensFor1 scrns
			INNER JOIN cteKempAssessmentsFor2 ka ON ka.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteKempAssessments_For2a_Calc_Percentage q82a ON q82a.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteKempAssessments_For2a_1_Calc_Percentage q82a1 ON q82a1.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteKempAssessments_For2a_2_Calc_Percentage q82a2 ON q82a2.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteKempAssessments_For2a_3_Calc_Percentage q82a3 ON q82a3.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteKempAssessments_For2b q82b ON q82b.QuarterNumber = scrns.QuarterNumber
			INNER JOIN cteEnrolledAtBeginingOfQuarter3 q83 ON q83.QuarterNumber = scrns.QuarterNumber			
			INNER JOIN cteNewEnrollmentsThisQuarter4 q84 ON q84.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteNewEnrollmentsThisQuarter4a_Calc_Percentage q84a ON q84a.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteNewEnrollmentsThisQuarter4b_Calc_Percentage q84b ON q84b.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesDischargedThisQuarter5 q85 ON q85.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesCompletingProgramThisQuarter5a q85a ON q85a.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesActiveAtEndOfThisQuarter6 q86 ON q86.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage q86a ON q86a.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage q86b ON q86b.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesWithNoServiceReferrals6c_Calc_Percentage q86c ON q86c.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteFamiliesActiveAtEndOfThisQuarter7 q87 ON q87.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteTotalServedInQuarterIncludesClosedCases8 q88 ON q88.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteAverageVisitsPerFamily8a q88a ON q88a.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteAverageVisitsPerFamily8bFinal q88b ON q88b.QuarterNumber = scrns.QuarterNumber	
			INNER JOIN cteLengthInProgramFinal q9 ON q9.QuarterNumber = scrns.QuarterNumber			


		
			INNER JOIN @tblMake8Quarter q8 ON q8.QuarterNumber = scrns.QuarterNumber
			ORDER BY scrns.QuarterNumber 
			
			
			
	INSERT INTO @tblQ8ReportMain
	(
			 QuarterNumber
			, QuarterEndDate
			, numberOfScreens		 
			, numberOfKempAssessments
			, KempPositivePercentage
			, KempPositiveEnrolled
			, KempPositivePending
			, KempPositiveTerminated
			, AvgPositiveMotherScore
			, EnrolledAtBeginningOfQrtr
			, NewEnrollmentsThisQuarter
			, NewEnrollmentsPrenatal
			, TANFServicesEligible
			, FamiliesDischargedThisQuarter
			, FamiliesCompletingProgramThisQuarter
			, FamiliesActiveAtEndOfThisQuarter
			, FamiliesActiveAtEndOfThisQuarterOnLevel1
			, FamiliesActiveAtEndOfThisQuarterOnLevelX
			, FamiliesWithNoServiceReferrals
			, AverageVisitsPerMonthPerCase
			, TotalServedInQuarterIncludesClosedCases
			, AverageVisitsPerFamily
			, TANFServicesEligibleAtEnrollment
			, rowBlankforItem9			
			, LengthInProgramUnder6Months
			, LengthInProgramUnder6MonthsTo1Year
			, LengthInProgramUnder1YearTo2Year
			, LengthInProgramUnder2YearsAndOver	
	)
		SELECT	99
			,'Last day of Quarter'
			,'1. Total Screens' 
			,'2. Total Kempe Assessments'
			,'    a. % Positive'
			,'        1. % Positive Enrolled'
			,'        2. % Positive Pending Enrollment'
			,'        3. % Positive Terminated'
			,'    b. Average Positive Mother Score'
			,'3. Families Enrolled at Beginning of quarter'
			,'4. New Enrollments this quarter'
			,'    a. % Prenatal'
			,'    b. % TANF Services Eligible at Enrollment**'
			,'5. Families Discharged this quarter'
			,'    a. Families completing the program'
			,'6. Families Active at end of this Quarter'
			,'    a. % on Level 1 at end of Quarter'
			,'    b. % on Level X at end of Quarter'
			,'    c. % Families with no Service Referrals'
			,'7. Average Visits per Month per Case on Level 1 or Level 1-SS'
			,'8. Total Served in Quarter(includes closed cases)'
			,'    a. Average Visits per Family'
			,'    b. % TANF Services Eligible at enrollment**'
			,'9. Length in Program for Active at End of Quarter'
			,'    a. Under 6 months'
			,'    b. 6 months up to 1 year'
			,'    c. 1 year up to 2 years'
			,'    d. 2 years and Over'			
			

-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'

-- Objective: Transpose Rows into Columns - what a pain in the ...
-- Idea: Create 9 variable tables and later join them to get our final result
-- Note: in each variable table, we are using UnPivot method  ... Khalsa


DECLARE @tblcol99 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8LeftNavText] VARCHAR(MAX) 	
)

DECLARE @tblcol1 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col1] VARCHAR(MAX) 	
)

DECLARE @tblcol2 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col2] VARCHAR(MAX) 	
)

DECLARE @tblcol3 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col3] VARCHAR(MAX) 	
)

DECLARE @tblcol4 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col4] VARCHAR(MAX) 	
)

DECLARE @tblcol5 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col5] VARCHAR(MAX) 	
)
DECLARE @tblcol6 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col6] VARCHAR(MAX) 	
)

DECLARE @tblcol7 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col7] VARCHAR(MAX) 	
)

DECLARE @tblcol8 TABLE(
	[Q8Columns] VARCHAR(MAX) ,
	[Q8Col8] VARCHAR(MAX) 	
)

;
WITH cteCol99 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 99	

)

INSERT INTO @tblcol99
SELECT	field,value FROM  cteCol99  AS col1
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol99

-- column1
;
WITH cteCol1 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 1	

)

INSERT INTO @tblcol1
SELECT	field,value FROM  cteCol1  AS col1
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol1

-- column2
;
WITH cteCol2 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 2	

)

INSERT INTO @tblcol2
SELECT	field,value FROM  cteCol2  AS col2
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol2

-- column3
;
WITH cteCol3 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 3	

)

INSERT INTO @tblcol3
SELECT	field,value FROM  cteCol3  AS col3
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol3

-- column4
;
WITH cteCol4 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 4	

)

INSERT INTO @tblcol4
SELECT	field,value FROM  cteCol4  AS col4
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol4

-- column5
;
WITH cteCol5 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 5	

)

INSERT INTO @tblcol5
SELECT	field,value FROM  cteCol5  AS col5
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol5

-- column6
;
WITH cteCol6 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 6	

)

INSERT INTO @tblcol6
SELECT	field,value FROM  cteCol6  AS col6
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol6

-- column7
;
WITH cteCol7 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 7	

)

INSERT INTO @tblcol7
SELECT	field,value FROM  cteCol7  AS col7
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol7

-- column8
;
WITH cteCol8 AS
(
SELECT	*
FROM  @tblQ8ReportMain AS Q8Report
where Q8Report.QuarterNumber = 8	

)

INSERT INTO @tblcol8
SELECT	field,value FROM  cteCol8  AS col8
UNPIVOT 
(
	value for field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage, KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore, EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter, FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1, FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals, AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver)

) unpvtCol8



-- Now get the desired output ... Khalsa
-- get all the columns and put them together now
SELECT 
	  Q8LeftNavText	
	 , c1.Q8Col1
	 , c2.Q8Col2
	 , c3.Q8Col3
	 , c4.Q8Col4
	 , c5.Q8Col5
	 , c6.Q8Col6
	 , c7.Q8Col7
	 --, c8.Q8Col8
	 
	 FROM @tblcol99 c99
INNER JOIN @tblcol1 c1 ON c1.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol2 c2 ON c2.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol3 c3 ON c3.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol4 c4 ON c4.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol5 c5 ON c5.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol6 c6 ON c6.Q8Columns = c99.Q8Columns
INNER JOIN @tblcol7 c7 ON c7.Q8Columns = c99.Q8Columns
--INNER JOIN @tblcol8 c8 ON c8.Q8Columns = c99.Q8Columns




-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'




END
GO