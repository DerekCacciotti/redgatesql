SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <January 4th, 2013>
-- Description:	<gets you data for Quarterly report i.e. J. Program Information for 8 Quarters>
-- exec [rspProgramInformationFor8Quarters] '5','03/31/13'
-- exec [rspProgramInformationFor8Quarters] '2','06/30/12'
-- exec [rspProgramInformationFor8Quarters] '5','06/30/12'
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',13,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',19,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL

-- exec [rspProgramInformationFor8Quarters] '39','12/31/13'
-- exec [rspProgramInformationFor8Quarters] '19','06/30/13'

-- 02/02/2013 
-- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens

-- exec [rspProgramInformationFor8Quarters] '31','2012-06-30'
-- =============================================
CREATE PROC [dbo].[rspProgramInformationFor8Quarters]
(
    @programfk VARCHAR(300) = NULL,
    @edate DATETIME,
    @sitefk INT = 0,
    @casefilterspositive VARCHAR(100) = ''
)
AS
BEGIN




    IF @programfk IS NULL
    BEGIN
        SELECT @programfk = SUBSTRING(
                            (
                                SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
                                FROM HVProgram
                                FOR XML PATH('')
                            ),
                            2,
                            8000
                                     );
    END;
    SET @programfk = REPLACE(@programfk, '"', '');




    SET @sitefk = CASE
                      WHEN dbo.IsNullOrEmpty(@sitefk) = 1 THEN
                          0
                      ELSE
                          @sitefk
                  END;
    SET @casefilterspositive = CASE
                                   WHEN @casefilterspositive = '' THEN
                                       NULL
                                   ELSE
                                       @casefilterspositive
                               END;


    ---- create a table that will be filled in with data at the end
    DECLARE @tblQ8ReportMain TABLE
    (
        QuarterNumber [VARCHAR](10),
        QuarterEndDate [VARCHAR](200) NULL,
        numberOfScreens [VARCHAR](200) NULL,
        numberOfKempAssessments [VARCHAR](200) NULL,
        KempPositivePercentage [VARCHAR](200) NULL,
        KempPositiveEnrolled [VARCHAR](200) NULL,
        KempPositivePending [VARCHAR](200) NULL,
        KempPositiveTerminated [VARCHAR](200) NULL,
        AvgPositiveMotherScore [VARCHAR](200) NULL,
        EnrolledAtBeginningOfQrtr [VARCHAR](200) NULL,
        NewEnrollmentsThisQuarter [VARCHAR](200) NULL,
        NewEnrollmentsPrenatal [VARCHAR](200) NULL,
        TANFServicesEligible [VARCHAR](200) NULL,
        FamiliesDischargedThisQuarter [VARCHAR](200) NULL,
        FamiliesCompletingProgramThisQuarter [VARCHAR](200) NULL,
        FamiliesActiveAtEndOfThisQuarter [VARCHAR](200) NULL,
        FamiliesActiveAtEndOfThisQuarterOnLevel1 [VARCHAR](200) NULL,
        FamiliesActiveAtEndOfThisQuarterOnLevelX [VARCHAR](200) NULL,
        FamiliesWithNoServiceReferrals [VARCHAR](200) NULL,
        AverageVisitsPerMonthPerCase [VARCHAR](200) NULL,
        TotalServedInQuarterIncludesClosedCases [VARCHAR](200) NULL,
        AverageVisitsPerFamily [VARCHAR](200) NULL,
        TANFServicesEligibleAtEnrollment [VARCHAR](200) NULL,
        rowBlankforItem9 [VARCHAR](200) NULL,
        LengthInProgramUnder6Months [VARCHAR](200) NULL,
        LengthInProgramUnder6MonthsTo1Year [VARCHAR](200) NULL,
        LengthInProgramUnder1YearTo2Year [VARCHAR](200) NULL,
        LengthInProgramUnder2YearsAndOver [VARCHAR](200) NULL
    );





    -- Create 8 quarters given a starting quarter end date
    -- 02/02/2013 
    -- handling when there is no data available. In order to handle, I added the following columns i.e. col1-col26
    DECLARE @tblMake8Quarter TABLE
    (
        [QuarterNumber] [INT],
        [QuarterStartDate] [DATE],
        [QuarterEndDate] [DATE],
        [Col1] [VARCHAR](200)
            DEFAULT ' ',
        [Col2] [VARCHAR](200)
            DEFAULT ' ',
        [Col3] [VARCHAR](200)
            DEFAULT ' ',
        [Col4] [VARCHAR](200)
            DEFAULT ' ',
        [Col5] [VARCHAR](200)
            DEFAULT ' ',
        [Col6] [VARCHAR](200)
            DEFAULT ' ',
        [Col7] [VARCHAR](200)
            DEFAULT ' ',
        [Col8] [VARCHAR](200)
            DEFAULT ' ',
        [Col9] [VARCHAR](200)
            DEFAULT ' ',
        [Col10] [VARCHAR](200)
            DEFAULT ' ',
        [Col11] [VARCHAR](200)
            DEFAULT ' ',
        [Col12] [VARCHAR](200)
            DEFAULT ' ',
        [Col13] [VARCHAR](200)
            DEFAULT ' ',
        [Col14] [VARCHAR](200)
            DEFAULT ' ',
        [Col15] [VARCHAR](200)
            DEFAULT ' ',
        [Col16] [VARCHAR](200)
            DEFAULT ' ',
        [Col17] [VARCHAR](200)
            DEFAULT ' ',
        [Col18] [VARCHAR](200)
            DEFAULT ' ',
        [Col19] [VARCHAR](200)
            DEFAULT ' ',
        [Col20] [VARCHAR](200)
            DEFAULT ' ',
        [Col21] [VARCHAR](200)
            DEFAULT ' ',
        [Col22] [VARCHAR](200)
            DEFAULT ' ',
        [Col23] [VARCHAR](200)
            DEFAULT ' ',
        [Col24] [VARCHAR](200)
            DEFAULT ' ',
        [Col25] [VARCHAR](200)
            DEFAULT ' ',
        [Col26] [VARCHAR](200)
            DEFAULT ' '
    );

    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 8,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -3, @edate)) + 1, 0))),
           @edate AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 7,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -6, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -3, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 6,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -9, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -6, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 5,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -12, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -9, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 4,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -15, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -12, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 3,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -18, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -15, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 2,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -21, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -18, @edate)) + 1, 0)) AS QuarterEndDate;
    INSERT INTO @tblMake8Quarter
    (
        [QuarterNumber],
        [QuarterStartDate],
        [QuarterEndDate]
    )
    SELECT 1,
           DATEADD(dd, 1, DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -24, @edate)) + 1, 0))),
           DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(mm, -21, @edate)) + 1, 0)) AS QuarterEndDate;


    -- SELECT * FROM @tblMake8Quarter  -- equivalent to csr8q cursor
    -- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'


    ---- ***************** ----
    -- Please use Pivot to change columns to rows (hint Pivoted on RowNumber) --- .... khalsa
    ---- ***************** ----

    -- Create a Summary table, where we will store values of all 8 quarters
    --create table #tblMain8Quarters(
    --	[RowNumber] [int],
    --	[Title] VARCHAR(250),
    --	[LastDayOfQuarter1] VARCHAR(10),
    --	[LastDayOfQuarter2] VARCHAR(10),
    --	[LastDayOfQuarter3] VARCHAR(10),
    --	[LastDayOfQuarter4] VARCHAR(10),
    --	[LastDayOfQuarter5] VARCHAR(10),
    --	[LastDayOfQuarter6] VARCHAR(10),
    --	[LastDayOfQuarter7] VARCHAR(10),
    --	[LastDayOfQuarter8] VARCHAR(10)	
    --)


    -- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
    -- We will use this cohort starting item # 3
    DECLARE @tblInitial_cohort TABLE
    (
        [HVCasePK] [INT],
        [CaseProgress] [NUMERIC](3, 1) NULL,
        [Confidentiality] [BIT] NULL,
        [CPFK] [INT] NULL,
        [DateOBPAdded] [DATETIME] NULL,
        [EDC] [DATETIME] NULL,
        [FFFK] [INT] NULL,
        [FirstChildDOB] [DATETIME] NULL,
        [FirstPrenatalCareVisit] [DATETIME] NULL,
        [FirstPrenatalCareVisitUnknown] [BIT] NULL,
        [HVCaseCreateDate] [DATETIME] NOT NULL,
        [HVCaseCreator] [CHAR](10) NOT NULL,
        [HVCaseEditDate] [DATETIME] NULL,
        [HVCaseEditor] [CHAR](10) NULL,
        [InitialZip] [CHAR](10) NULL,
        [IntakeDate] [DATETIME] NULL,
        [IntakeLevel] [CHAR](1) NULL,
        [IntakeWorkerFK] [INT] NULL,
        [KempeDate] [DATETIME] NULL,
        [OBPInformationAvailable] [BIT] NULL,
        [OBPFK] [INT] NULL,
        [OBPinHomeIntake] [BIT] NULL,
        [OBPRelation2TC] [CHAR](2) NULL,
        [PC1FK] [INT] NOT NULL,
        [PC1Relation2TC] [CHAR](2) NULL,
        [PC1Relation2TCSpecify] [VARCHAR](30) NULL,
        [PC2FK] [INT] NULL,
        [PC2inHomeIntake] [BIT] NULL,
        [PC2Relation2TC] [CHAR](2) NULL,
        [PC2Relation2TCSpecify] [VARCHAR](30) NULL,
        [PrenatalCheckupsB4] [INT] NULL,
        [ScreenDate] [DATETIME] NOT NULL,
        [TCDOB] [DATETIME] NULL,
        [TCDOD] [DATETIME] NULL,
        [TCNumber] [INT] NULL,
        [CaseProgramPK] [INT],
        [CaseProgramCreateDate] [DATETIME] NOT NULL,
        [CaseProgramCreator] [CHAR](10) NOT NULL,
        [CaseProgramEditDate] [DATETIME] NULL,
        [CaseProgramEditor] [CHAR](10) NULL,
        [CaseStartDate] [DATETIME] NOT NULL,
        [CurrentFAFK] [INT] NULL,
        [CurrentFAWFK] [INT] NULL,
        [CurrentFSWFK] [INT] NULL,
        [CurrentLevelDate] [DATETIME] NOT NULL,
        [CurrentLevelFK] [INT] NOT NULL,
        [DischargeDate] [DATETIME] NULL,
        [DischargeReason] [CHAR](2) NULL,
        [DischargeReasonSpecify] [VARCHAR](500) NULL,
        [ExtraField1] [CHAR](30) NULL,
        [ExtraField2] [CHAR](30) NULL,
        [ExtraField3] [CHAR](30) NULL,
        [ExtraField4] [CHAR](30) NULL,
        [ExtraField5] [CHAR](30) NULL,
        [ExtraField6] [CHAR](30) NULL,
        [ExtraField7] [CHAR](30) NULL,
        [ExtraField8] [CHAR](30) NULL,
        [ExtraField9] [CHAR](30) NULL,
        [HVCaseFK] [INT] NOT NULL,
        [HVCaseFK_old] [INT] NOT NULL,
        [OldID] [CHAR](23) NULL,
        [PC1ID] [CHAR](13) NOT NULL,
        [ProgramFK] [INT] NOT NULL,
        [TransferredtoProgram] [VARCHAR](50) NULL,
        [TransferredtoProgramFK] [INT] NULL,
        [CalcTCDOB] [DATETIME] NULL
    );

	DECLARE @tblScreensFor1_Cohort TABLE (
		QuarterNumber INT,
		NumberOfScreens INT
	)

	DECLARE @tblScreensFor1 TABLE (
		QuarterNumber INT,
		NumberOfScreens INT
	)

	DECLARE @tblKempAssessmentsFor2_Cohort TABLE (
		QuarterNumber INT,
		NumberOfKempeAssessments INT
	)

	DECLARE @tblKempAssessmentsFor2 TABLE (
		QuarterNumber INT,
		NumberOfKempeAssessments INT
	)

	DECLARE @tblKempAssessmentsFor2a_Cohort TABLE (
		QuarterNumber INT,
		TotalKemp INT,
		KempePositive INT
	)

	DECLARE @tblKempAssessmentsFor2a TABLE (
		QuarterNumber INT,
		TotalKemp INT,
		KempePositive INT
	)

	DECLARE @tblKempAssessmentsFor2a_CalcPercentage TABLE (
		QuarterNumber INT,
		KempPositivePercentage VARCHAR(50)
	)

	DECLARE @tblKempAssessmentsFor2a1_Cohort TABLE (
		QuarterNumber INT,
		KempPositiveEnrolled INT,
		KempePositive INT
	)
	
	DECLARE @tblKempAssessmentsFor2a1 TABLE (
		QuarterNumber INT,
		KempPositiveEnrolled INT,
		KempePositive INT
	)
	
	DECLARE @tblKempAssessmentsFor2a1_CalcPercentage TABLE (
		QuarterNumber INT,
		KempPositiveEnrolledPercentage VARCHAR(50)
	)
	
	DECLARE @tblKempAssessmentsFor2a2_Cohort TABLE (
		QuarterNumber INT,
		KempPositivePending INT,
		KempePositive INT
	)
	
	DECLARE @tblKempAssessmentsFor2a2 TABLE (
		QuarterNumber INT,
		KempPositivePending INT,
		KempePositive INT
	)

	DECLARE @tblKempAssessmentsFor2a2_CalcPercentage TABLE (
		QuarterNumber INT,
		KempPositivePendingPercentage VARCHAR(50)
	)

	DECLARE @tblKempAssessmentsFor2a3_Cohort TABLE (
		QuarterNumber INT,
		KempPositiveTerminated INT,
		KempePositive INT
	)
	
	DECLARE @tblKempAssessmentsFor2a3 TABLE (
		QuarterNumber INT,
		KempPositiveTerminated INT,
		KempePositive INT
	)
	
	DECLARE @tblKempAssessmentsFor2a3_CalcPercentage TABLE (
		QuarterNumber INT,
		KempPositiveTerminatedPercentage VARCHAR(50)
	)

	DECLARE @tblPositiveKempeScore TABLE (
		QuarterNumber INT,
		KempeScore DECIMAL(10,2)
	)

	DECLARE @tblKempAssessmentsFor2b_Cohort TABLE (
		QuarterNumber INT,
		AvgPositiveMotherScore DECIMAL(10,2)
	)

	DECLARE @tblKempAssessmentsFor2b TABLE (
		QuarterNumber INT,
		AvgPositiveMotherScore DECIMAL(10,2)
	)

	DECLARE @tblEnrolledAtBeginningOfQuarter3_Cohort TABLE (
		QuarterNumber INT,
		EnrolledAtBeginningOfQrtr INT
	)

	DECLARE @tblEnrolledAtBeginningOfQuarter3 TABLE (
		QuarterNumber INT,
		EnrolledAtBeginningOfQrtr INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4_Cohort TABLE (
		QuarterNumber INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4 TABLE (
		QuarterNumber INT,
		NewEnrollmentsThisQuarter INT
	)

	DECLARE @tblNewEnrollmentsThisQuarter4Again TABLE (
		QuarterNumber INT,
		NewEnrollmentsThisQuarter INT
	)

	DECLARE @tblNewEnrollmentsThisQuarter4a_Cohort TABLE (
		QuarterNumber INT,
		NewEnrollmentsPrenatal INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4a TABLE (
		QuarterNumber INT,
		NewEnrollmentsPrenatal INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4a_CalcPercentage TABLE (
		QuarterNumber INT,
		NewEnrollmentsPrenatalPercentage VARCHAR(50)
	)

	DECLARE @tblNewEnrollmentsThisQuarter4Again2 TABLE (
		QuarterNumber INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4b_Cohort TABLE (
		QuarterNumber INT,
		TANFServicesEligible INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4b TABLE (
		QuarterNumber INT,
		TANFServicesEligible INT,
		NewEnrollmentsThisQuarter INT
	)
	
	DECLARE @tblNewEnrollmentsThisQuarter4b_CalcPercentage TABLE (
		QuarterNumber INT,
		TANFServicesEligiblePercentage VARCHAR(50)
	)
	
	DECLARE @tblFamiliesDischargedThisQuarter5_Cohort TABLE (
		QuarterNumber INT,
		FamiliesDischargedThisQuarter INT
	)
	
	DECLARE @tblFamiliesDischargedThisQuarter5 TABLE (
		QuarterNumber INT,
		FamiliesDischargedThisQuarter INT
	)
	
	DECLARE @tblFamiliesCompletingProgramThisQuarter5a_Cohort TABLE (
		QuarterNumber INT,
		FamiliesCompletingProgramThisQuarter INT
	)
	
	DECLARE @tblFamiliesCompletingProgramThisQuarter5a TABLE (
		QuarterNumber INT,
		FamiliesCompletingProgramThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6_Cohort TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6 TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6Again TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6a_Cohort TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6a TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6a_CalcPercentage TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1Percentage VARCHAR(50)
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6Again2 TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6b TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevelX INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevelX INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6b_CalcPercentage TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevelXPercentage VARCHAR(50)
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter6Again3 TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblFamiliesWithNoServiceReferrals6c TABLE (
		QuarterNumber INT,
		FamiliesWithNoServiceReferrals INT
	)
	
	DECLARE @tblFamiliesWithNoServiceReferrals6c_MergeCohort TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT,
		FamiliesWithNoServiceReferrals INT
	)
	
	DECLARE @tblFamiliesWithNoServiceReferrals6c_Merge TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT,
		FamiliesWithNoServiceReferrals INT
	)
	
	DECLARE @tblFamiliesWithNoServiceReferrals6c_CalcPercentage TABLE (
		QuarterNumber INT,
		FamiliesWithNoServiceReferralsPercentage VARCHAR(50)
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter7_LevelRateCohort TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		TotalLevelRate DECIMAL(10,2)
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter7_LevelRate TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		TotalLevelRate DECIMAL(10,2)
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisitsCohort TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		TotalVisitRate INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisits TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarterOnLevel1 INT,
		TotalVisitRate INT
	)
	
	DECLARE @tblFamiliesActiveAtEndOfThisQuarter7 TABLE (
		QuarterNumber INT,
		AverageVisitsPerMonthPerCase DECIMAL(10,2)
	)
	
	DECLARE @tblTotalServedInQuarterIncludesClosedCases8_Cohort TABLE (
		QuarterNumber INT,
		TotalServedInQuarterIncludesClosedCases INT
	)
	
	DECLARE @tblTotalServedInQuarterIncludesClosedCases8 TABLE (
		QuarterNumber INT,
		TotalServedInQuarterIncludesClosedCases INT
	)
	
	DECLARE @tblAllFamilies8AgainFor8a_Cohort TABLE (
		QuarterNumber INT,
		TotalFamiliesServed INT
	)
	
	DECLARE @tblAllFamilies8AgainFor8a TABLE (
		QuarterNumber INT,
		TotalFamiliesServed INT
	)
	
	DECLARE @tblAllFamilies8aVisits_Cohort TABLE (
		QuarterNumber INT,
		TotalHVLogActivities INT
	)
	
	DECLARE @tblAllFamilies8aVisits TABLE (
		QuarterNumber INT,
		TotalHVLogActivities INT
	)
	
	DECLARE @tblAverageVisitsPerFamily8a TABLE (
		QuarterNumber INT,
		AverageVisitsPerFamily DECIMAL(10,2)
	)
	
	DECLARE @tblAllFamilies8AgainFor8b TABLE (
		QuarterNumber INT,
		TotalFamiliesServed INT
	)
	
	DECLARE @tblAverageVisitsPerFamily8b_Cohort TABLE (
		QuarterNumber INT,
		TANFServicesEligible INT,
		TotalFamiliesServed INT
	)
	
	DECLARE @tblAverageVisitsPerFamily8b TABLE (
		QuarterNumber INT,
		TANFServicesEligible INT,
		TotalFamiliesServed INT
	)
	
	DECLARE @tblAverageVisitsPerFamily8b_Final TABLE (
		QuarterNumber INT,
		TANFServicesEligibleAtEnrollment VARCHAR(50)
	)
	
	DECLARE @tblLengthInProgram9 TABLE (
		QuarterNumber INT,
		LengthInProgramUnder6Months INT,
		LengthInProgram6MonthsTo1Year INT,
		LengthInProgram1YearTo2Year INT,
		LengthInProgram2YearsAndOver INT
	)
	
	DECLARE @tblLengthInProgram9_SumCohort TABLE (
		QuarterNumber INT,
		LengthInProgramUnder6Months INT,
		LengthInProgram6MonthsTo1Year INT,
		LengthInProgram1YearTo2Year INT,
		LengthInProgram2YearsAndOver INT
	)
	
	DECLARE @tblLengthInProgram9_Sum TABLE (
		QuarterNumber INT,
		LengthInProgramUnder6Months INT,
		LengthInProgram6MonthsTo1Year INT,
		LengthInProgram1YearTo2Year INT,
		LengthInProgram2YearsAndOver INT
	)
	
	DECLARE @tblLengthInProgramAtEndOfThisQuarter9 TABLE (
		QuarterNumber INT,
		FamiliesActiveAtEndOfThisQuarter INT
	)
	
	DECLARE @tblLengthInProgramFinal TABLE (
		QuarterNumber INT,
		LengthInProgramUnder6MonthsPercentage VARCHAR(50),
		LengthInProgram6MonthsTo1YearPercentage VARCHAR(50),
		LengthInProgram1YearTo2YearPercentage VARCHAR(50),
		LengthInProgram2YearsAndOverPercentage VARCHAR(50)
	)

    INSERT INTO @tblInitial_cohort
    SELECT [HVCasePK],
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
           CASE
               WHEN h.TCDOB IS NOT NULL THEN
                   h.TCDOB
               ELSE
                   h.EDC
           END AS [CalcTCDOB]
    FROM HVCase h
        INNER JOIN CaseProgram cp
            ON h.HVCasePK = cp.HVCaseFK
        INNER JOIN dbo.SplitString(@programfk, ',')
            ON cp.ProgramFK = ListItem
        LEFT OUTER JOIN Worker w
            ON w.WorkerPK = cp.CurrentFSWFK
        LEFT OUTER JOIN WorkerProgram wp
            ON wp.WorkerFK = w.WorkerPK
               AND wp.ProgramFK = cp.ProgramFK
        INNER JOIN dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf
            ON cf.HVCaseFK = h.HVCasePK
    WHERE CASE
              WHEN @sitefk = 0 THEN
                  1
              WHEN wp.SiteFK = @sitefk THEN
                  1
              ELSE
                  0
          END = 1
          AND cp.CaseStartDate < @edate -- handling transfer cases
          AND
          (
              DischargeDate IS NULL
              OR DischargeDate >= DATEADD(mm, -27, @edate)
          )

    -- 1
    INSERT INTO @tblScreensFor1_Cohort
     -- "1. Total Screens"
       -- Screens Row 1
       SELECT DISTINCT
           --Chris Papas
              QuarterNumber AS QuarterNumber,
              COUNT(*) OVER (PARTITION BY [QuarterNumber]) AS 'numberOfScreens'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.ScreenDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblScreensFor1
    -- "1. Total Screens"
       -- Screens Row 1
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(numberOfScreens, 0) AS numberOfScreens
       FROM @tblScreensFor1_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

	INSERT INTO @tblKempAssessmentsFor2_Cohort
         -- 2
		  -- "2. Total Kempe Assessments"
       -- Kempe Assessment Row 2
       SELECT DISTINCT
              QuarterNumber,
              COUNT(*) OVER (PARTITION BY [QuarterNumber]) AS 'numberOfKempAssessments'
       FROM @tblInitial_cohort h
           INNER JOIN Kempe k
               ON k.HVCaseFK = h.HVCaseFK
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO	@tblKempAssessmentsFor2
     -- "2. Total Kempe Assessments"
       -- Kempe Assessment Row 2		
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.NumberOfKempeAssessments, 0) AS numberOfKempAssessments
       FROM @tblKempAssessmentsFor2_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         -- 2a
    INSERT INTO @tblKempAssessmentsFor2a_Cohort
       -- Kempe Assessment Percentage
       -- It will be done in two steps i.e. 1. Get numbers like KempePositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'TotalKemp',
              SUM(   CASE
                         WHEN k.KempeResult = 1 THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempePositive'
       FROM @tblInitial_cohort h
           LEFT JOIN Kempe k
               ON k.HVCaseFK = h.HVCasePK
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblKempAssessmentsFor2a
       -- Kempe Assessment Percentage
       -- It will be done in two steps i.e. 1. Get numbers like KempePositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.TotalKemp, 0) AS TotalKemp,
              ISNULL(s1.KempePositive, 0) AS KempePositive
       FROM @tblKempAssessmentsFor2a_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblKempAssessmentsFor2a_CalcPercentage
       -- "    a. % Positive" 
       -- Kempe Assessment Percentage Row 3				
       SELECT QuarterNumber,
              CONVERT(VARCHAR, KempePositive) + ' ('
              + CONVERT(VARCHAR, ROUND(COALESCE(CAST(KempePositive AS FLOAT) * 100 / NULLIF(TotalKemp, 0), 0), 0))
              + '%)' AS KempPositivePercentage
       FROM @tblKempAssessmentsFor2a


         -- 2a1
    INSERT INTO @tblKempAssessmentsFor2a1_Cohort
       -- Kempe Assessment Percentage - Positive Enrolled
       -- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              SUM(   CASE
                         WHEN
                         (
                             (k.KempeResult = 1)
                             AND
                             (
                                 h.IntakeDate IS NOT NULL
                                 AND h.IntakeDate <> ''
                             )
                         ) THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempPositiveEnrolled',
              SUM(   CASE
                         WHEN k.KempeResult = 1 THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempePositive'
       FROM @tblInitial_cohort h
           LEFT JOIN Kempe k
               ON k.HVCaseFK = h.HVCasePK
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblKempAssessmentsFor2a1
       -- Kempe Assessment Percentage - Positive Enrolled
       -- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.KempPositiveEnrolled, 0) AS KempPositiveEnrolled,
              ISNULL(s1.KempePositive, 0) AS KempePositive
       FROM @tblKempAssessmentsFor2a1_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblKempAssessmentsFor2a1_CalcPercentage
       -- "        1. % Positive Enrolled" 
       -- Kempe Assessment Percentage Row 3				
       SELECT QuarterNumber,
              CONVERT(VARCHAR, KempPositiveEnrolled) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(COALESCE(CAST(KempPositiveEnrolled AS FLOAT) * 100 / NULLIF(KempePositive, 0), 0), 0)
                       ) + '%)' AS KempPositiveEnrolled
       FROM @tblKempAssessmentsFor2a1

         -- 2a2
    INSERT INTO @tblKempAssessmentsFor2a2_Cohort
       -- Kempe Assessment Percentage - Positive Pending Enrollment
       -- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              SUM(   CASE
                         WHEN
                         (
                             (k.KempeResult = 1)
                             AND
                             (
                                 h.DischargeDate IS NULL
                                 AND h.IntakeDate IS NULL
                             )
                         ) THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempPositivePending',
              SUM(   CASE
                         WHEN k.KempeResult = 1 THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempePositive'
       FROM @tblInitial_cohort h
           LEFT JOIN Kempe k
               ON k.HVCaseFK = h.HVCasePK
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblKempAssessmentsFor2a2
       -- Kempe Assessment Percentage - Positive Pending Enrollment
       -- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.KempPositivePending, 0) AS KempPositivePending,
              ISNULL(s1.KempePositive, 0) AS KempePositive
       FROM @tblKempAssessmentsFor2a2_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblKempAssessmentsFor2a2_CalcPercentage
       --	"        2. % Positive Pending Enrollment" 
       -- Kempe Assessment Percentage Row 3				
       SELECT QuarterNumber,
              CONVERT(VARCHAR, KempPositivePending) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(COALESCE(CAST(KempPositivePending AS FLOAT) * 100 / NULLIF(KempePositive, 0), 0), 0)
                       ) + '%)' AS KempPositivePending
       FROM @tblKempAssessmentsFor2a2

         -- 2a3
    INSERT INTO @tblKempAssessmentsFor2a3_Cohort
       -- Kempe Assessment Percentage - Positive Terminated
       -- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              SUM(   CASE
                         WHEN
                         (
                             (k.KempeResult = 1)
                             AND
                             (
                                 h.DischargeDate IS NOT NULL
                                 AND h.IntakeDate IS NULL
                             )
                         ) THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempPositiveTerminated',
              SUM(   CASE
                         WHEN k.KempeResult = 1 THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'KempePositive'
       FROM @tblInitial_cohort h
           LEFT JOIN Kempe k
               ON k.HVCaseFK = h.HVCasePK
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblKempAssessmentsFor2a3
       -- Kempe Assessment Percentage - Positive Terminated
       -- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempePositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.KempPositiveTerminated, 0) AS KempPositiveTerminated,
              ISNULL(s1.KempePositive, 0) AS KempePositive
       FROM @tblKempAssessmentsFor2a3_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblKempAssessmentsFor2a3_CalcPercentage
       --"        3. % Positive Terminated"
       -- Kempe Assessment Percentage Row 3				
       SELECT QuarterNumber,
              CONVERT(VARCHAR, KempPositiveTerminated) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(COALESCE(CAST(KempPositiveTerminated AS FLOAT) * 100 / NULLIF(KempePositive, 0), 0), 0)
                       ) + '%)' AS KempPositiveTerminated
       FROM @tblKempAssessmentsFor2a3

         -- 2b
     INSERT INTO @tblPositiveKempeScore
     -- find max score of mom/father/partner ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              (
                  SELECT MAX(thisValue)
                  FROM
                  (
                      SELECT ISNULL(CAST(k.MomScore AS DECIMAL(10,2)), 0) AS thisValue
                      UNION ALL
                      SELECT ISNULL(CAST(k.DadScore AS DECIMAL(10,2)), 0) AS thisValue
                      UNION ALL
                      SELECT ISNULL(CAST(k.PartnerScore AS DECIMAL(10,2)), 0) AS thisValue
                  ) AS khalsaTable
              ) AS KempeScore
       FROM @tblInitial_cohort h
           LEFT JOIN Kempe k
               ON k.HVCaseFK = h.HVCasePK
                  AND k.KempeResult = 1 -- keeping 'k.KempeResult = 1' it here (not as in where clause down), it saved 3 seconds of execution time ... Khalsa
           INNER JOIN @tblMake8Quarter q8
               ON k.KempeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblKempAssessmentsFor2b_Cohort
       -- "    b. Average Positive Mother Score"
       -- MomScore
       SELECT DISTINCT
              QuarterNumber,
              AVG(KempeScore) OVER (PARTITION BY [QuarterNumber]) AS 'AvgPositiveMotherScore'
       FROM @tblPositiveKempeScore

    INSERT INTO @tblKempAssessmentsFor2b
       -- "    b. Average Positive Mother Score"
       -- MomScore
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(AvgPositiveMotherScore, 0) AS AvgPositiveMotherScore
       FROM @tblKempAssessmentsFor2b_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         -- 3
    INSERT INTO @tblEnrolledAtBeginningOfQuarter3_Cohort
       -- 3. Families Enrolled at Beginning of quarter
       SELECT DISTINCT
              QuarterNumber,
              COUNT(HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'EnrolledAtBeginningOfQrtr'
       FROM @tblInitial_cohort ic
           INNER JOIN @tblMake8Quarter q8
               ON ic.IntakeDate <= [QuarterStartDate]
                  AND ic.IntakeDate IS NOT NULL
                  AND
                  (
                      ic.DischargeDate >= [QuarterStartDate]
                      OR ic.DischargeDate IS NULL
                  )

    INSERT INTO @tblEnrolledAtBeginningOfQuarter3
       -- 3. Families Enrolled at Beginning of quarter
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.EnrolledAtBeginningOfQrtr, 0) AS EnrolledAtBeginningOfQrtr
       FROM @tblEnrolledAtBeginningOfQuarter3_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         -- 4
    INSERT INTO @tblNewEnrollmentsThisQuarter4_Cohort
       -- "4. New Enrollments this quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'NewEnrollmentsThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblNewEnrollmentsThisQuarter4
       -- "4. New Enrollments this quarter"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.NewEnrollmentsThisQuarter, 0) AS NewEnrollmentsThisQuarter
       FROM @tblNewEnrollmentsThisQuarter4_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         --- 4a
    INSERT INTO @tblNewEnrollmentsThisQuarter4Again
       -- We will use this one in cteNewEnrollmentsThisQuarter4a. 
       -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'NewEnrollmentsThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblNewEnrollmentsThisQuarter4a_Cohort
       -- "    a. % Prenatal"
       -- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'NewEnrollmentsPrenatal',
              q8Again.NewEnrollmentsThisQuarter AS NewEnrollmentsThisQuarter
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]
           INNER JOIN @tblNewEnrollmentsThisQuarter4Again q8Again
               ON q8Again.QuarterNumber = q8.QuarterNumber
       WHERE h.[CalcTCDOB] > IntakeDate

    INSERT INTO @tblNewEnrollmentsThisQuarter4a
       -- "    a. % Prenatal"
       -- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.NewEnrollmentsPrenatal, 0) AS NewEnrollmentsPrenatal,
              ISNULL(s1.NewEnrollmentsThisQuarter, 0) AS NewEnrollmentsThisQuarter
       FROM @tblNewEnrollmentsThisQuarter4a_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblNewEnrollmentsThisQuarter4a_CalcPercentage
		SELECT QuarterNumber,
               CONVERT(VARCHAR, NewEnrollmentsPrenatal) + ' ('
               + CONVERT(
                            VARCHAR,
                            ROUND(
                                     COALESCE(
                                                 CAST(NewEnrollmentsPrenatal AS FLOAT) * 100
                                                 / NULLIF(NewEnrollmentsThisQuarter, 0),
                                                 0
                                             ),
                                     0
                                 )
                        ) + '%)' AS NewEnrollmentsPrenatal
        FROM @tblNewEnrollmentsThisQuarter4a

         --- 4b
    INSERT INTO @tblNewEnrollmentsThisQuarter4Again2
       -- We will use this one in cteNewEnrollmentsThisQuarter4b. 
       -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'NewEnrollmentsThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]

    INSERT INTO @tblNewEnrollmentsThisQuarter4b_Cohort
       -- "    b. % TANF Services Eligible at Enrollment**"
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(*) OVER (PARTITION BY q8.[QuarterNumber]) AS 'TANFServicesEligible',
              q8Again2.NewEnrollmentsThisQuarter
       FROM @tblInitial_cohort h
           INNER JOIN CommonAttributes ca
               ON ca.HVCaseFK = h.HVCaseFK
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]
           INNER JOIN @tblNewEnrollmentsThisQuarter4Again2 q8Again2
               ON q8Again2.QuarterNumber = q8.QuarterNumber
       WHERE ca.TANFServices = 1
             AND ca.FormType = 'IN' -- only from Intake form here

         
    INSERT INTO @tblNewEnrollmentsThisQuarter4b
       -- "    b. % TANF Services Eligible at Enrollment**"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.TANFServicesEligible, 0) AS TANFServicesEligible,
              ISNULL(s1.NewEnrollmentsThisQuarter, 0) AS NewEnrollmentsThisQuarter
       FROM @tblNewEnrollmentsThisQuarter4b_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblNewEnrollmentsThisQuarter4b_CalcPercentage
		SELECT QuarterNumber,
               CONVERT(VARCHAR, TANFServicesEligible) + ' ('
               + CONVERT(
                            VARCHAR,
                            ROUND(
                                     COALESCE(
                                                 CAST(TANFServicesEligible AS FLOAT) * 100
                                                 / NULLIF(NewEnrollmentsThisQuarter, 0),
                                                 0
                                             ),
                                     0
                                 )
                        ) + '%)' AS TANFServicesEligible
        FROM @tblNewEnrollmentsThisQuarter4b



         -- 5
    INSERT INTO @tblFamiliesDischargedThisQuarter5_Cohort
       -- "5. Families Discharged this quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesDischargedThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.DischargeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL

    INSERT INTO @tblFamiliesDischargedThisQuarter5
       -- "5. Families Discharged this quarter"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(FamiliesDischargedThisQuarter, 0) AS FamiliesDischargedThisQuarter
       FROM @tblFamiliesDischargedThisQuarter5_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber


         -- 5a
    INSERT INTO @tblFamiliesCompletingProgramThisQuarter5a_Cohort
       -- "    a. Families completing the program"
       -- Discharged after completing the program through Discharge Form
       SELECT DISTINCT
              QuarterNumber,
              SUM(   CASE
                         WHEN DischargeReason IN ( 27, 29 ) THEN
                             1
                         ELSE
                             0
                     END
                 ) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesCompletingProgramThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.DischargeDate
                  BETWEEN [QuarterStartDate] AND [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL

    INSERT INTO @tblFamiliesCompletingProgramThisQuarter5a
       -- "    a. Families completing the program"
       -- Discharged after completing the program through Discharge Form
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.FamiliesCompletingProgramThisQuarter, 0) AS FamiliesCompletingProgramThisQuarter
       FROM @tblFamiliesCompletingProgramThisQuarter5a_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         -- 6
    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6_Cohort
       -- "6. Families Active at end of this Quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6
       -- "6. Families Active at end of this Quarter"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(FamiliesActiveAtEndOfThisQuarter, 0) AS FamiliesActiveAtEndOfThisQuarter
       FROM @tblFamiliesActiveAtEndOfThisQuarter6_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber



         -- 6a
    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6Again
       -- "6. Families Active at end of this Quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6a_Cohort
       -- "    a. % on Level 1 at end of Quarter"
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarterOnLevel1',
              q86a.FamiliesActiveAtEndOfThisQuarter AS FamiliesActiveAtEndOfThisQuarter
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
           INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter6Again q86a
               ON q86a.QuarterNumber = q8.QuarterNumber
           LEFT JOIN HVLevelDetail hd
               ON hd.HVCaseFK = h.HVCaseFK
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )
             AND
             (
                 (q8.QuarterEndDate
             BETWEEN hd.StartLevelDate AND hd.EndLevelDate
                 )
                 OR
                 (
                     q8.QuarterEndDate >= hd.StartLevelDate
                     AND hd.EndLevelDate IS NULL
                 )
             ) -- note: they still may be on level 1
             AND LevelName IN ( 'Level 1', 'Level 1-SS' )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6a
       -- "    a. % on Level 1 at end of Quarter"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) AS FamiliesActiveAtEndOfThisQuarterOnLevel1,
              ISNULL(s1.FamiliesActiveAtEndOfThisQuarter, 0) AS FamiliesActiveAtEndOfThisQuarter
       FROM @tblFamiliesActiveAtEndOfThisQuarter6a_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6a_CalcPercentage
		SELECT QuarterNumber,
               CONVERT(VARCHAR, FamiliesActiveAtEndOfThisQuarterOnLevel1) + ' ('
               + CONVERT(
                            VARCHAR,
                            ROUND(
                                     COALESCE(
                                                 CAST(FamiliesActiveAtEndOfThisQuarterOnLevel1 AS FLOAT) * 100
                                                 / NULLIF(FamiliesActiveAtEndOfThisQuarter, 0),
                                                 0
                                             ),
                                     0
                                 )
                        ) + '%)' AS FamiliesActiveAtEndOfThisQuarterOnLevel1
        FROM @tblFamiliesActiveAtEndOfThisQuarter6a

         -- 6b
    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6Again2
       -- "    b. % on Level CO at end of Quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6b
       -- "    b. % on Level CO at end of Quarter"
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarterOnLevelX',
              q86b.FamiliesActiveAtEndOfThisQuarter AS FamiliesActiveAtEndOfThisQuarter
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
           INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter6Again2 q86b
               ON q86b.QuarterNumber = q8.QuarterNumber
           --Note: we are making use of operator i.e. 'Outer Apply'
           -- because a columns values cann't be passed to a function in a join without this operator  ... khalsa
           OUTER APPLY [udfHVLevel](@programfk, q8.QuarterEndDate) e3
       WHERE h.IntakeDate IS NOT NULL
             AND h.IntakeDate <= q8.QuarterEndDate
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )
             AND e3.levelname LIKE 'Level CO'
             AND e3.hvcasefk = h.HVCasePK
             AND e3.programfk = h.ProgramFK

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
       -- "    b. % on Level CO at end of Quarter"
       SELECT ISNULL(f6bmissing.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(FamiliesActiveAtEndOfThisQuarterOnLevelX, 0) AS FamiliesActiveAtEndOfThisQuarterOnLevelX,
              ISNULL(FamiliesActiveAtEndOfThisQuarter, 0) AS FamiliesActiveAtEndOfThisQuarter
       FROM @tblFamiliesActiveAtEndOfThisQuarter6b f6bmissing
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = f6bmissing.QuarterNumber

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6b_CalcPercentage
		SELECT QuarterNumber,
               CONVERT(VARCHAR, FamiliesActiveAtEndOfThisQuarterOnLevelX) + ' ('
               + CONVERT(
                            VARCHAR,
                            ROUND(
                                     COALESCE(
                                                 CAST(FamiliesActiveAtEndOfThisQuarterOnLevelX AS FLOAT) * 100
                                                 / NULLIF(FamiliesActiveAtEndOfThisQuarter, 0),
                                                 0
                                             ),
                                     0
                                 )
                        ) + '%)' AS FamiliesActiveAtEndOfThisQuarterOnLevelX
        FROM @tblFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters

         -- 6c
    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter6Again3
       -- "6. Families Active at end of this Quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > QuarterEndDate
             )

    INSERT INTO @tblFamiliesWithNoServiceReferrals6c
		-- "    c. % Families with no Service Referrals"
       -- Find those records (hvcasepk) that are in @tblFamiliesActiveAtEndOfThisQuarter6 but does not have Service Referral in table i.e.ServiceReferral
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'FamiliesWithNoServiceReferrals'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
           LEFT JOIN ServiceReferral sr
               ON sr.HVCaseFK = h.HVCaseFK
                  AND (ReferralDate <= [QuarterEndDate]) -- leave it here the extra condition
       WHERE h.IntakeDate IS NOT NULL
             AND h.IntakeDate <= [QuarterEndDate]
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > [QuarterEndDate]
             )
             AND ReferralDate IS NULL -- This is important

    INSERT INTO @tblFamiliesWithNoServiceReferrals6c_MergeCohort
		-- "    c. % Families with no Service Referrals"
       -- Note: There are quarters which are missing in @tblFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
       -- therefore, we need  to merge to bring back missing quarters
       SELECT a.QuarterNumber,
              FamiliesActiveAtEndOfThisQuarter,
              CASE
                  WHEN FamiliesWithNoServiceReferrals > 0 THEN
                      FamiliesWithNoServiceReferrals
                  ELSE
                      0
              END AS FamiliesWithNoServiceReferrals
       FROM @tblFamiliesActiveAtEndOfThisQuarter6Again3 a
           LEFT JOIN @tblFamiliesWithNoServiceReferrals6c b
               ON a.QuarterNumber = b.QuarterNumber

    INSERT INTO @tblFamiliesWithNoServiceReferrals6c_Merge
       -- "    c. % Families with no Service Referrals"
       -- Note: There are quarters which are missing in @tblFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
       -- therefore, we need  to merge to bring back missing quarters
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(s1.FamiliesActiveAtEndOfThisQuarter, 0) AS FamiliesActiveAtEndOfThisQuarter,
              ISNULL(s1.FamiliesWithNoServiceReferrals, 0) AS FamiliesWithNoServiceReferrals
       FROM @tblFamiliesWithNoServiceReferrals6c_MergeCohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblFamiliesWithNoServiceReferrals6c_CalcPercentage
		SELECT QuarterNumber,
               CONVERT(VARCHAR, FamiliesWithNoServiceReferrals) + ' ('
               + CONVERT(
                            VARCHAR,
                            ROUND(
                                     COALESCE(
                                                 CAST(FamiliesWithNoServiceReferrals AS FLOAT) * 100
                                                 / NULLIF(FamiliesActiveAtEndOfThisQuarter, 0),
                                                 0
                                             ),
                                     0
                                 )
                        ) + '%)' AS FamiliesWithNoServiceReferrals
        FROM @tblFamiliesWithNoServiceReferrals6c_Merge

         -- 7	
    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter7_LevelRateCohort
       -- calculate level for each case
      -- "7. Average Visits per Month per Case on Level 1"
    SELECT DISTINCT
           q8.QuarterNumber,
           COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarterOnLevel1',
           SUM(   CASE
                      WHEN hd.StartLevelDate <= q8.QuarterStartDate THEN
                          1
                      WHEN hd.StartLevelDate
                           BETWEEN q8.QuarterStartDate AND q8.QuarterEndDate THEN
                          ROUND(
                                   COALESCE(
                                               CAST(DATEDIFF(dd, hd.StartLevelDate, q8.QuarterEndDate) AS FLOAT) * 100
                                               / NULLIF(DATEDIFF(dd, q8.QuarterStartDate, q8.QuarterEndDate), 0),
                                               0
                                           ),
                                   0
                               ) / 100
                      ELSE
                          0
                  END
              ) OVER (PARTITION BY q8.[QuarterNumber]) AS 'TotalLevelRate'
    FROM @tblInitial_cohort h
        INNER JOIN @tblMake8Quarter q8
            ON h.IntakeDate <= [QuarterEndDate]
        LEFT JOIN HVLevelDetail hd
            ON hd.HVCaseFK = h.HVCaseFK
    WHERE h.IntakeDate IS NOT NULL
          AND
          (
              h.DischargeDate IS NULL
              OR h.DischargeDate > QuarterEndDate
          )
          AND
          (
              (q8.QuarterEndDate
          BETWEEN hd.StartLevelDate AND hd.EndLevelDate
              )
              OR
              (
                  q8.QuarterEndDate >= hd.StartLevelDate
                  AND hd.EndLevelDate IS NULL
              )
          ) -- note: they still may be on level 1
          AND LevelName IN ( 'Level 1', 'Level 1-SS' )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter7_LevelRate
       -- calculate level for each case
        -- "7. Average Visits per Month per Case on Level 1"
    SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
           ISNULL(s1.FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) AS FamiliesActiveAtEndOfThisQuarterOnLevel1,
           ISNULL(s1.TotalLevelRate, 0) AS TotalLevelRate
    FROM @tblFamiliesActiveAtEndOfThisQuarter7_LevelRateCohort s1
        RIGHT JOIN @tblMake8Quarter q8
            ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisitsCohort
       -- calculate visits per case
        -- "7. Average Visits per Month per Case on Level 1"
    SELECT DISTINCT
           q8.QuarterNumber,
           COUNT(h.HVCasePK) OVER (PARTITION BY q8.[QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarterOnLevel1',
           SUM(   CASE
                      WHEN hd.StartLevelDate <= q8.QuarterStartDate THEN
                          1 -- count(hvcasepk) over (partition by q8.QuarterNumber) -- count of num of visits for the entire quarter if he was on level 1 before quarterstart
                      WHEN VisitStartTime
                           BETWEEN hd.StartLevelDate AND q8.QuarterEndDate THEN
                          1
                      ELSE
                          0
                  END
              ) OVER (PARTITION BY q8.[QuarterNumber]) AS 'TotalVisitRate'
    FROM @tblInitial_cohort h
        LEFT JOIN HVLevelDetail hd
            ON hd.HVCaseFK = h.HVCaseFK
        LEFT OUTER JOIN HVLog
            ON h.HVCaseFK = HVLog.HVCaseFK
        INNER JOIN @tblMake8Quarter q8
            ON HVLog.VisitStartTime
               BETWEEN q8.QuarterStartDate AND q8.QuarterEndDate
    WHERE h.IntakeDate IS NOT NULL
          AND
          (
              h.DischargeDate IS NULL
              OR h.DischargeDate > QuarterEndDate
          )
          AND
          (
              (q8.QuarterEndDate
          BETWEEN hd.StartLevelDate AND hd.EndLevelDate
              )
              OR
              (
                  q8.QuarterEndDate >= hd.StartLevelDate
                  AND hd.EndLevelDate IS NULL
              )
          ) -- note: they still may be on level 1
          AND LevelName IN ( 'Level 1', 'Level 1-SS' )

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisits
       -- calculate visits per case
        -- "7. Average Visits per Month per Case on Level 1"
    SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
           ISNULL(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) AS FamiliesActiveAtEndOfThisQuarterOnLevel1,
           ISNULL(TotalVisitRate, 0) AS TotalVisitRate
    FROM @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisitsCohort s1
        RIGHT JOIN @tblMake8Quarter q8
            ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblFamiliesActiveAtEndOfThisQuarter7
       -- calculate visits per case
        -- "7. Average Visits per Month per Case on Level 1"	
    SELECT lr.QuarterNumber,
           --, lr.FamiliesActiveAtEndOfThisQuarterOnLevel1
           --, TotalLevelRate
           ----, nv.QuarterNumber
           --, nv.FamiliesActiveAtEndOfThisQuarterOnLevel1
           --, TotalVisitRate
           --, ( TotalVisitRate / (3 * TotalLevelRate) ) AS AverageVisitsPerMonthPerCase
           ROUND(COALESCE(CAST(TotalVisitRate AS FLOAT) * 100 / NULLIF(3 * TotalLevelRate, 0), 0), 0) / 100 AS AverageVisitsPerMonthPerCase
    FROM @tblFamiliesActiveAtEndOfThisQuarter7_LevelRate lr
        INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter7_NumberOfVisits nv
            ON nv.QuarterNumber = lr.QuarterNumber

         -- 8
    INSERT INTO @tblTotalServedInQuarterIncludesClosedCases8_Cohort
       -- "8. Total Served in Quarter(includes closed cases)"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'TotalServedInQuarterIncludesClosedCases'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= QuarterStartDate
             ) -- not discharged or discharged after the quarter start date		

    INSERT INTO @tblTotalServedInQuarterIncludesClosedCases8
       -- "8. Total Served in Quarter(includes closed cases)"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(TotalServedInQuarterIncludesClosedCases, 0) AS TotalServedInQuarterIncludesClosedCases
       FROM @tblTotalServedInQuarterIncludesClosedCases8_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber



         -- 8a
    INSERT INTO @tblAllFamilies8AgainFor8a_Cohort
       -- "8    a. Average Visits per Family"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'TotalFamiliesServed'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= QuarterStartDate
             ) -- not discharged or discharged after the quarter start date		

    INSERT INTO @tblAllFamilies8AgainFor8a
       -- "8    a. Average Visits per Family"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(TotalFamiliesServed, 0) AS TotalFamiliesServed
       FROM @tblAllFamilies8AgainFor8a_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblAllFamilies8aVisits_Cohort
       -- "8    a. Average Visits per Family"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(HVLog.HVLogPK) OVER (PARTITION BY [QuarterNumber]) AS 'TotalHVlogActivities'
       FROM @tblInitial_cohort h
           LEFT JOIN HVLevelDetail hd
               ON hd.HVCaseFK = h.HVCaseFK
           LEFT OUTER JOIN HVLog
               ON h.HVCaseFK = HVLog.HVCaseFK
           INNER JOIN @tblMake8Quarter q8
               ON HVLog.VisitStartTime
                  BETWEEN q8.QuarterStartDate AND q8.QuarterEndDate
       WHERE h.IntakeDate IS NOT NULL
             AND h.IntakeDate <= q8.[QuarterEndDate]
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= [QuarterStartDate]
             ) -- not discharged or discharged after the quarter start date	
             AND SUBSTRING(VisitType, 4, 1) <> '1'

    INSERT INTO @tblAllFamilies8aVisits
       -- "8    a. Average Visits per Family"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(TotalHVlogActivities, 0) AS TotalHVlogActivities
       FROM @tblAllFamilies8aVisits_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblAverageVisitsPerFamily8a
     -- "8    a. Average Visits per Family"
       SELECT lr.QuarterNumber,
              --, TotalFamiliesServed
              ----, nv.QuarterNumber
              --, TotalHVlogActivities		
              ROUND(COALESCE(CAST(TotalHVlogActivities AS FLOAT) * 100 / NULLIF(3 * TotalFamiliesServed, 0), 0), 0)
              / 100 AS AverageVisitsPerFamily
       FROM @tblAllFamilies8AgainFor8a lr
           INNER JOIN @tblAllFamilies8aVisits nv
               ON nv.QuarterNumber = lr.QuarterNumber

         -- 8b	
    INSERT INTO @tblAllFamilies8AgainFor8b
		 -- "8    a. Average Visits per Family"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'TotalFamiliesServed'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= QuarterStartDate
             ) -- not discharged or discharged after the quarter start date		
			 
         -- 8b
    INSERT INTO @tblAverageVisitsPerFamily8b_Cohort
       -- "8    b. % TANF Services Eligible at enrollment**"
       SELECT DISTINCT
              q8.QuarterNumber,
              COUNT(*) OVER (PARTITION BY q8.[QuarterNumber]) AS 'TANFServicesEligible',
              q8b.TotalFamiliesServed
       FROM @tblInitial_cohort h
           INNER JOIN CommonAttributes ca
               ON ca.HVCaseFK = h.HVCaseFK
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
           INNER JOIN @tblAllFamilies8AgainFor8b q8b
               ON q8b.QuarterNumber = q8.QuarterNumber
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= QuarterStartDate
             ) -- not discharged or discharged after the quarter start date	
             AND ca.TANFServices = 1
             AND ca.FormType = 'IN' -- only from Intake form here	

    INSERT INTO @tblAverageVisitsPerFamily8b
		 -- "8    b. % TANF Services Eligible at enrollment**"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(TANFServicesEligible, 0) AS TANFServicesEligible,
              ISNULL(TotalFamiliesServed, 0) AS TotalFamiliesServed
       FROM @tblAverageVisitsPerFamily8b_Cohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

         -- 8b
    INSERT INTO @tblAverageVisitsPerFamily8b_Final
       -- "8    b. % TANF Services Eligible at enrollment**"
       SELECT QuarterNumber,
              CONVERT(VARCHAR, TANFServicesEligible) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(
                                    COALESCE(
                                                CAST(TANFServicesEligible AS FLOAT) * 100
                                                / NULLIF(TotalFamiliesServed, 0),
                                                0
                                            ),
                                    0
                                )
                       ) + '%)' AS TANFServicesEligibleAtEnrollment
       FROM @tblAverageVisitsPerFamily8b

         -- 9
     INSERT INTO @tblLengthInProgram9
       -- "9. Length in Program for Active at End of Quarter"
       SELECT q8.QuarterNumber,
              CASE
                  WHEN (DATEDIFF(dd, h.IntakeDate, q8.[QuarterEndDate])
                       BETWEEN 0 AND 182
                       ) THEN
                      1
                  ELSE
                      0
              END AS 'LengthInProgramUnder6Months',
              CASE
                  WHEN (DATEDIFF(dd, h.IntakeDate, q8.[QuarterEndDate])
                       BETWEEN 183 AND 365
                       ) THEN
                      1
                  ELSE
                      0
              END AS 'LengthInProgramUnder6MonthsTo1Year',
              CASE
                  WHEN (DATEDIFF(dd, h.IntakeDate, q8.[QuarterEndDate])
                       BETWEEN 366 AND 730
                       ) THEN
                      1
                  ELSE
                      0
              END AS 'LengthInProgramUnder1YearTo2Year',
              CASE
                  WHEN (DATEDIFF(dd, h.IntakeDate, q8.[QuarterEndDate]) > 730) THEN
                      1
                  ELSE
                      0
              END AS 'LengthInProgramUnder2YearsAndOver'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate > [QuarterEndDate]
             ) -- active cases			

    INSERT INTO @tblLengthInProgram9_SumCohort
     -- "9. Length in Program for Active at End of Quarter"
       SELECT DISTINCT
              QuarterNumber,
              SUM(LengthInProgramUnder6Months) OVER (PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder6Months',
              SUM(LengthInProgram6MonthsTo1Year) OVER (PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder6MonthsTo1Year',
              SUM(LengthInProgram1YearTo2Year) OVER (PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder1YearTo2Year',
              SUM(LengthInProgram2YearsAndOver) OVER (PARTITION BY [QuarterNumber]) AS 'LengthInProgramUnder2YearsAndOver'
       FROM @tblLengthInProgram9

    INSERT INTO @tblLengthInProgram9_Sum
       -- "9. Length in Program for Active at End of Quarter"
       SELECT ISNULL(s1.QuarterNumber, q8.QuarterNumber) AS QuarterNumber,
              ISNULL(LengthInProgramUnder6Months, 0) AS LengthInProgramUnder6Months,
              ISNULL(LengthInProgram6MonthsTo1Year, 0) AS LengthInProgramUnder6MonthsTo1Year,
              ISNULL(LengthInProgram1YearTo2Year, 0) AS LengthInProgramUnder1YearTo2Year,
              ISNULL(LengthInProgram2YearsAndOver, 0) AS LengthInProgramUnder2YearsAndOver
       FROM @tblLengthInProgram9_SumCohort s1
           RIGHT JOIN @tblMake8Quarter q8
               ON q8.QuarterNumber = s1.QuarterNumber

    INSERT INTO @tblLengthInProgramAtEndOfThisQuarter9
       -- "6. Families Active at end of this Quarter"
       SELECT DISTINCT
              QuarterNumber,
              COUNT(h.HVCasePK) OVER (PARTITION BY [QuarterNumber]) AS 'FamiliesActiveAtEndOfThisQuarter'
       FROM @tblInitial_cohort h
           INNER JOIN @tblMake8Quarter q8
               ON h.IntakeDate <= [QuarterEndDate]
       WHERE h.IntakeDate IS NOT NULL
             AND
             (
                 h.DischargeDate IS NULL
                 OR h.DischargeDate >= QuarterEndDate
             )

    INSERT INTO @tblLengthInProgramFinal
     -- "9. Length in Program for Active at End of Quarter"
       SELECT cl.QuarterNumber,
              CONVERT(VARCHAR, LengthInProgramUnder6Months) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(
                                    COALESCE(
                                                CAST(LengthInProgramUnder6Months AS FLOAT) * 100
                                                / NULLIF(ct.FamiliesActiveAtEndOfThisQuarter, 0),
                                                0
                                            ),
                                    0
                                )
                       ) + '%)' AS LengthInProgramUnder6Months,
              CONVERT(VARCHAR, LengthInProgram6MonthsTo1Year) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(
                                    COALESCE(
                                                CAST(LengthInProgram6MonthsTo1Year AS FLOAT) * 100
                                                / NULLIF(ct.FamiliesActiveAtEndOfThisQuarter, 0),
                                                0
                                            ),
                                    0
                                )
                       ) + '%)' AS LengthInProgram6MonthsTo1Year,
              CONVERT(VARCHAR, LengthInProgram1YearTo2Year) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(
                                    COALESCE(
                                                CAST(LengthInProgram1YearTo2Year AS FLOAT) * 100
                                                / NULLIF(ct.FamiliesActiveAtEndOfThisQuarter, 0),
                                                0
                                            ),
                                    0
                                )
                       ) + '%)' AS LengthInProgram1YearTo2Year,
              CONVERT(VARCHAR, LengthInProgram2YearsAndOver) + ' ('
              + CONVERT(
                           VARCHAR,
                           ROUND(
                                    COALESCE(
                                                CAST(LengthInProgram2YearsAndOver AS FLOAT) * 100
                                                / NULLIF(ct.FamiliesActiveAtEndOfThisQuarter, 0),
                                                0
                                            ),
                                    0
                                )
                       ) + '%)' AS LengthInProgram2YearsAndOver
       FROM @tblLengthInProgram9_Sum cl
           INNER JOIN @tblLengthInProgramAtEndOfThisQuarter9 ct
               ON ct.QuarterNumber = cl.QuarterNumber

    ---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'


    --SELECT * FROM @tblLengthInProgram_Final


    -- For report Summary - Just add the new row (add another inner join for a newly created cte for the new row in the report summary) ... Khalsa

    INSERT INTO @tblQ8ReportMain
    (
        QuarterNumber,
        QuarterEndDate,
        numberOfScreens,
        numberOfKempAssessments,
        KempPositivePercentage,
        KempPositiveEnrolled,
        KempPositivePending,
        KempPositiveTerminated,
        AvgPositiveMotherScore,
        EnrolledAtBeginningOfQrtr,
        NewEnrollmentsThisQuarter,
        NewEnrollmentsPrenatal,
        TANFServicesEligible,
        FamiliesDischargedThisQuarter,
        FamiliesCompletingProgramThisQuarter,
        FamiliesActiveAtEndOfThisQuarter,
        FamiliesActiveAtEndOfThisQuarterOnLevel1,
        FamiliesActiveAtEndOfThisQuarterOnLevelX,
        FamiliesWithNoServiceReferrals,
        AverageVisitsPerMonthPerCase,
        TotalServedInQuarterIncludesClosedCases,
        AverageVisitsPerFamily,
        TANFServicesEligibleAtEnrollment,
        rowBlankforItem9,
        LengthInProgramUnder6Months,
        LengthInProgramUnder6MonthsTo1Year,
        LengthInProgramUnder1YearTo2Year,
        LengthInProgramUnder2YearsAndOver
    )
    SELECT scrns.QuarterNumber,
           LEFT(CONVERT(VARCHAR, q8.QuarterEndDate, 120), 10) AS QuarterEndDate, -- convert into string
           numberOfScreens,
           numberOfKempeAssessments,
           q82a.KempPositivePercentage,
           q82a1.KempPositiveEnrolledPercentage,
           q82a2.KempPositivePendingPercentage,
           q82a3.KempPositiveTerminatedPercentage,
           CONVERT(DECIMAL(4, 1), q82b.AvgPositiveMotherScore) AS AvgPositiveMotherScore,
           q83.EnrolledAtBeginningOfQrtr,
           q84.NewEnrollmentsThisQuarter,
           q84a.NewEnrollmentsPrenatalPercentage,
           q84b.TANFServicesEligiblePercentage,
           q85.FamiliesDischargedThisQuarter,
           q85a.FamiliesCompletingProgramThisQuarter,
           q86.FamiliesActiveAtEndOfThisQuarter,
           q86a.FamiliesActiveAtEndOfThisQuarterOnLevel1Percentage,
           q86b.FamiliesActiveAtEndOfThisQuarterOnLevelXPercentage,
           q86c.FamiliesWithNoServiceReferralsPercentage,
           q87.AverageVisitsPerMonthPerCase,
           q88.TotalServedInQuarterIncludesClosedCases,
           q88a.AverageVisitsPerFamily,
           q88b.TANFServicesEligibleAtEnrollment,
           '' AS rowBlankforItem9,
           q9.LengthInProgramUnder6MonthsPercentage,
           q9.LengthInProgram6MonthsTo1YearPercentage,
           q9.LengthInProgram1YearTo2YearPercentage,
           q9.LengthInProgram2YearsAndOverPercentage
    FROM @tblScreensFor1 scrns
        INNER JOIN @tblKempAssessmentsFor2 ka
            ON ka.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblKempAssessmentsFor2a_CalcPercentage q82a
            ON q82a.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblKempAssessmentsFor2a1_CalcPercentage q82a1
            ON q82a1.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblKempAssessmentsFor2a2_CalcPercentage q82a2
            ON q82a2.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblKempAssessmentsFor2a3_CalcPercentage q82a3
            ON q82a3.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblKempAssessmentsFor2b q82b
            ON q82b.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblEnrolledAtBeginningOfQuarter3 q83
            ON q83.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblNewEnrollmentsThisQuarter4 q84
            ON q84.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblNewEnrollmentsThisQuarter4a_CalcPercentage q84a
            ON q84a.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblNewEnrollmentsThisQuarter4b_CalcPercentage q84b
            ON q84b.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesDischargedThisQuarter5 q85
            ON q85.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesCompletingProgramThisQuarter5a q85a
            ON q85a.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter6 q86
            ON q86.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter6a_CalcPercentage q86a
            ON q86a.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter6b_CalcPercentage q86b
            ON q86b.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesWithNoServiceReferrals6c_CalcPercentage q86c
            ON q86c.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblFamiliesActiveAtEndOfThisQuarter7 q87
            ON q87.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblTotalServedInQuarterIncludesClosedCases8 q88
            ON q88.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblAverageVisitsPerFamily8a q88a
            ON q88a.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblAverageVisitsPerFamily8b_Final q88b
            ON q88b.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblLengthInProgramFinal q9
            ON q9.QuarterNumber = scrns.QuarterNumber
        INNER JOIN @tblMake8Quarter q8
            ON q8.QuarterNumber = scrns.QuarterNumber
    ORDER BY scrns.QuarterNumber;



    INSERT INTO @tblQ8ReportMain
    (
        QuarterNumber,
        QuarterEndDate,
        numberOfScreens,
        numberOfKempAssessments,
        KempPositivePercentage,
        KempPositiveEnrolled,
        KempPositivePending,
        KempPositiveTerminated,
        AvgPositiveMotherScore,
        EnrolledAtBeginningOfQrtr,
        NewEnrollmentsThisQuarter,
        NewEnrollmentsPrenatal,
        TANFServicesEligible,
        FamiliesDischargedThisQuarter,
        FamiliesCompletingProgramThisQuarter,
        FamiliesActiveAtEndOfThisQuarter,
        FamiliesActiveAtEndOfThisQuarterOnLevel1,
        FamiliesActiveAtEndOfThisQuarterOnLevelX,
        FamiliesWithNoServiceReferrals,
        AverageVisitsPerMonthPerCase,
        TotalServedInQuarterIncludesClosedCases,
        AverageVisitsPerFamily,
        TANFServicesEligibleAtEnrollment,
        rowBlankforItem9,
        LengthInProgramUnder6Months,
        LengthInProgramUnder6MonthsTo1Year,
        LengthInProgramUnder1YearTo2Year,
        LengthInProgramUnder2YearsAndOver
    )
    SELECT 99,
           'Last day of Quarter',
           '1. Total Screens',
           '2. Total Parent Surveys',
           '    a. % Positive',
           '        1. % Positive Enrolled',
           '        2. % Positive Pending Enrollment',
           '        3. % Positive Terminated',
           '    b. Average Positive Score',
           '3. Families Enrolled at Beginning of quarter',
           '4. New Enrollments this quarter',
           '    a. % Prenatal',
           '    b. % TANF Services Eligible at Enrollment**',
           '5. Families Discharged this quarter',
           '    a. Families completing the program',
           '6. Families Active at end of this Quarter',
           '    a. % on Level 1 at end of Quarter',
           '    b. % on Level CO at end of Quarter',
           '    c. % Families with no Service Referrals',
           '7. Average Visits per Month per Case on Level 1 or Level 1-SS',
           '8. Total Served in Quarter(includes closed cases)',
           '    a. Average Visits per Family',
           '    b. % TANF Services Eligible at enrollment**',
           '9. Length in Program for Active at End of Quarter',
           '    a. Under 6 months',
           '    b. 6 months up to 1 year',
           '    c. 1 year up to 2 years',
           '    d. 2 years and Over'

    -- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens
    -- add quarters with missing data. just add rows for those quarters with placeholders containing fake/imaginery data
    UNION ALL
    SELECT [QuarterNumber],
           LEFT(CONVERT(VARCHAR, QuarterEndDate, 120), 10) AS QuarterEndDate,
           [Col1],
           [Col2],
           [Col3],
           [Col4],
           [Col5],
           [Col6],
           [Col7],
           [Col8],
           [Col9],
           [Col10],
           [Col11],
           [Col12],
           [Col13],
           [Col14],
           [Col15],
           [Col16],
           [Col17],
           [Col18],
           [Col19],
           [Col20],
           [Col21],
           [Col22],
           [Col23],
           [Col24],
           [Col25],
           [Col26]
    FROM @tblMake8Quarter
    WHERE QuarterNumber NOT IN
          (
              SELECT QuarterNumber FROM @tblQ8ReportMain
          );

    ---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'
    --SELECT * from @tblQ8ReportMain

    -- Objective: Transpose Rows into Columns - what a pain in the ...
    -- Idea: Create 9 variable tables and later join them to get our final result
    -- Note: in each variable table, we are using UnPivot method  ... Khalsa


    DECLARE @tblcol99 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8LeftNavText] VARCHAR(MAX)
    );

    DECLARE @tblcol1 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col1] VARCHAR(MAX)
    );

    DECLARE @tblcol2 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col2] VARCHAR(MAX)
    );

    DECLARE @tblcol3 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col3] VARCHAR(MAX)
    );

    DECLARE @tblcol4 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col4] VARCHAR(MAX)
    );

    DECLARE @tblcol5 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col5] VARCHAR(MAX)
    );

    DECLARE @tblcol6 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col6] VARCHAR(MAX)
    );

    DECLARE @tblcol7 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col7] VARCHAR(MAX)
    );

    DECLARE @tblcol8 TABLE
    (
        [Q8Columns] VARCHAR(MAX),
        [Q8Col8] VARCHAR(MAX)
    );
    WITH cteCol99
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 99)
    INSERT INTO @tblcol99
    SELECT field,
           value
    FROM cteCol99 AS col1
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol99


    -- column1
    ;

    WITH cteCol1
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 1)
    INSERT INTO @tblcol1
    SELECT field,
           value
    FROM cteCol1 AS col1
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol1


    -- column2
    ;
    WITH cteCol2
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 2)
    INSERT INTO @tblcol2
    SELECT field,
           value
    FROM cteCol2 AS col2
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol2

    -- column3
    ;
    WITH cteCol3
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 3)
    INSERT INTO @tblcol3
    SELECT field,
           value
    FROM cteCol3 AS col3
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol3

    -- column4
    ;
    WITH cteCol4
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 4)
    INSERT INTO @tblcol4
    SELECT field,
           value
    FROM cteCol4 AS col4
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol4

    -- column5
    ;
    WITH cteCol5
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 5)
    INSERT INTO @tblcol5
    SELECT field,
           value
    FROM cteCol5 AS col5
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol5

    -- column6
    ;
    WITH cteCol6
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 6)
    INSERT INTO @tblcol6
    SELECT field,
           value
    FROM cteCol6 AS col6
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol6

    -- column7
    ;
    WITH cteCol7
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 7)
    INSERT INTO @tblcol7
    SELECT field,
           value
    FROM cteCol7 AS col7
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol7

    -- column8
    ;
    WITH cteCol8
    AS (SELECT *
        FROM @tblQ8ReportMain AS Q8Report
        WHERE Q8Report.QuarterNumber = 8)
    INSERT INTO @tblcol8
    SELECT field,
           value
    FROM cteCol8 AS col8
        UNPIVOT
        (
            value
            FOR field IN (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
                          KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
                          EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal,
                          TANFServicesEligible, FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
                          FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
                          FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
                          AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases,
                          AverageVisitsPerFamily, TANFServicesEligibleAtEnrollment, rowBlankforItem9,
                          LengthInProgramUnder6Months, LengthInProgramUnder6MonthsTo1Year,
                          LengthInProgramUnder1YearTo2Year, LengthInProgramUnder2YearsAndOver
                         )
        ) unpvtCol8;



    -- Now get the desired output ... Khalsa
    -- get all the columns and put them together now
    SELECT Q8LeftNavText,
           c1.Q8Col1,
           c2.Q8Col2,
           c3.Q8Col3,
           c4.Q8Col4,
           c5.Q8Col5,
           c6.Q8Col6,
           c7.Q8Col7,
           c8.Q8Col8
    FROM @tblcol99 c99
        INNER JOIN @tblcol1 c1
            ON c1.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol2 c2
            ON c2.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol3 c3
            ON c3.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol4 c4
            ON c4.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol5 c5
            ON c5.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol6 c6
            ON c6.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol7 c7
            ON c7.Q8Columns = c99.Q8Columns
        INNER JOIN @tblcol8 c8
            ON c8.Q8Columns = c99.Q8Columns;
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'
END;

GO
