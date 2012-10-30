SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'ASQs for Active Cases with Target Child 4 months or older, calc. DOB '>
-- rspQAReport7 31, 'summary'	--- for summary page
-- rspQAReport7 31			--- for main report - location = 2
-- rspQAReport7 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport7](
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

Set @LastDayofPreviousMonth = '05/31/2012'

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport7Detail TABLE(
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

	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)  --- case not closed
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




INSERT INTO @tbl4QAReport7Detail(
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
 WHERE AgeInDays > 122 AND (tcdod > @LastDayofPreviousMonth OR tcdod IS NULL)  -- 122 need to be converted later on
 
 
UPDATE @tbl4QAReport7Detail SET TCName = '' WHERE TCName IS NULL



-- Equivelent to csrForm6 in foxpro	
--SELECT DISTINCT HVCasePK  FROM @tbl4QAReport7Detail
SELECT * FROM @tbl4QAReport7Detail  -- Equivelent to csrForm6 in foxpro
ORDER BY HVCasePK
 
--- rspQAReport7 31 ,'summary'

DECLARE @tbl4QAReport7DetailEF TABLE(
	HVCasePK INT,
	[PC1ID] [char](13),
	TCDOB [datetime],
	FormDueDate [datetime],
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC](3),
	XDateAge INT,
	DevAge INT,
	GestationalAge INT,
	AgeInDays INT,
	TCDOD [datetime],
	TCIDPK INT,
	TCName [varchar](200),
	Missing BIT,
	OutOfWindow BIT,
	RecOK BIT,
	ASQTCReceiving [char](1),
	ASQInWindow BIT,
	FormDoneDateCompleted [datetime]
)

--SELECT 
--		qa1.HVCasePK
--		,AgeInDays
--		,DueBy	 
--	  , Interval
 
-- FROM @tbl4QAReport7Detail qa1 --, @tbl4DueByDates 
-- inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays <= DueBy  
-- --GROUP BY HVCasePK
-- ORDER BY AgeInDays desc

;
-- eliminates records where AgeInDays > 1856
WITH cteInterval AS
(
SELECT 
		qa1.HVCasePK	 
	  , min(Interval) AS Interval
	  ,TCIDPK
 
 FROM @tbl4QAReport7Detail qa1
 inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays <= DueBy  
 GROUP BY HVCasePK, TCIDPK  -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
)

--- rspQAReport7 31 ,'summary'

--SELECT * FROM cteInterval
--ORDER BY HVCasePK


--SELECT 
--		qa1.HVCasePK	 
--	  , min(Interval) AS Interval

-- FROM @tbl4QAReport7Detail qa1 --, @tbl4DueByDates 
-- inner join codeduebydates on scheduledevent = 'ASQ' AND AgeInDays <= DueBy  
-- GROUP BY HVCasePK

--- rspQAReport7 31 ,'summary'


INSERT INTO @tbl4QAReport7DetailEF(
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
	DevAge,
	GestationalAge,
	AgeInDays,
	TCDOD,
	TCIDPK,
	TCName,
	Missing,
	OutOfWindow,
	RecOK,	
	ASQTCReceiving,
	ASQInWindow,
	FormDoneDateCompleted
) 
 SELECT 
		qa1.HVCasePK
	  , [PC1ID]
	  , TCDOB
	  , FormDueDate
	  , Worker
	  , currentLevel
	  , IntakeDate
	  , DischargeDate
	  , CaseProgress
	  , XDateAge
	  , DevAge
	  , GestationalAge
	  , AgeInDays
	  , TCDOD
	  , qa1.TCIDPK
	  , TCName
	  , Missing
	  , CASE WHEN ((ASQTCReceiving <> '1') AND (ASQInWindow = 0)) THEN 1 ELSE 0 END AS OutOfWindow	 
	  , CASE WHEN ((ASQTCReceiving <> '1') AND (ASQInWindow = 0)) THEN 0 ELSE 1 END AS RecOK 
	 
	  , ASQTCReceiving
	  ,	ASQInWindow
	  , DateCompleted  AS FormDoneDateCompleted 
 
 FROM @tbl4QAReport7Detail qa1 --, @tbl4DueByDates 
 INNER JOIN cteInterval cteIn ON qa1.TCIDPK = cteIn.TCIDPK -- we will use column 'Interval' next
 -- The following line gets those tcid's with ASQ's that are due for the Interval
 INNER JOIN ASQ A ON A.TCIDFK = qa1.TCIDPK AND A.TCAge = cteIn.Interval -- note 'Interval' is the minimum interval
 
 
 SELECT * FROM @tbl4QAReport7DetailEF
 --WHERE  OutOfWindow = 1

	
--- rspQAReport7 31 ,'summary'

--SELECT * FROM @tbl4QAReport7Detail qa7
----inner join codeduebydates on scheduledevent = 'ASQ'


--INNER JOIN ASQ A ON qa7.TCIDPK = A.TCIDFK AND qa7.
--WHERE AgeInDays > 122 AND (tcdod > @LastDayofPreviousMonth OR tcdod IS NULL)



--IF @ReportType = 'summary'

--	BEGIN 

--	DECLARE @numOfALLScreens INT = 0
--	SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport7Detail
--	WHERE AgeInDays > 122 AND (tcdod > @LastDayofPreviousMonth OR tcdod IS NULL))

--	DECLARE @numOfActiveIntakeCases INT = 0
--	SET @numOfActiveIntakeCases = (
--	SELECT count(HVCasePK) FROM @tbl4QAReport7Detail
--	WHERE HVCasePK NOT IN 
--		(
--		SELECT HVCaseFK FROM Intake i 
--		inner join dbo.SplitString(@programfk,',') on i.programfk = listitem
--		)			

--	)

--DECLARE tbl4QAReport7Summary TABLE(
--	[SummaryId] INT,
--	[SummaryText] [varchar](200),
--	[SummaryTotal] [varchar](100)
--)

--INSERT INTO tbl4QAReport7Summary([SummaryId],[SummaryText],[SummaryTotal])
--VALUES(7 ,'ASQs for Active Cases with Target Child 4 months or older, calc. DOB (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
--	,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
--	)

--	SELECT * FROM @tbl4QAReport7Summary	

--	END
--ELSE
--	BEGIN
--	SELECT 
--		HVCasePK,
--		[PC1ID],
--		IntakeDate,
--		FormDueDate,
--		Worker,
--		currentLevel 
--	 FROM @tbl4QAReport7Detail	
--	WHERE HVCasePK NOT IN 
--		(
--		SELECT HVCaseFK FROM Intake i 
--		inner join dbo.SplitString(@programfk,',') on i.programfk = listitem
--		)

--	ORDER BY Worker, PC1ID 	


--	END
GO
