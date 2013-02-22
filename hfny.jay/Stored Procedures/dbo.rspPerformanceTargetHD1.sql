
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 13, 2013>
-- Description:	<gets you data for Performance Target report - HD1. Immunizations at one year>
-- exec [rspPerformanceTargetHD1] '07/01/2012','09/30/2012','01',null,null


-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'

-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD1]
(    
    @sdate               datetime,
    @edate               datetime,
	@tblPTCase			 PTCases READONLY,
	@ReportType char(7) = NULL  
)

as
begin

DECLARE @HD1Total INT
DECLARE @HD1Valid INT
DECLARE @HD1Meet INT

DECLARE @tbl4PTReportHD1TotalCases TABLE(
			NumberMeetingPT INT,
			TotalValidCases INT,
			TotalCase INT 
)

DECLARE @tbl4PTReportHD1NotMeetingPT TABLE(
			ReportTitleText [varchar](max),
			PC1ID [char](13),					
			TCDOB [datetime],
			Reason [varchar](200),
			CurrentWorker [varchar](200),
			LevelAtEndOfReport [varchar](50),
			Explanation [varchar](60)

)

--DECLARE @tbl4PTReportHD1InvalidCases TABLE(
--			ReportTitleText [varchar](max),
--			PC1ID [char](13),
--			MetTarget BIT,
--			OutOfWindow VARCHAR(50),
--			NotReviewedBySupervisor	BIT,
--			Missing BIT,
--			FormType  varchar(2),			
--			TCDOB [datetime],
--			LevelAtEndOfReport [varchar](50),
--			ProgramName [varchar](60)

--)


;
WITH cteSubCohort AS
(
SELECT 	
	  ptc.HVCaseFK
	, ptc.PC1ID
	, cp.OldID 
	, ptc.PC1FullName
	, ptc.CurrentWorkerFK
	, ptc.CurrentWorkerFullName
	, ptc.CurrentLevel
	, ptc.ProgramFK
	, ptc.TCIDPK
	, case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	  end as TCDOB	 
	 ,DischargeDate

	 
	  FROM @tblPTCase ptc
INNER JOIN HVCase h ON ptc.hvcaseFK = h.HVCasePK 
INNER join CaseProgram cp on h.hvcasePK = cp.HVCaseFK -- AND cp.DischargeDate IS NULL
)



,

cteCohort AS
(
SELECT 	
	  HVCaseFK
	, PC1ID
	, OldID 
	, PC1FullName
	, CurrentWorkerFK
	, CurrentWorkerFullName
	, CurrentLevel
	, ProgramFK
	, TCIDPK
	, TCDOB
	, case
		   when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
			   datediff(day,tcdob, DischargeDate)	   
		   ELSE
			   datediff(day,tcdob, @eDate)	   
		end as tcAgeDays
		
	 , case
			   when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
				   DischargeDate
			   else
				   @eDate
		end as lastdate
		
	   
	  FROM cteSubCohort 

)





-- Report: HD1. Immunization at one year
, cteHD1TotalCases AS
(
	SELECT *	
	 FROM cteCohort	
	WHERE datediff(day, tcdob, @sdate)	<= 548 AND datediff(day,tcdob, lastdate) >= 365	

)
,
cteHD1Valid AS 
(
	SELECT DISTINCT 
	    coh.HVCaseFK
	  , coh.TCIDPK 
	  , CASE WHEN count(TCMedical.TCIDFK) > 0 THEN 1 ELSE 0 END AS valid

	
	  FROM cteHD1TotalCases coh	  
	  LEFT join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK  AND TCMedical.TCIDFK = coh.TCIDPK	

	 WHERE TCItemDate BETWEEN coh.TCDOB AND dateadd(dd,365,coh.TCDOB)	
	GROUP BY coh.HVCaseFK, coh.TCIDPK
)


,
--HD1: Meet 1 - count DTaP i.e. Diptheria Tetanus Pertussis shots for each child                              
cteHD1DTaP_1YCount AS 
(
	SELECT DISTINCT 
	  coh.HVCaseFK
	  , coh.TCIDPK 
	, count(coh.TCIDPK) as 'DTaP_1Y'
	
	
	  FROM cteHD1TotalCases coh	
	    
	  LEFT join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK AND TCMedical.TCIDFK = coh.TCIDPK
	  INNER join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem AND cmi.MedicalItemTitle = 'DTaP'

	 WHERE TCItemDate BETWEEN TCDOB AND dateadd(dd,365,TCDOB)
	 GROUP BY coh.HVCaseFK, coh.TCIDPK
)


--HD1: Meet 2 - count Polio i.e. Polio Immunization  shots for each child      
,
cteHD1Polio_1YCount AS 
(
	SELECT DISTINCT 
	  coh.HVCaseFK
	  , coh.TCIDPK 
	, count(coh.TCIDPK) as 'Polio_1Y'
	
	
	  FROM cteHD1TotalCases coh	
	    
	  LEFT join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK AND TCMedical.TCIDFK = coh.TCIDPK
	  INNER join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem AND cmi.MedicalItemTitle = 'Polio'

	 WHERE TCItemDate BETWEEN TCDOB AND dateadd(dd,365,TCDOB)
	 GROUP BY coh.HVCaseFK, coh.TCIDPK
)

,
cteHD1Meet AS (
-- HD1: number who meet Performance Target
-- Inner join HD1: Meet 1 and HD1: Meet 2
SELECT dtap.HVCaseFK
	 , dtap.TCIDPK
	 , DTaP_1Y 	
	 , Polio_1Y
 FROM cteHD1DTaP_1YCount dtap
INNER JOIN cteHD1Polio_1YCount polio ON dtap.hvcasefk = polio.hvcasefk  AND dtap.TCIDPK = polio.TCIDPK 
WHERE DTaP_1Y >= 3 AND Polio_1Y >= 2
)

,
cteHD1NotMeetingPT AS (
 SELECT 
		'HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age' AS ReportTitleText
	  , PC1ID
	  , TCDOB
	  , 'Missing Shots or Not on Time' AS Reason  
	  , CurrentWorkerFullName
	  , CurrentLevel
	  , '' AS Explanation
	  
	 FROM cteHD1TotalCases cht
	 WHERE cht.HVCaseFK NOT IN (SELECT HVCaseFK FROM cteHD1Meet) 
)

--SELECT * FROM cteHD1NotMeetingPT

-- add all these into a row in a table
INSERT INTO @tbl4PTReportHD1TotalCases
(
			NumberMeetingPT,
			TotalValidCases,
			TotalCase

)
select
			(SELECT count(HVCaseFK) FROM cteHD1TotalCases) AS NumberMeetingPT
			,(SELECT count(HVCaseFK) FROM cteHD1Valid) AS TotalValidCases
			,(SELECT count(HVCaseFK) FROM cteHD1Meet) AS TotalCase
			
			

--INSERT INTO @tbl4PTReportHD1NotMeetingPT
--(
--			ReportTitleText,
--			PC1ID,					
--			TCDOB,
--			Reason,
--			CurrentWorker,
--			LevelAtEndOfReport,
--			Explanation
--) 
-- SELECT * FROM cteHD1NotMeetingPT


			
			
			
			
			
			

----SELECT * FROM cteHD1Polio_1YCount
----ORDER BY HVCaseFK 

----SELECT * FROM cteHD1DTaP_1YCount
----ORDER BY HVCaseFK 

----SELECT * FROM cteHD1Meet
----ORDER BY HVCaseFK 

-- --  rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


IF @ReportType = 'summary'

		BEGIN 
		
	
			DECLARE	@NumberMeetingPT INT = 0
			DECLARE	@TotalValidCases INT = 0
			DECLARE	@TotalCase INT = 0

			SET @TotalCase = (SELECT NumberMeetingPT FROM @tbl4PTReportHD1TotalCases)
			SET @TotalValidCases = (SELECT TotalValidCases FROM @tbl4PTReportHD1TotalCases)
			SET @NumberMeetingPT = (SELECT TotalCase FROM @tbl4PTReportHD1TotalCases)
			
			if @TotalCase is null
			SET @TotalCase = 0
			
			if @TotalValidCases is null
			SET @TotalValidCases = 0
			
			if @NumberMeetingPT is null
			SET @NumberMeetingPT = 0


			DECLARE @tbl4PTReportHD1Summary TABLE(
						ReportTitleText [varchar](max),
						PercentageMeetingPT [varchar](200),
						NumberMeetingPT INT,
						TotalValidCases INT,
						TotalCase INT 
			)

			  



			INSERT INTO @tbl4PTReportHD1Summary([ReportTitleText],[PercentageMeetingPT],[NumberMeetingPT],[TotalValidCases],[TotalCase])
			VALUES('HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age' 	
				, ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@NumberMeetingPT AS FLOAT) * 100/ NULLIF(@TotalCase,0), 0), 0))  + '%)'
				,CONVERT(VARCHAR,@NumberMeetingPT)
				,CONVERT(VARCHAR,@TotalValidCases)
				,CONVERT(VARCHAR,@TotalCase)
				)

				SELECT * FROM @tbl4PTReportHD1Summary	

		END
--	ELSE
--		BEGIN
		
--			SELECT ReportTitleText
--				 , PC1ID
--				 , TCDOB
--				 , Reason
--				 , CurrentWorker
--				 , LevelAtEndOfReport
--				 , Explanation FROM @tbl4PTReportHD1NotMeetingPT
--					ORDER BY CurrentWorker, PC1ID 	


--		END	








end
GO
