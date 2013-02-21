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
	, case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	  end as TCDOB	 
	 ,DischargeDate

	 
	  FROM @tblPTCase ptc
INNER JOIN HVCase h ON ptc.hvcaseFK = h.HVCasePK 
inner join CaseProgram cp on ptc.hvcaseFK = cp.HVCaseFK
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
	SELECT *,
	datediff(day, tcdob, @sdate) aa,
	datediff(day,tcdob, lastdate) bb
	
	 FROM cteCohort
	WHERE datediff(day, tcdob, @sdate)	<= 548 AND datediff(day,tcdob, lastdate) >= 365
	

)




----------SELECT * FROM cteHD1TotalCases
------------ORDER BY OldID
----------ORDER BY pc1id
--ORDER BY HVCaseFK 

-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


--------------SELECT * FROM CaseProgram cp 
--------------INNER JOIN HVCase h ON h.HVCasePK = cp.HVCaseFK
--------------left join tcid on tcid.hvcasefk = h.hvcasepk
--------------WHERE PC1ID = 'BH92070201567'


--------------SELECT * FROM CaseProgram cp 
--------------INNER JOIN HVCase h ON h.HVCasePK = cp.HVCaseFK
--------------left join tcid on tcid.hvcasefk = h.hvcasepk
--------------WHERE PC1ID = 'AW88070032137'
--WHERE PC1ID = 'AW88070032137'










, cteHD1TotalCases1 AS
(
	SELECT * FROM cteCohort
	WHERE datediff(day, tcdob, @sdate)	<= 548 AND datediff(day,tcdob, lastdate) >= 365

)
, cteHD1TotalCases2 AS
(
	SELECT * FROM cteCohort
	WHERE datediff(day, tcdob, @sdate)	<= 548 AND datediff(day,tcdob, lastdate) >= 365

)

,

cteHD1ValidCases AS 
(
	SELECT DISTINCT 
	  coh.HVCaseFK
	, count(TCItemDate) over (partition BY coh.HVCaseFK) as 'DTaP_1Y'

	
	  FROM cteHD1TotalCases1 coh	  
	  LEFT join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK
	  inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem AND cmi.MedicalItemTitle = 'DTaP'

	 WHERE TCItemDate BETWEEN TCDOB AND dateadd(dd,365,TCDOB)
	GROUP BY coh.HVCaseFK, TCItemDate
	
)
,

cteHD1MeetPT AS 
(
	SELECT DISTINCT 
	  coh.HVCaseFK
	, count(TCItemDate) over (partition BY coh.HVCaseFK) as 'Polio_1Y'
	
	  FROM cteHD1TotalCases2 coh	  
	  LEFT join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK
	  INNER join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem AND cmi.MedicalItemTitle = 'Polio'

	 WHERE TCItemDate BETWEEN TCDOB AND dateadd(dd,365,TCDOB)
	 GROUP BY coh.HVCaseFK, TCItemDate
)


--SELECT * FROM cteHD1MeetPT
--ORDER BY HVCaseFK 

-- number who meet Performance Target
SELECT * FROM cteHD1ValidCases a 
LEFT JOIN cteHD1MeetPT b ON a.hvcasefk = b.hvcasefk 
WHERE DTaP_1Y >= 3 AND Polio_1Y >= 2

--SELECT * FROM cteHD1MeetPT

-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


/*** START - For testing By Khalsa ***/
DECLARE	@ReportTitleText [varchar](max)
DECLARE	@PercentageMeetingPT [varchar](50)
DECLARE	@NumberMeetingPT [varchar](50)
DECLARE	@TotalValidCases [varchar](50)
DECLARE	@TotalCase [varchar](50)	

SET @ReportTitleText	= ''
SET @PercentageMeetingPT = ''
SET @NumberMeetingPT = ''
SET @TotalValidCases = ''
SET @TotalCase = ''


--SELECT @ReportTitleText,@PercentageMeetingPT,@NumberMeetingPT,@TotalValidCases,@TotalCase

--SELECT * FROM @tblPTCase

/*** END - For testing By Khalsa ***/

end
GO
