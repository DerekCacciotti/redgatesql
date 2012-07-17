SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Jyly 16th, 2012>
-- Description:	<gets you data for Enrolled Program Caseload Quarterly and Contract Period>
-- exec [rspEnrolledProgramCaseload] 6,'07/01/2011','12/31/2011'
-- =============================================
CREATE procedure [dbo].[rspEnrolledProgramCaseload](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL
                                                                                                                  
                                                        )

as
BEGIN

    declare @ContractStartDate DATE
    declare @ContractEndDate DATE
    
    if @ProgramFK IS not NULL
    BEGIN 
		set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK)
		set @ContractEndDate = (select ContractEndDate FROM HVProgram P where HVProgramPK=@ProgramFK)
	END 

--SELECT @ContractStartDate

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int]

)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int]

)

-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK]
)
SELECT 
h.HVCasePK,h.IntakeDate,

case
   when h.tcdob is not null then
	   h.tcdob
   else
	   h.edc
end as tcdob

,h.TCNumber,cp.DischargeDate, cp.DischargeReason,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
FROM HVCase h 
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
WHERE 
cp.ProgramFK = @programfk

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK])
SELECT * FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)


--SELECT * FROM @tblInitRequiredData
---------------------------------------------

---------------------------------------------
--- **************************************** ---
-- Part 1: Families Enrolled at the beginning of the period	(QUARTERLY STATS)
-- declare a table variable for First row i.e. FamiliesEnrolled
declare @tblFamiliesEnrolledQuarterly table (
 NumberOfFamiliesEnrolledQuarterly [int],
 TCNumberQuarterly [int]
) 

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblFamiliesEnrolledQuarterly(
	[NumberOfFamiliesEnrolledQuarterly],
	[TCNumberQuarterly]

)
SELECT count(HVCasePK) AS NumOfFamiliesEnrolled,sum(TCNumber)AS TotalTCNumber FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @sdate
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)			

--SELECT * FROM @tblFamiliesEnrolled


DECLARE @TotalNumberOfFamiliesEnrolledQuarterly INT 
DECLARE @TotalTCNumberQuarterly INT
		
SET @TotalNumberOfFamiliesEnrolledQuarterly = (SELECT NumberOfFamiliesEnrolledQuarterly FROM @tblFamiliesEnrolledQuarterly) -- value for 1
SET @TotalTCNumberQuarterly = (SELECT TCNumberQuarterly FROM @tblFamiliesEnrolledQuarterly) -- value for 1.a	


--- **************************************** ---
-- Part 1: Families Enrolled at the beginning of the period (CONTRACT PERIOD STATS)	
-- NOTE: For contract period, our sdate is @ContractStartDate

-- declare a table variable for First row i.e. FamiliesEnrolled
declare @tblFamiliesEnrolledContractPeriod table (
 NumberOfFamiliesEnrolledContractPeriod [int],
 TCNumberContractPeriod [int]
) 

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblFamiliesEnrolledContractPeriod(
	[NumberOfFamiliesEnrolledContractPeriod],
	[TCNumberContractPeriod]

)
SELECT count(HVCasePK) AS NumOfFamiliesEnrolled,sum(TCNumber)AS TotalTCNumber FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @ContractStartDate
AND (DischargeDate IS NULL OR DischargeDate >= @ContractStartDate)	

DECLARE @NumberOfFamiliesEnrolled4ContractPeriod INT 
DECLARE @TCNumber4ContractPeriod INT 

SET @NumberOfFamiliesEnrolled4ContractPeriod = (SELECT NumberOfFamiliesEnrolledContractPeriod FROM @tblFamiliesEnrolledContractPeriod) -- value for 1
SET @TCNumber4ContractPeriod = (SELECT TCNumberContractPeriod FROM @tblFamiliesEnrolledContractPeriod) -- value for 1.a	
	
	

---------------------------------------------
--- **************************************** ---
-- Part 2: New families Prenatal v/s Postnatal at intake
-- Quarterly figures
DECLARE @TotalNumOfFamiliesEnrolledThisPeriodQuarterly INT 
DECLARE @TotalPrenatalFamiliesQuarterly INT 
DECLARE @TotalPostnatalFamiliesQuarterly INT 

-- table variable for holding Init Required Data
DECLARE @tblNewFamiliesThisPeriod TABLE(
	[NumOfFamiliesEnrolledQuarterly] [int],
	[PrenatalEnrollmentQuarterly] [int],
	[PostnatalEnrollmentQuarterly] [int]

)

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblNewFamiliesThisPeriod(
	[NumOfFamiliesEnrolledQuarterly],
	[PrenatalEnrollmentQuarterly],
	[PostnatalEnrollmentQuarterly]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesEnrolledThisPeriod
	,	
	sum(case
		when TCDOB is not null and TCDOB > IntakeDate then 
		   1
		 else
		   0		
	end) as PrenatalEnrollment
	,
	sum(case
		when TCDOB is not null and TCDOB <= IntakeDate THEN
		   1
		 else
		   0
		end) as PostnatalEnrollment	
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND IntakeDate BETWEEN @sdate AND @edate

Set @TotalNumOfFamiliesEnrolledThisPeriodQuarterly = (SELECT NumOfFamiliesEnrolledQuarterly FROM @tblNewFamiliesThisPeriod)
Set @TotalPrenatalFamiliesQuarterly = (SELECT PrenatalEnrollmentQuarterly FROM @tblNewFamiliesThisPeriod)
Set @TotalPostnatalFamiliesQuarterly = (SELECT PostnatalEnrollmentQuarterly FROM @tblNewFamiliesThisPeriod)

-- Add percentage to the numbers
DECLARE @TotalPrenatalFamiliesQuarterlyPCT VARCHAR(50)
DECLARE @TotalPostnatalFamiliesQuarterlyPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalPrenatalFamiliesQuarterlyPCT = CONVERT(VARCHAR,@TotalPrenatalFamiliesQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPrenatalFamiliesQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodQuarterly,0), 0), 0))  + '%)'
Set @TotalPostnatalFamiliesQuarterlyPCT = CONVERT(VARCHAR,@TotalPostnatalFamiliesQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPostnatalFamiliesQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodQuarterly,0), 0), 0))  + '%)'


-- Part 2: New families Prenatal v/s Postnatal at intake
-- ContractPeriod figures
DECLARE @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod INT 
DECLARE @TotalPrenatalFamiliesContractPeriod INT 
DECLARE @TotalPostnatalFamiliesContractPeriod INT 

-- table variable for holding Init Required Data
DECLARE @tblNewFamiliesThisPeriodContractPeriod TABLE(
	[NumOfFamiliesEnrolledContractPeriod] [int],
	[PrenatalEnrollmentContractPeriod] [int],
	[PostnatalEnrollmentContractPeriod] [int]

)

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblNewFamiliesThisPeriodContractPeriod(
	[NumOfFamiliesEnrolledContractPeriod],
	[PrenatalEnrollmentContractPeriod],
	[PostnatalEnrollmentContractPeriod]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesEnrolledThisPeriod
	,	
	sum(case
		when TCDOB is not null and TCDOB > IntakeDate then 
		   1
		 else
		   0		
	end) as PrenatalEnrollment
	,
	sum(case
		when TCDOB is not null and TCDOB <= IntakeDate THEN
		   1
		 else
		   0
		end) as PostnatalEnrollment	
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND IntakeDate BETWEEN @ContractStartDate AND @edate  -- make a note of @ContractStartDate field

Set @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod = (SELECT NumOfFamiliesEnrolledContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)
Set @TotalPrenatalFamiliesContractPeriod = (SELECT PrenatalEnrollmentContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)
Set @TotalPostnatalFamiliesContractPeriod = (SELECT PostnatalEnrollmentContractPeriod FROM @tblNewFamiliesThisPeriodContractPeriod)

-- Add percentage to the numbers
DECLARE @TotalPrenatalFamiliesContractPeriodPCT VARCHAR(50)
DECLARE @TotalPostnatalFamiliesContractPeriodPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalPrenatalFamiliesContractPeriodPCT = CONVERT(VARCHAR,@TotalPrenatalFamiliesContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPrenatalFamiliesContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodContractPeriod,0), 0), 0))  + '%)'
Set @TotalPostnatalFamiliesContractPeriodPCT = CONVERT(VARCHAR,@TotalPostnatalFamiliesContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalPostnatalFamiliesContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesEnrolledThisPeriodContractPeriod,0), 0), 0))  + '%)'

--- **************************************** ---

--- **************************************** ---
-- Part 3: Families discharged this period Quarterly
DECLARE @TotalNumOfFamiliesDischargedThisPeriodQuarterly INT 
DECLARE @TotalFamiliesCompletedProgramQuarterly INT 
DECLARE @TotalFamiliesNOTCompletedProgramQuarterly INT 

-- table variable for holding Init Required Data
DECLARE @tblNewFamiliesDischargedThisPeriodQuarterly TABLE(
	[NumOfFamiliesDischargedThisPeriodQuarterly] [int],
	[FamiliesCompletedProgramQuarterly] [int],
	[FamiliesNOTCompletedProgramQuarterly] [int]

)

-- Fill this table i.e. @tblFamiliesEnrolled as below
INSERT INTO @tblNewFamiliesDischargedThisPeriodQuarterly(
	[NumOfFamiliesDischargedThisPeriodQuarterly],
	[FamiliesCompletedProgramQuarterly],
	[FamiliesNOTCompletedProgramQuarterly]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesDischargedThisPeriod
	,	
	sum(case
		when DischargeDate is not null and DischargeReason IN (27,29) then 
		   1
		 else
		   0		
	end) as NumOfFamiliesCompletedProgram
	,
	sum(case
		when DischargeDate is not null and DischargeReason NOT IN (27,29) then 
		   1
		 else
		   0	
	end) as NumOfFamiliesNOTCompletedProgram
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND DischargeDate BETWEEN @sdate AND @edate

Set @TotalNumOfFamiliesDischargedThisPeriodQuarterly = (SELECT NumOfFamiliesDischargedThisPeriodQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)
Set @TotalFamiliesCompletedProgramQuarterly = (SELECT FamiliesCompletedProgramQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)
Set @TotalFamiliesNOTCompletedProgramQuarterly = (SELECT FamiliesNOTCompletedProgramQuarterly FROM @tblNewFamiliesDischargedThisPeriodQuarterly)

--SELECT @TotalFamiliesCompletedProgramQuarterly, @TotalFamiliesNOTCompletedProgramQuarterly

-- Add percentage to the numbers
DECLARE @TotalFamiliesCompletedProgramQuarterlyPCT VARCHAR(50)
DECLARE @TotalFamiliesNOTCompletedProgramQuarterlyPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalFamiliesCompletedProgramQuarterlyPCT = CONVERT(VARCHAR,@TotalFamiliesCompletedProgramQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesCompletedProgramQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedThisPeriodQuarterly,0), 0), 0))  + '%)'
Set @TotalFamiliesNOTCompletedProgramQuarterlyPCT = CONVERT(VARCHAR,@TotalFamiliesNOTCompletedProgramQuarterly) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesNOTCompletedProgramQuarterly AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedThisPeriodQuarterly,0), 0), 0))  + '%)'


--- **************************************** ---
-- Part 3: Families discharged during contract period
DECLARE @TotalNumOfFamiliesDischargedContractPeriod INT 
DECLARE @TotalFamiliesCompletedProgramContractPeriod INT 
DECLARE @TotalFamiliesNOTCompletedProgramContractPeriod INT 


DECLARE @tblNewFamiliesDischargedContractPeriod TABLE(
	[NumOfFamiliesDischargedContractPeriod] [int],
	[FamiliesCompletedProgramContractPeriod] [int],
	[FamiliesNOTCompletedProgramContractPeriod] [int]

)


INSERT INTO @tblNewFamiliesDischargedContractPeriod(
	[NumOfFamiliesDischargedContractPeriod],
	[FamiliesCompletedProgramContractPeriod],
	[FamiliesNOTCompletedProgramContractPeriod]
)

SELECT 
	count(HVCasePK) AS NumOfFamiliesDischargedThisPeriod
	,	
	sum(case
		when DischargeDate is not null and DischargeReason IN (27,29) then 
		   1
		 else
		   0		
	end) as NumOfFamiliesCompletedProgram
	,
	sum(case
		when DischargeDate is not null and DischargeReason NOT IN (27,29) then 
		   1
		 else
		   0	
	end) as NumOfFamiliesNOTCompletedProgram
	
 FROM @tblInitRequiredData
WHERE IntakeDate IS NOT NULL 
AND DischargeDate BETWEEN @ContractStartDate AND @edate  -- note we have repalce @sdate with @ContractStartDate

Set @TotalNumOfFamiliesDischargedContractPeriod = (SELECT NumOfFamiliesDischargedContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)
Set @TotalFamiliesCompletedProgramContractPeriod = (SELECT FamiliesCompletedProgramContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)
Set @TotalFamiliesNOTCompletedProgramContractPeriod = (SELECT FamiliesNOTCompletedProgramContractPeriod FROM @tblNewFamiliesDischargedContractPeriod)

--SELECT @TotalFamiliesCompletedProgramQuarterly, @TotalFamiliesNOTCompletedProgramQuarterly

-- Add percentage to the numbers
DECLARE @TotalFamiliesCompletedProgramContractPeriodPCT VARCHAR(50)
DECLARE @TotalFamiliesNOTCompletedProgramContractPeriodPCT VARCHAR(50)

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa
Set @TotalFamiliesCompletedProgramContractPeriodPCT = CONVERT(VARCHAR,@TotalFamiliesCompletedProgramContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesCompletedProgramContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedContractPeriod,0), 0), 0))  + '%)'
Set @TotalFamiliesNOTCompletedProgramContractPeriodPCT = CONVERT(VARCHAR,@TotalFamiliesNOTCompletedProgramContractPeriod) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@TotalFamiliesNOTCompletedProgramContractPeriod AS FLOAT) * 100/ NULLIF(@TotalNumOfFamiliesDischargedContractPeriod,0), 0), 0))  + '%)'



--- **************************************** ---
--- **************************************** ---
-- Part 4: Families discharged detail reports follow

-- Quartery detail report
DECLARE @countFamilyDischarged INT

-- Idea: Create two tables, one for each i.e. Quarterly and ContractPeriod
-- and then join them together to get 3 required columns, we are interested in

-- table for Quarterly
declare @tblFamilyDischargedQuarterly table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamiliesQTRLY varchar(50) NULL 
)

-- table for ContractPeriod
-- CP = Contract Period
declare @tblFamilyDischargedCP table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamiliesCP varchar(50) NULL 
)

-- Combine table to join above quarterly and  ContractPeriod tables
declare @tblFamilyDischargedQTRLYAndCP table (
 DischargeReasonText varchar(500) NULL 
 ,NumberOfFamiliesQTRLY varchar(50) NULL 
 ,NumberOfFamiliesCP varchar(50) NULL 
)

declare @tblFamilyDischarged table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamilies INT
)
;

	WITH cteCodeDischarge
	AS
	(		
				
				SELECT 	d.DischargeReason,d.DischargeCode FROM codeDischarge d  				
						WHERE DischargeUsedWhere LIKE '%DS%'	
	)	
	,

	cteMain 
			as (			
				
				SELECT 
					DischargeReason
					,
					case
						when DischargeDate is not null then 
						   1
						 else
						   0		
					end as NumOfFamiliesCompletedProgramOrNot

					
				 FROM @tblInitRequiredData
				WHERE IntakeDate IS NOT NULL 
				AND DischargeDate BETWEEN @sDate AND @edate	
				--AND DischargeDate BETWEEN @ContractStartDate AND @edate				
			
			)
			
	INSERT INTO @tblFamilyDischarged		
				SELECT cd.DischargeReason
				,isnull(cm.NumOfFamiliesCompletedProgramOrNot,0) AS NumOfFamiliesCompletedProgramOrNot				
				 FROM cteCodeDischarge cd
				LEFT JOIN cteMain cm ON cd.DischargeCode = cm.DischargeReason



--calculate the totals that will we use to caclualte percentages
Set @countFamilyDischarged = (SELECT sum(NumberOfFamilies) FROM @tblFamilyDischarged )		

INSERT INTO @tblFamilyDischargedQuarterly			
SELECT DischargeReasonText
 ,CONVERT(VARCHAR,sum(NumberOfFamilies)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(sum(NumberOfFamilies) AS FLOAT) * 100/ NULLIF(@countFamilyDischarged,0), 0), 0))  + '%)' AS TotalFamilyDischarged
 FROM @tblFamilyDischarged	
GROUP BY DischargeReasonText


-- *********************************
-- Contract Period detail report
DECLARE @countFamilyDischargedContractPeriod INT

declare @tblFamilyDischargedContractPeriod table (
 DischargeReasonText varchar(500) NULL 
,NumberOfFamilies INT
)
;

	WITH cteCodeDischargeContractPeriod
	AS
	(		
				
				SELECT 	d.DischargeReason,d.DischargeCode FROM codeDischarge d  				
						WHERE DischargeUsedWhere LIKE '%DS%'	
	)	
	,

	cteMainContractPeriod 
			as (			
				
				SELECT 
					DischargeReason
					,
					case
						when DischargeDate is not null then 
						   1
						 else
						   0		
					end as NumOfFamiliesCompletedProgramOrNot

					
				 FROM @tblInitRequiredData
				WHERE IntakeDate IS NOT NULL 				
				AND DischargeDate BETWEEN @ContractStartDate AND @edate				
			
			)
			
	INSERT INTO @tblFamilyDischargedContractPeriod		
				SELECT cd.DischargeReason
				,isnull(cm.NumOfFamiliesCompletedProgramOrNot,0) AS NumOfFamiliesCompletedProgramOrNot				
				 FROM cteCodeDischargeContractPeriod cd
				LEFT JOIN cteMainContractPeriod cm ON cd.DischargeCode = cm.DischargeReason
						
			



--INSERT INTO @tblFamilyDischarged SELECT DischargeReason, codeDischargePK FROM cteFamilyDischarged

--calculate the totals that will we use to caclualte percentages
Set @countFamilyDischargedContractPeriod = (SELECT sum(NumberOfFamilies) FROM @tblFamilyDischargedContractPeriod )		

INSERT INTO @tblFamilyDischargedCP				
SELECT DischargeReasonText
 ,CONVERT(VARCHAR,sum(NumberOfFamilies)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(sum(NumberOfFamilies) AS FLOAT) * 100/ NULLIF(@countFamilyDischargedContractPeriod,0), 0), 0))  + '%)' AS TotalFamilyDischargedContractPeriod
 FROM @tblFamilyDischargedContractPeriod	
GROUP BY DischargeReasonText

--- **************************************** ---
--- **************************************** ---
-- End Of Part 4: Families discharged detail reports follow
--- **************************************** ---
--- **************************************** ---




DECLARE @tblEnrolledProgramCaseload TABLE(
	[CaseLoadText] VARCHAR(500),
	[CaseLoadQuarterlyData] VARCHAR(50),
	[CaseLoadContractPeriodData] VARCHAR(50)
)

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('1. Families Active at the beginning of period', @TotalNumberOfFamiliesEnrolledQuarterly, @NumberOfFamiliesEnrolled4ContractPeriod)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('		a. Target Children', @TotalTCNumberQuarterly, @TCNumber4ContractPeriod)

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('2. New Families enrolled in the Home Visiting program this period', @TotalNumOfFamiliesEnrolledThisPeriodQuarterly, @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('		a. Prenatal at intake', @TotalPrenatalFamiliesQuarterlyPCT, @TotalPrenatalFamiliesContractPeriodPCT)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('		b. Postnatal at intake', @TotalPostnatalFamiliesQuarterlyPCT, @TotalPostnatalFamiliesContractPeriodPCT)

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('3. Families Discharged this period', @TotalNumOfFamiliesDischargedThisPeriodQuarterly, @TotalNumOfFamiliesDischargedContractPeriod)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('		a. Completed Program', @TotalFamiliesCompletedProgramQuarterlyPCT, @TotalFamiliesCompletedProgramContractPeriodPCT)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('		b. Did not Complete Program', @TotalFamiliesNOTCompletedProgramQuarterlyPCT, @TotalFamiliesNOTCompletedProgramContractPeriodPCT)

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row


-- insert Part4 - Family discharged reasons
INSERT INTO @tblEnrolledProgramCaseload
SELECT tblQ.DischargeReasonText, tblQ.NumberOfFamiliesQTRLY, tblCP.NumberOfFamiliesCP  FROM @tblFamilyDischargedQuarterly tblQ
INNER JOIN @tblFamilyDischargedCP tblCP ON tblQ.DischargeReasonText = tblCP.DischargeReasonText

INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('','', '') --insert empty row

-- Calculate totals (last row)
INSERT INTO @tblEnrolledProgramCaseload([CaseLoadText],[CaseLoadQuarterlyData],[CaseLoadContractPeriodData])VALUES('Families enrolled at the end of period',
@TotalNumberOfFamiliesEnrolledQuarterly + @TotalNumOfFamiliesEnrolledThisPeriodQuarterly - @TotalNumOfFamiliesDischargedThisPeriodQuarterly,
 @NumberOfFamiliesEnrolled4ContractPeriod + @TotalNumOfFamiliesEnrolledThisPeriodContractPeriod - @TotalNumOfFamiliesDischargedContractPeriod) 



SELECT * FROM @tblEnrolledProgramCaseload

end
GO
