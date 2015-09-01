
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <04/04/2013>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'

-- =============================================


CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Summary](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

DECLARE @tbl4CredentialingKempeAnalysis TABLE(
	SummaryText [varchar](200),
	TotalEnrolled [varchar](100),
	TotalNotEnrolled [varchar](100),
	Totals4NotEnrolled_Refused [varchar](100),
	Totals4NotEnrolled_UnableToLocate [varchar](100),
	Totals4NotEnrolled_TCAgedOut [varchar](100),
	Totals4NotEnrolled_OutOfTargetArea [varchar](100),
	Totals4NotEnrolled_Transfered [varchar](100),
	Totals4NotEnrolled_AllOthers [varchar](100)
)
	

DECLARE @tblCohort TABLE(
	HVCasePK INT, 	
	TCDOB [datetime],
	DischargeDate [datetime],
	IntakeDate [datetime],
	KempeDate [datetime],
	PC1FK INT, 	
	DischargeReason [char](2),		
	[OldID] [char](23),	
	[PC1ID] [char](13),	
	KempeResult BIT,
	CurrentFSWFK INT, 	
	CurrentFAWFK INT,
	babydate [datetime],
	testdate [datetime],
	PCDOB [datetime],
	Race [char](2),
	MaritalStatus [char](2),	
	HighestGrade [char](2),
	IsCurrentlyEmployed [char](1),
	OBPInHome [char](1),
	MomScore INT,
	DadScore int,
	FOBPresent bit,
	MOBPresent bit,
	MOBPartnerPresent bit,
	OtherPresent bit,
	MOBPartner bit,
	FOBPartner bit,
	MOBGrandmother bit 	

)

INSERT INTO @tblCohort(
	HVCasePK,
	TCDOB,
	DischargeDate,
	IntakeDate,
	KempeDate,
	PC1FK,	
	DischargeReason,		
	[OldID],
	[PC1ID],
	KempeResult,
	CurrentFSWFK,	
	CurrentFAWFK,
	babydate,
	testdate,
	PCDOB,
	Race,
	MaritalStatus,
	HighestGrade,
	IsCurrentlyEmployed,
	OBPInHome,
	MomScore,
	DadScore,
	FOBPresent,
	MOBPresent, 
	MOBPartnerPresent,
	OtherPresent,
	MOBPartner, 
	FOBPartner,
	MOBGrandmother
	
)
	-- only include kempes that are positive and where there is a clos_date or an intake date.
	
	SELECT HVCasePK
		 , 	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as tcdob
		 , DischargeDate
		 , IntakeDate
		 , k.KempeDate
		 , PC1FK
		 , cp.DischargeReason
		 , OldID
		 , PC1ID		 
		 , KempeResult
		 , cp.CurrentFSWFK
		 , cp.CurrentFAWFK	
		 ,	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as babydate	
		 ,	case
			   when h.IntakeDate is not null then
				   h.IntakeDate
			   else
				   cp.DischargeDate 
			end as testdate	
		  , P.PCDOB 
		  , P.Race 
		  ,ca.MaritalStatus
		  ,ca.HighestGrade 
		  ,ca.IsCurrentlyEmployed
		  ,ca.OBPInHome  		
		  ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
		  ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore 
		  ,FOBPresent
		  ,MOBPresent 
		  ,MOBPartnerPresent
		  ,OtherPresent 
		  ,MOBPartnerPresent as MOBPartner 
		  ,FOBPartnerPresent as FOBPartner
		  ,GrandParentPresent as MOBGrandmother
	

	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'

	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
	AND k.KempeResult = 1
	AND k.KempeDate BETWEEN @StartDate AND @EndDate
	
	 --SELECT * FROM @tblCohort
	 --ORDER BY OldID 
	
-- **************************************** Here goes the report calcuations *********************	

-- We need to calculate %. So let us get ready
DECLARE @TotalEnrolled [varchar](100)
DECLARE @TotalNotEnrolled [varchar](100)
DECLARE @Totals [varchar](100)


Set @TotalEnrolled = (SELECT count(HVCasePK) as TotalEnrolled FROM @tblCohort WHERE IntakeDate  IS NOT NULL)
Set @TotalNotEnrolled = (SELECT count(HVCasePK) as TotalNotEnrolled FROM @tblCohort WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL)
Set @Totals = convert(varchar, (convert(int, @TotalEnrolled) + convert(int, @TotalNotEnrolled)) )



-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'

;
-- Totals -- 
WITH cteTotalEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , 'Totals ( N = ' + @Totals + ' )'  AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@Totals,0), 0), 0))  + '%)' AS TotalEnrolled
		
	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  
)
,
TotalNotEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@Totals,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 ,sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) [Totals4NotEnrolled_Refused]
			 ,sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) [Totals4NotEnrolled_UnableToLocate]
			 ,sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) [Totals4NotEnrolled_TCAgedOut]
			 ,sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) [Totals4NotEnrolled_OutOfTargetArea]
			 ,sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) [Totals4NotEnrolled_Transfered]
			 ,sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25')  THEN 1 ELSE 0 END) [Totals4NotEnrolled_AllOthers]
	
	FROM @tblCohort 
	WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL   
)

,
cteTotals AS
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_Refused) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_Refused AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_UnableToLocate) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_UnableToLocate AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_TCAgedOut) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_TCAgedOut AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_OutOfTargetArea) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_OutOfTargetArea AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_Transfered) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_Transfered AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
	 ,CONVERT(VARCHAR,Totals4NotEnrolled_AllOthers) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(Totals4NotEnrolled_AllOthers AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	 
	 FROM cteTotalEnrolled te
	 LEFT JOIN TotalNotEnrolled tne ON te.SummaryId = tne.SummaryId
	  
)


-- Totals --
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM CteTotals
--insert blank line
--INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT '','','','','','','','',''




---------- Age --
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Age','','','','','','','',''


;

WITH cteAgeEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Under 18' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND datediff(day,pcdob, testdate)/365.25  < 18
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      18 up to 20' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND datediff(day,pcdob, testdate)/365.25  >= 18 AND datediff(day,pcdob, testdate)/365.25  < 20
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      20 up to 30' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND datediff(day,pcdob, testdate)/365.25  >= 20 AND datediff(day,pcdob, testdate)/365.25  < 30
UNION	  
	SELECT	 
			 4 AS SummaryId
			 , '      30 and over' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND datediff(day,pcdob, testdate)/365.25  >= 30
	  
)
,
 cteAgeNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND datediff(day,pcdob, testdate)/365.25  < 18
	  
UNION	  
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND datediff(day,pcdob, testdate)/365.25  >= 18 AND datediff(day,pcdob, testdate)/365.25  < 20
	  
UNION	  
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND datediff(day,pcdob, testdate)/365.25  >= 20 AND datediff(day,pcdob, testdate)/365.25  < 30
UNION	  
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND datediff(day,pcdob, testdate)/365.25  >= 30	  
	  
)
,
cteAge AS -- put cteAgeEnrolled and cteAgeNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers


	 
	 FROM cteAgeEnrolled en
	 LEFT JOIN cteAgeNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)


-- Age -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteAge

-- Race -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Race','','','','','','','',''

;

WITH cteRaceEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      White, non-Hispanic' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '01'
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      Black, non-Hispanic' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '02'
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      Hispanic/Latina/Latino' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '03'
	  
UNION
	SELECT	 
			 4 AS SummaryId
			 , '      Asian' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '04'
UNION	  
	SELECT	 
			 5 AS SummaryId
			 , '      Native American' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '05'
UNION	  
	SELECT	 
			 6 AS SummaryId
			 , '      Multiracial' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '06'
	  
UNION	  
	SELECT	 
			 7 AS SummaryId
			 , '      Other' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race = '07'
UNION	  
	SELECT	 
			 8 AS SummaryId
			 , '      Missing' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND Race IS NULL or Race = ''

)
,
 cteRaceNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '01'
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '02'
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '03'
    UNION
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '04'
    UNION
	SELECT	 
			  5 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '05'
    UNION
	SELECT	 
			  6 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '06'
    UNION
	SELECT	 
			  7 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race = '07'

    UNION
	SELECT	 
			  8 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Race IS NULL or Race = '' 
  
	  
	  
)
,
cteRace AS -- put cteAgeEnrolled and cteAgeNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteRaceEnrolled en
	 LEFT JOIN cteRaceNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- Race data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteRace
-- Martial Status Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Martial Status','','','','','','','',''


-- Martial Status --
;

WITH cteMaritalStatusEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Married' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '01'
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      Not Married' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '02'

-- new
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      Separated' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '03'
UNION	  
	SELECT	 
			 4 AS SummaryId
			 , '      Divorced' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '04'
UNION	  
	SELECT	 
			 5 AS SummaryId
			 , '      Widowed' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '05'

UNION	  
	SELECT	 
			 6 AS SummaryId
			 , '      Unknown' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MaritalStatus = '06' OR MaritalStatus IS NULL
)
,
 cteMaritalStatusNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '01'
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '02'
	
	UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '03'
	
	UNION
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '04'
	
	UNION
	SELECT	 
			  5 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '05'
	
    UNION
	SELECT	 
			  6 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MaritalStatus = '06' OR MaritalStatus IS NULL

)
,
cteMaritalStatus AS  -- put cteMaritalStatusEnrolled and cteMaritalStatusNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteMaritalStatusEnrolled en
	 LEFT JOIN cteMaritalStatusNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- Marital Status data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteMaritalStatus
-- Education Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Education','','','','','','','',''





-- Education --
;

WITH cteEducationEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Less than 12' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND HighestGrade IN ('01','02')
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      HS/GED' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND HighestGrade IN ('03','04')
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      More than 12' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND HighestGrade IN ('05','06','07','08')
UNION	  
	SELECT	 
			 4 AS SummaryId
			 , '      Unknown' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND HighestGrade IS NULL 

)
,
 cteEducationNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND HighestGrade IN ('01','02')
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND HighestGrade IN ('03','04')
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND HighestGrade IN ('05','06','07','08')
    UNION
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND HighestGrade IS NULL 

	  
	  
)
,
cteEducation AS  -- put cteEducationEnrolled and cteEducationNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteEducationEnrolled en
	 LEFT JOIN cteEducationNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- Education data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteEducation
-- Employed Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Employed','','','','','','','',''



-- Employed --
;

WITH cteEmployedEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Yes' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND IsCurrentlyEmployed = 1
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      No' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND IsCurrentlyEmployed = 0


)
,
 cteEmployedNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND IsCurrentlyEmployed = 1
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND IsCurrentlyEmployed = 0
  
	  
)
,
cteEmployed AS  -- put cteEmployedEnrolled and cteEmployedNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteEmployedEnrolled en
	 LEFT JOIN cteEmployedNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- Employed data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteEmployed

-- Bio Father in home Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Bio Father in home','','','','','','','',''



-- Employed --
;

WITH cteOBPInHomeEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Yes' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND OBPInHome = 1
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      No' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND OBPInHome = 0
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      Unknown' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND OBPInHome IS NULL or (NOT (OBPInHome = 0 OR OBPInHome = 1))


)
,
 cteOBPInHomeNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND OBPInHome = 1
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND OBPInHome = 0
  UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND OBPInHome IS NULL or (NOT (OBPInHome = 0 OR OBPInHome = 1))
	  
)
,
cteOBPInHome AS  -- put cteOBPInHomeEnrolled and cteOBPInHomeNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteOBPInHomeEnrolled en
	 LEFT JOIN cteOBPInHomeNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- OBPInHome data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteOBPInHome

-- Whose Score Qualifies Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Whose Score Qualifies','','','','','','','',''



-- Whose Score Qualifies --
;

WITH ctekempqualEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      Mother' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MomScore >= 25 AND DadScore < 25
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      Father' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MomScore < 25 AND DadScore >= 25
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      Mother & Father' AS SummaryText
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort
	  WHERE IntakeDate  IS NOT NULL   
	  AND MomScore >= 25 AND DadScore >= 25

)
,
 ctekempqualNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MomScore >= 25 AND DadScore < 25
    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MomScore < 25 AND DadScore >= 25
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MomScore >= 25 AND DadScore >= 25  
	  
)
,
ctekempqual AS  -- put ctekempqualEnrolled and ctekempqualNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM ctekempqualEnrolled en
	 LEFT JOIN ctekempqualNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)

-- kempqual data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM ctekempqual

-- Kempe Score Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Kempe Score','','','','','','','',''



-- Kempe Score --
;

DECLARE @tblKempScore TABLE(
	HVCasePK INT, 
	KempScore INT

)

INSERT INTO @tblKempScore(
	HVCasePK,
	KempScore
)
SELECT HVCasePK
	,case WHEN MomScore > DadScore  then MomScore else DadScore end as KempScore 
 FROM @tblCohort

;

 WITH cteKempScoreEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      25-49' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND KempScore BETWEEN  25 AND 49
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      50-74' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND KempScore BETWEEN  50 AND 74
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      75+' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND KempScore >= 75

)
,
 cteKempScoreNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND KempScore BETWEEN  25 AND 49

    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND KempScore BETWEEN  50 AND 74
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblKempScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND KempScore >= 75
	  
)
,
cteKempScore AS  -- put cteKempScoreEnrolled and cteKempScoreNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteKempScoreEnrolled en
	 LEFT JOIN cteKempScoreNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)


-- KempScore data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteKempScore
-- PC1 Issues Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'PC1 Issues','','','','','','','',''



-- PC1 Issues --

DECLARE @tblPC1IssuesScore TABLE(
	HVCasePK INT, 
	DV int,
	MH int,
	SA int,
	IntakeDate [datetime],
	DischargeDate [datetime],
	DischargeReason [char](2)

)

INSERT INTO @tblPC1IssuesScore(
	HVCasePK,
	DV,
	MH,
	SA,
	IntakeDate,
	DischargeDate,
	DischargeReason
)
SELECT HVCasePK
		  ,case when DomesticViolence = 1 then 1 else 0 end as DV
		  ,case when (Depression = 1 or MentalIllness = 1) then 1 else 0 end as MH
		  ,case when (AlcoholAbuse = 1 or SubstanceAbuse = 1) then 1 else 0 end as SA
		  ,IntakeDate
		  ,DischargeDate
		  ,DischargeReason
 FROM @tblCohort h
left join PC1Issues pci on pci.hvcasefk = h.hvcasepk
where Interval='1'		 
 

;

 WITH ctePC1IssuesScoreEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      DV' AS SummaryText
			 ,CONVERT(VARCHAR, sum(pc1i.DV)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.DV) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblPC1IssuesScore pc1i	  
	  WHERE IntakeDate  IS NOT NULL   
	 
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      MH' AS SummaryText
			 ,CONVERT(VARCHAR, sum(pc1i.MH)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.MH) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblPC1IssuesScore pc1i	  
	  WHERE IntakeDate  IS NOT NULL   
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      SA' AS SummaryText
			 ,CONVERT(VARCHAR, sum(pc1i.SA)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.SA) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblPC1IssuesScore pc1i	  
	  WHERE IntakeDate  IS NOT NULL   

)
,
 ctePC1IssuesScoreNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, sum(pc1i.DV)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.DV) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	 FROM @tblPC1IssuesScore pc1i	  
	 WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	 and dv = 1
	 

    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, sum(pc1i.MH)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.MH) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	 FROM @tblPC1IssuesScore pc1i	  
	 WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	 and mh = 1
	 
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, sum(pc1i.SA)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(pc1i.SA) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	 FROM @tblPC1IssuesScore pc1i	  
	 WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	 and sa = 1
	  
)
,
ctePC1IssuesScore AS  -- put ctePC1IssuesScoreEnrolled and ctePC1IssuesScoreNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM ctePC1IssuesScoreEnrolled en
	 LEFT JOIN ctePC1IssuesScoreNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)


-- PC1IssuesScore data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM ctePC1IssuesScore

-- Trimester (at time of Enrollment /Discharge) Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Trimester (at time of Enrollment /Discharge)','','','','','','','',''



-- Trimester (at time of Enrollment /Discharge) --
;

DECLARE @tblTrimesterScore TABLE(
	HVCasePK INT, 
	Trimester int,
	babydate [datetime],
	testdate [datetime]

)

INSERT INTO @tblTrimesterScore(
	HVCasePK,
	Trimester,
	babydate,
	testdate
)
SELECT HVCasePK
	--,case WHEN datediff(d, testdate, babydate) < round(30.44*3,0)  then 3 
	--		 WHEN ( datediff(d, testdate, babydate) >= round(30.44*3,0) and datediff(d, testdate, babydate) < round(30.44*6,0) ) then 2
	--		  WHEN datediff(d, testdate, babydate) >= round(30.44*6,0) then 1
	--		   WHEN datediff(d, testdate, babydate) <= 0 then 4	
	--end as Trimester 
	
	,case WHEN datediff(d, testdate, babydate) > 0 and datediff(d, testdate, babydate) < 30.44*3  then 3 
			 WHEN ( datediff(d, testdate, babydate) >= 30.44*3 and datediff(d, testdate, babydate) < 30.44*6 ) then 2
			  WHEN datediff(d, testdate, babydate) >= round(30.44*6,0) then 1
			   WHEN datediff(d, testdate, babydate) <= 0 then 4	
	end as Trimester 	
	
	, babydate
	, testdate
 FROM @tblCohort

;

 WITH cteTrimesterScoreEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      1st' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND Trimester = 1
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      2nd' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND Trimester = 2
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      3rd' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND Trimester = 3
UNION	  
	SELECT	 
			 4 AS SummaryId
			 , '      Postnatal' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE IntakeDate  IS NOT NULL   
	  AND h.testdate >= h.babydate 
)
,
 cteTrimesterScoreNotEnrolled AS
( 
	SELECT	 
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Trimester = 1

    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Trimester = 2
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND Trimester = 3
    UNION
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  INNER JOIN @tblTrimesterScore hk ON hk.HVCasePK = h.HVCasePK
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND h.testdate >= h.babydate 
)
,
cteTrimesterScore AS  -- put cteTrimesterScoreEnrolled and cteTrimesterScoreNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM cteTrimesterScoreEnrolled en
	 LEFT JOIN cteTrimesterScoreNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)


-- TrimesterScore data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM cteTrimesterScore
-- Present at Assessment Blank Row -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT 'Present at Assessment','','','','','','','',''


-- PresentWho --
;


 WITH ctePresentWhoEnrolled AS
(
	SELECT	 
			 1 AS SummaryId
			 , '      MOB only' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h	  
	  WHERE IntakeDate  IS NOT NULL   
	  AND MOBPresent = 1 	  
	  AND ((FOBPresent is null or FOBPresent = 0)
	  and (MOBPartner is null or MOBPartner = 0)
	  and (FOBPartner is null or FOBPartner = 0)
	  and (MOBGrandmother is null or MOBGrandmother = 0)
	  and (otherPresent is null or otherPresent = 0))
	 
UNION	  
	SELECT	 
			 2 AS SummaryId
			 , '      Both Parents' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  
	  WHERE IntakeDate  IS NOT NULL  	  
	  AND MOBPresent = 1
	  AND FOBPresent  = 1
UNION	  
	SELECT	 
			 3 AS SummaryId
			 , '      FOBPresent' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  
	  WHERE IntakeDate  IS NOT NULL 	  
	  AND FOBPresent = 1 	  
	  AND ((MOBPresent is null or FOBPresent = 0)
	  and (MOBPartner is null or MOBPartner = 0)
	  and (FOBPartner is null or FOBPartner = 0)
	  and (MOBGrandmother is null or MOBGrandmother = 0)
	  and (otherPresent is null or otherPresent = 0))	  

UNION	  
	SELECT	 
			 4 AS SummaryId
			 , '      Parent and Current Partner' AS SummaryText
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalEnrolled,0), 0), 0))  + '%)' AS TotalEnrolled

	  FROM @tblCohort h
	  
	  WHERE IntakeDate  IS NOT NULL   
	  -- Parent and Current Partner
	  and (MOBPresent is not null or  FOBPresent is not null)
	  AND (MOBPartner = 1 or FOBPartner = 1 or MOBGrandmother= 1 or otherPresent= 1)
)
,
 ctePresentWhoNotEnrolled AS
( 
	SELECT	  -- Need to sit with JOhn
			  1 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND MOBPresent = 1 	  
	  AND ((FOBPresent is null or FOBPresent = 0)
	  and (MOBPartner is null or MOBPartner = 0)
	  and (FOBPartner is null or FOBPartner = 0)
	  and (MOBGrandmother is null or MOBGrandmother = 0)
	  and (otherPresent is null or otherPresent = 0))

    UNION
	SELECT	 
			  2 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  	 
	  AND MOBPresent = 1
	   AND FOBPresent  = 1
    UNION
	SELECT	 
			  3 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	  AND FOBPresent = 1 	  
	  AND ((MOBPresent is null or FOBPresent = 0)
	  and (MOBPartner is null or MOBPartner = 0)
	  and (FOBPartner is null or FOBPartner = 0)
	  and (MOBGrandmother is null or MOBGrandmother = 0)
	  and (otherPresent is null or otherPresent = 0))	  
    union   
	SELECT	 
			  4 AS SummaryId
			 ,CONVERT(VARCHAR, count(h.HVCasePK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( count(h.HVCasePK) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS TotalNotEnrolled	 
			 
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '36' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Refused
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '12' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_UnableToLocate
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '19' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_TCAgedOut
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason = '07' THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_OutOfTargetArea
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason IN ('25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_Transfered
			 ,CONVERT(VARCHAR, sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) )  + ' (' + CONVERT(VARCHAR, round(COALESCE(cast( sum(CASE WHEN DischargeReason NOT IN ('36','12','19','07','25') THEN 1 ELSE 0 END) AS FLOAT) * 100/ NULLIF(@TotalNotEnrolled,0), 0), 0))  + '%)' AS Totals4NotEnrolled_AllOthers

	  FROM @tblCohort h
	  
	  WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL 
	  -- Parent and Current Partner
	  and (MOBPresent is not null or  FOBPresent is not null)
	  AND (MOBPartner = 1 or FOBPartner = 1 or MOBGrandmother= 1 or otherPresent= 1)
)
,
ctePresentWho AS  -- put ctePresentWhoEnrolled and ctePresentWhoNotEnrolled together
(
SELECT 

	   SummaryText
	 , TotalEnrolled	
	 , TotalNotEnrolled
	 
	 ,CASE WHEN Totals4NotEnrolled_Refused IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Refused END AS Totals4NotEnrolled_Refused
	 ,CASE WHEN Totals4NotEnrolled_UnableToLocate IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_UnableToLocate END AS Totals4NotEnrolled_UnableToLocate
	 ,CASE WHEN Totals4NotEnrolled_TCAgedOut IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_TCAgedOut END AS Totals4NotEnrolled_TCAgedOut
	 ,CASE WHEN Totals4NotEnrolled_OutOfTargetArea IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_OutOfTargetArea END AS Totals4NotEnrolled_OutOfTargetArea
	 ,CASE WHEN Totals4NotEnrolled_Transfered IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_Transfered END AS Totals4NotEnrolled_Transfered
	 ,CASE WHEN Totals4NotEnrolled_AllOthers IS NULL  THEN '0(0%)' ELSE Totals4NotEnrolled_AllOthers END AS Totals4NotEnrolled_AllOthers
	 
	 FROM ctePresentWhoEnrolled en
	 LEFT JOIN ctePresentWhoNotEnrolled nen ON en.SummaryId = nen.SummaryId
	  
)


-- PresentWho data -- 
INSERT INTO @tbl4CredentialingKempeAnalysis (SummaryText,TotalEnrolled,TotalNotEnrolled,Totals4NotEnrolled_Refused,Totals4NotEnrolled_UnableToLocate,Totals4NotEnrolled_TCAgedOut,Totals4NotEnrolled_OutOfTargetArea,Totals4NotEnrolled_Transfered,Totals4NotEnrolled_AllOthers) SELECT * FROM ctePresentWho


SELECT * FROM @tbl4CredentialingKempeAnalysis
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'



GO
