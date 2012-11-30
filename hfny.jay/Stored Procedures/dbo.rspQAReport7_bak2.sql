SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'ASQs for Active Cases with Target Child 4 months or older, calc. DOB '>
-- rspQAReport7_bak2 1, 'summary'	--- for summary page
-- rspQAReport7_bak2 1			--- for main report - location = 2
-- rspQAReport7_bak2 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport7_bak2](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
--Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

Set @LastDayofPreviousMonth = '10/31/2012'

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport7_bak2Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	XDateAge INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	DevAge INT,
	GestationalAge INT,
	AgeInDays INT,
	TCDOD [datetime],
	TCIDPK INT, 
	TCName [varchar](200),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT
)



;
WITH cteMainReport7 AS
(
select 
	 h.HVCasePK, 
	cp.PC1ID,
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,

	-- Form due date is intake date plus 30.44 days
	dateadd(mm,1,h.IntakeDate) as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	case
	   when h.tcdob is not null then
		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
	   else
		   datediff(dd, h.edc, @LastDayofPreviousMonth)
	end as XDateAge,
	
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth],
	
	0 AS DevAge,
	
	case
	   when T.GestationalAge is null then
		 0
	   else
		   T.GestationalAge
	end as GestationalAge,
	T.TCDOD,
	
	case
	   when T.TCIDPK is null then
		 0
	   else
		   T.TCIDPK
	end as TCIDPK,	

	rtrim(T.TCLastName) + ', ' + rtrim(T.TCFirstName) TCName, 
	0 AS  	Missing ,
	0 AS 	OutOfWindow,
	0 AS 	RecOK
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	INNER JOIN TCID T ON T.HVCaseFK = h.HVCasePK 

	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	-- enrolled atleast 30 days as of analysis point		 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed as of analysis point


	--where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
	--		AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed
			--AND (( (@LastDayofPreviousMonth <= dateadd(M, 4, h.edc)) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth <= dateadd(M, 4, h.tcdob)) AND (h.edc IS NULL) ) )  
			--AND ( (@LastDayofPreviousMonth <= dateadd(M, 4, h.edc)) OR  (@LastDayofPreviousMonth <= dateadd(M, 4, h.tcdob)) )  

)
,
cteAgeInDays AS
(
select HVCasePK
	 , PC1ID
	 , tcdob
	 , FormDueDate
	 , worker
	 , LevelName
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , TCNumber
	 , MultipleBirth
	 , DevAge
	 , GestationalAge
	 , 
	case
	   when (XDateAge / 30.44) < 24 then
		 XDateAge - ((40 - GestationalAge) * 7)
	   else
		   XDateAge
	end as AgeInDays,
	TCDOD,
	TCIDPK, 
	TCName,
	Missing,
	OutOfWindow,
	RecOK 	

 FROM cteMainReport7

)




INSERT INTO @tbl4QAReport7_bak2Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	TCNumber,
	MultipleBirth,
	DevAge,
	GestationalAge,
	AgeInDays,
	TCDOD,
	TCIDPK, 
	TCName,
	Missing,
	OutOfWindow,
	RecOK 
)
select HVCasePK
	 , PC1ID
	 , tcdob
	 , FormDueDate
	 , worker
	 , LevelName
	 , IntakeDate
	 , DischargeDate
	 , CaseProgress
	 , XDateAge
	 , TCNumber
	 , MultipleBirth
	 , DevAge
	 , GestationalAge
	 , AgeInDays
	 , TCDOD
	 , TCIDPK 
	 , TCName
	 , Missing
	 , OutOfWindow
	 , RecOK 	

 FROM cteAgeInDays
 WHERE AgeInDays > 122 AND (tcdod > @LastDayofPreviousMonth OR tcdod IS NULL)  -- 122 need to be converted later on (Target Child 4 months or older)
 
 
UPDATE @tbl4QAReport7_bak2Detail SET TCName = '' WHERE TCName IS NULL



-- Equivelent to csrForm6 in foxpro	
--SELECT DISTINCT HVCasePK  FROM @tbl4QAReport7_bak2Detail



--SELECT * FROM @tbl4QAReport7_bak2Detail  -- Equivelent to csrForm6 in foxpro
--ORDER BY HVCasePK
 
--- rspQAReport7_bak2 1 ,'summary'

-- Get the intervals for each tcid
--DECLARE @tbl4QAReport7_bak2Interval TABLE(
--	HVCasePK INT,
--	Interval CHAR (2)
--)


--INSERT INTO @tbl4QAReport7_bak2Interval
--(
--HVCasePK,
--Interval
--)
--SELECT 
--		qa1.HVCasePK	 
--	  , max(Interval) AS Interval
 
-- FROM @tbl4QAReport7_bak2Detail qa1
-- inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays >= DueBy  
-- GROUP BY HVCasePK, QA1.TCIDPK -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
 
 
 DECLARE @tbl4QAReport7_bak2Interval TABLE(
	HVCasePK INT,
	TCIDFK INT,
	Interval CHAR (2)
)


INSERT INTO @tbl4QAReport7_bak2Interval
(
HVCasePK,
TCIDFK,
Interval
)
SELECT 
		qa1.HVCasePK
	  , qa1.TCIDPK 	 
	  , max(Interval) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
 
 FROM @tbl4QAReport7_bak2Detail qa1
 inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays >= DueBy  
 GROUP BY HVCasePK, QA1.TCIDPK -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
 
 
 
 
 
 --SELECT * FROM @tbl4QAReport7_bak2Interval
 --ORDER BY HVCasePK, TCIDFK
 
 --- rspQAReport7_bak2 1 ,'summary'


-- get expected records that are due for the Interval
DECLARE @tbl4QAReport7_bak2Expected TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	AgeInDays INT,
	TCNumber INT,
	MultipleBirth [char](3),	
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	[DueBy] [int] NOT NULL,
	[Interval] [char](2) NOT NULL,
	[MaximumDue] [int] NOT NULL,
	[MinimumDue] [int] NOT NULL,	
	FormDate [datetime],
	FormReviewed BIT,
	TCName [varchar](200),
	FormDueDate [datetime],
	GestationalAge INT,
	CalcDOB [datetime],
	TCIDPK INT,
	TCAge [char](2) NOT NULL,
	cteInterval [char](2) NOT NULL 
)


INSERT INTO @tbl4QAReport7_bak2Expected(
	HVCasePK,
	[PC1ID],
	TCDOB,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	XDateAge,
	AgeInDays,
	TCNumber,
	MultipleBirth,	
	Missing,
	OutOfWindow,
	RecOK,
	[DueBy],
	[Interval],
	[MaximumDue],
	[MinimumDue],	
	FormDate,
	FormReviewed,
	TCName,
	FormDueDate,
	GestationalAge,
	CalcDOB,
	TCIDPK,
	TCAge,
	cteInterval
) 
 SELECT qa1.HVCasePK
	  , PC1ID
	  , TCDOB
	  , Worker
	  , currentLevel
	  , IntakeDate
	  , DischargeDate
	  , CaseProgress
	  , XDateAge
	  , AgeInDays
	  , qa1.TCNumber
	  , qa1.MultipleBirth
	  , 0 AS Missing
	  	  ,  1  AS OutOfWindow
	  ,  0  AS RecOK 
	  --, CASE WHEN (ASQInWindow = 1) THEN 0 ELSE 1 END AS OutOfWindow
	  --, CASE WHEN (ASQInWindow = 1) THEN 1 ELSE 0 END AS RecOK 
	  , cd.[DueBy]
	  , cd.[Interval]
	  , cd.[MaximumDue]
	  , cd.[MinimumDue]		  
	  , getdate()  AS FormDate
	   --, DateCompleted  AS FormDate
	  , 1  AS FormReviewed
	  --, CASE WHEN dbo.IsFormReviewed(DateCompleted, 'AS', ASQPK)=1 THEN 1 ELSE 0 END AS FormReviewed
	  , qa1.TCName
	  , CASE WHEN (XDateAge/30.44) < 24  
	  THEN   dateadd(d, ((40 - qa1.GestationalAge) * 7) + cd.[DueBy], TCDOB) 	  
	  ELSE   dateadd(d, cd.[DueBy], TCDOB)
	  END AS FormDueDate
	  , qa1.GestationalAge
	  , CASE WHEN (XDateAge/30.44) < 24  
		  Then
		 dateadd(d, ((40 - qa1.GestationalAge) * 7), TCDOB)
		 ELSE
		 TCDOB
		 END
		  AS CalcDOB
	  , qa1.TCIDPK
	  ,	Q.TCAge
	,cteIn.Interval  
	  
 FROM @tbl4QAReport7_bak2Detail qa1 
 INNER JOIN @tbl4QAReport7_bak2Interval cteIn ON qa1.HVCasePK = cteIn.HVCasePK AND qa1.TCIDPK = cteIn.TCIDFK  -- we will use column 'Interval' next, which we just added
 inner join codeduebydates cd on scheduledevent = 'ASQ' AND cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
 -- The following line gets those tcid's with ASQ's that are due for the Interval
 INNER JOIN ASQ Q ON Q.TCIDFK  = qa1.TCIDPK -- AND Q.TCAge = cteIn.Interval -- note 'Interval' is the minimum interval 
 ORDER BY HVCasePK 
 
 
 SELECT * FROM @tbl4QAReport7_bak2Expected
 
 
------------ --- rspQAReport7_bak2 1 ,'summary'
 
 
------------ -- Looking into the missing ones
 
------------ -- Get the the last asq (max TCAge) that was done for each tcid
------------DECLARE @tbl4QAReport7_bak2Interval2 TABLE(
------------	HVCasePK INT,
------------	Interval CHAR (2)
------------)


------------INSERT INTO @tbl4QAReport7_bak2Interval2
------------(
------------HVCasePK,
------------Interval
------------)
------------SELECT 
------------		qa1.HVCasePK	 
------------	  , max(TCAge) AS Interval
 
------------ FROM @tbl4QAReport7_bak2Detail qa1
------------ LEFT JOIN ASQ A ON A.TCIDFK = qa1.TCIDPK  
------------ GROUP BY HVCasePK,qa1.TCIDPK 
 
 
 
------------ -- Get all the ASQs for all TCIDs in our cohort
------------ DECLARE @tbl4QAReport7_bak2Intervals4AllASQsInOurCohort TABLE(
------------	HVCaseFK INT,
------------	TCIDFK INT, 
------------	Interval CHAR (2),
------------	ASQTCReceiving [char](1)
------------)


------------INSERT INTO @tbl4QAReport7_bak2Intervals4AllASQsInOurCohort
------------(
------------	HVCaseFK,
------------	TCIDFK,
------------	Interval,
------------	ASQTCReceiving
------------) 
------------ SELECT qa3.HVCasePK,
------------		A.TCIDFK,
------------		A.TCAge,
------------		A.ASQTCReceiving 
------------  FROM ASQ A 
------------ INNER JOIN @tbl4QAReport7_bak2Detail qa3 ON qa3.TCIDPK = A.TCIDFK 
 
 
------------ --SELECT * FROM @tbl4QAReport7_bak2Intervals4AllASQsInOurCohort
------------ --ORDER BY TCIDFK 
 
------------ --- rspQAReport7_bak2 1 ,'summary'
 
 
------------ DECLARE @tbl4QAReport7_bak2NotExpected TABLE(
------------	HVCasePK INT,
------------	[PC1ID] [char](13),
------------	TCDOB [datetime],
------------	Worker [varchar](200),
------------	currentLevel [varchar](50),
------------	IntakeDate [datetime],
------------	DischargeDate [datetime],
------------	CaseProgress [NUMERIC](3),
------------	XDateAge INT,
------------	AgeInDays INT,
------------	TCNumber INT,
------------	MultipleBirth [char](3),	
------------	Missing BIT,
------------	OutOfWindow BIT,
------------	RecOK BIT,
------------	[DueBy] [int] NOT NULL,
------------	[Interval] [char](2) NOT NULL,
------------	[MaximumDue] [int] NOT NULL,
------------	[MinimumDue] [int] NOT NULL,	
------------	FormDate [datetime],
------------	FormReviewed BIT,
------------	TCName [varchar](200),
------------	FormDueDate [datetime],
------------	GestationalAge INT,
------------	CalcDOB [datetime],
------------	ASQTCReceiving [char](1),
------------	TCIDPK INT
------------)

-------------- missing ASQ's


------------INSERT INTO @tbl4QAReport7_bak2NotExpected(
------------	HVCasePK,
------------	[PC1ID],
------------	TCDOB,
------------	Worker,
------------	currentLevel,
------------	IntakeDate,
------------	DischargeDate,
------------	CaseProgress,
------------	XDateAge,
------------	AgeInDays,
------------	TCNumber,
------------	MultipleBirth,	
------------	Missing,
------------	OutOfWindow,
------------	RecOK,
------------	[DueBy],
------------	[Interval],
------------	[MaximumDue],
------------	[MinimumDue],	
------------	FormDate,
------------	FormReviewed,
------------	TCName,
------------	FormDueDate,
------------	GestationalAge,
------------	CalcDOB,
------------	ASQTCReceiving,
------------	TCIDPK
------------) 
------------ SELECT qa2.HVCasePK
------------	  , qa2.PC1ID
------------	  , qa2.TCDOB
------------	  , qa2.Worker
------------	  , qa2.currentLevel
------------	  , qa2.IntakeDate
------------	  , qa2.DischargeDate
------------	  , qa2.CaseProgress
------------	  , qa2.XDateAge
------------	  , qa2.AgeInDays
------------	  , qa2.TCNumber
------------	  , qa2.MultipleBirth
------------	  , 1 AS Missing
------------	  , qa2.OutOfWindow	
------------	  , CASE WHEN (ASQTCReceiving = 1) THEN 1 ELSE 0 END AS RecOK 
------------	  , cd.[DueBy]
------------	  , cd.[Interval]
------------	  , cd.[MaximumDue]
------------	  , cd.[MinimumDue]		  
------------	  , easq.FormDate AS FormDate
------------	  , NULL AS FormReviewed
------------	  , qa2.TCName
------------	  , CASE WHEN (qa2.XDateAge/30.44) < 24  
------------	  THEN   dateadd(d, ((40 - qa2.GestationalAge) * 7) + cd.[DueBy], qa2.TCDOB) 	  
------------	  ELSE   dateadd(d, cd.[DueBy], qa2.TCDOB)
------------	  END AS FormDueDate
------------	  , qa2.GestationalAge
------------	  , CASE WHEN (qa2.XDateAge/30.44) < 24  
------------		  Then
------------		 dateadd(d, ((40 - qa2.GestationalAge) * 7), qa2.TCDOB)
------------		 ELSE
------------		 qa2.TCDOB
------------		 END
------------		  AS CalcDOB
------------	  , qa4.ASQTCReceiving
------------	  , qa2.TCIDPK
	  
------------ FROM @tbl4QAReport7_bak2Detail qa2 
------------ LEFT JOIN @tbl4QAReport7_bak2Interval2 cteIn2 ON qa2.HVCasePK = cteIn2.HVCasePK -- we will use column 'Interval' next, which we just added
------------ LEFT JOIN @tbl4QAReport7_bak2Expected easq on easq.hvcasepk = qa2.HVCasePK 
------------ inner join codeduebydates cd on scheduledevent = 'ASQ' AND cteIn2.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
------------ LEFT JOIN @tbl4QAReport7_bak2Intervals4AllASQsInOurCohort qa4 ON qa4.TCIDFK  = qa2.TCIDPK  AND cteIn2.Interval = qa4.Interval  -- in foxpro i.e. LOCATE FOR ALLTRIM(tc_age)=ALLTRIM(STR(aqs.max_tcage,2,0))
--------------LEFT JOIN ASQ Q ON Q.TCIDFK  = qa2.TCIDPK AND Q.TCAge = cteIn2.Interval -- note 'Interval' is the minimum interval 
------------WHERE 
------------easq.hvcasepk IS NULL 
 
 
------------ SELECT * FROM @tbl4QAReport7_bak2NotExpected
------------ WHERE ASQTCReceiving = 0 
 

------------SELECT HVCasePK
------------	 , PC1ID
------------	 , TCDOB
------------	 , Worker
------------	 , currentLevel
------------	 , IntakeDate
------------	 , DischargeDate
------------	 , CaseProgress
------------	 , XDateAge
------------	 , AgeInDays
------------	 , TCNumber
------------	 , MultipleBirth	 
------------	 , Missing
------------	 , OutOfWindow
------------	 , 1 as RecOK
------------	 , DueBy
------------	 , qa4.Interval
------------	 , MaximumDue
------------	 , MinimumDue
------------	 , FormDate
------------	 , FormReviewed
------------	 , TCName
------------	 , FormDueDate
------------	 , GestationalAge
------------	 , CalcDOB
------------	 , qa04.ASQTCReceiving
------------	 , TCIDPK
	 
------------FROM @tbl4QAReport7_bak2NotExpected qa04
------------INNER JOIN @tbl4QAReport7_bak2Intervals4AllASQsInOurCohort qa4 ON qa4.TCIDFK  = qa04.TCIDPK AND qa4.Interval = '04'
------------where 
------------qa04.ASQTCReceiving = 0 
------------AND
------------qa04.Interval = '06'


--------------- rspQAReport7_bak2 1 ,'summary'
GO
