
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'Target Child IDs for Active Cases '>
-- rspQAReport5 1, 'summary'	--- for summary page
-- rspQAReport5 31			--- for main report - location = 2
-- rspQAReport5 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport5](
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
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

--Set @LastDayofPreviousMonth = '05/31/2012'

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport5Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	IntakeLevel [char](1),
	TCNumber INT,
	MultipleBirth [char](3) 
)

INSERT INTO @tbl4QAReport5Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	IntakeLevel,
	TCNumber,
	MultipleBirth
)
select 
	 h.HVCasePK, 
	cp.PC1ID,
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,
	CASE 
	WHEN (h.IntakeLevel = '1') 	
	THEN 
		
		CASE 
		WHEN (h.tcdob is NULL) THEN dateadd(mm,1,h.edc) ELSE dateadd(mm,1,h.tcdob) END 
		
	ELSE
		 dateadd(mm,1,h.IntakeDate) 
	END as FormDueDate,
	--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
	----case
	----   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
	----	   dateadd(mm,1,h.IntakeDate) 
	----   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
	----				dateadd(mm,1,h.tcdob) 
	----   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
	----				dateadd(mm,1,h.edc) 					
	----end as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	h.IntakeLevel,
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth]   			 			
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			AND (( (@LastDayofPreviousMonth >= dateadd(M, 1, h.edc)) AND (h.tcdob IS NULL) ) OR ( (@LastDayofPreviousMonth >= dateadd(M, 1, h.tcdob)) AND (h.edc IS NULL) ) )  
			order by cp.OldID -- h.IntakeDate 

			-- to get accurate count of case
			UPDATE @tbl4QAReport5Detail
			SET TCNumber = 1
			WHERE TCNumber = 0
	
			-- if you execute the following statement, you may not see all records i.e. two rows for twins etc, there is only one row for twin etc
			-- so number of records in the resultset will be less
			--SELECT * FROM @tbl4QAReport5Detail

	
--- rspQAReport5 31 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0

-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
SET @numOfALLScreens = (SELECT sum(TCNumber) FROM @tbl4QAReport5Detail)  

DECLARE @numOfActiveIntakeCases INT = 0
SET @numOfActiveIntakeCases = (
	SELECT count(HVCasePK) FROM @tbl4QAReport5Detail
	WHERE HVCasePK NOT IN 
		(
		SELECT HVCaseFK FROM TCID T 
		inner join dbo.SplitString(@programfk,',') on T.programfk = listitem
		)
)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0

DECLARE @tbl4QAReport5Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport5Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(5 ,'Target Child IDs for Active Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport5Summary	

END
ELSE
BEGIN
SELECT 
	[PC1ID],
	convert(varchar(10),TCDOB,101) as TCDOB,
	convert(varchar(10),IntakeDate,101) as IntakeDate,
	convert(varchar(10),FormDueDate,101) as FormDueDate,
	Worker,
	MultipleBirth,
	currentLevel 
 FROM @tbl4QAReport5Detail	
WHERE HVCasePK NOT IN 
	(
			SELECT HVCaseFK FROM @tbl4QAReport5Detail qa
			inner join TCID T  on T.HVCaseFK = qa.HVCasePK 		
	)

ORDER BY Worker, PC1ID 	


END
GO
