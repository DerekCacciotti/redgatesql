
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 24, 2012>
-- Description:	<This QA report gets you '16. Cases with Forms to be reviewed '>
-- rspQAReport16 12, 'summary'	--- for summary page
-- rspQAReport16 12			--- for main report - location = 2
-- rspQAReport16 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport16](
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

DECLARE @Back2MonthsFromAnalysisPoint DateTime
SET @Back2MonthsFromAnalysisPoint = dateadd(m,-2,@LastDayofPreviousMonth)

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport16Detail TABLE(
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
	MultipleBirth [char](3),
	XDateAge INT,
	TCName [varchar](200),
	DaysSinceLastMedicalFormEdit INT,
	LengthInProgress INT,
	CurrentLevelDate [datetime],
	Supervisor [varchar](200)  
	)

INSERT INTO @tbl4QAReport16Detail(
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
	MultipleBirth,
	XDateAge,
	TCName,
	DaysSinceLastMedicalFormEdit,
	LengthInProgress,
	CurrentLevelDate,
	Supervisor	
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
	
	--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
	case
	   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
		   dateadd(mm,1,h.IntakeDate) 
	   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.tcdob) 
	   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.edc) 					
	end as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	h.IntakeLevel,
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth],
		case
	   when h.tcdob is not null then
		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
	   else
		   datediff(dd, h.edc, @LastDayofPreviousMonth)
	end as XDateAge,
	'' AS TCName,
	''  AS DaysSinceLastMedicalFormEdit,
	datediff(dd, h.IntakeDate,  @LastDayofPreviousMonth)  AS LengthInProgress,
	cp.CurrentLevelDate,
	LTRIM(RTRIM(sup.firstname))+' '+LTRIM(RTRIM(sup.lastname)) as Supervisor
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	left join workerprogram on workerprogram.workerfk = case CurrentFSWFK
															when CurrentFSWFK then
																CurrentFSWFK
															else
																CurrentFAWFK
														end
	left join worker sup on sup.workerpk = workerprogram.supervisorfk	

	
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			order by h.HVCasePK
	
-- rspQAReport16 12 ,'summary'

--SELECT * FROM @tbl4QAReport16Detail

;
WITH cteFormsRequiringSupervisorReview AS
(

	SELECT pc1id,codeFormName
		  ,FormDate
		  ,fro.programfk
		  ,FormReviewStartDate
		from FormReview fr
			inner join FormReviewOptions fro on fro.FormType = fr.FormType AND fro.ProgramFK = fr.ProgramFK 
			left join codeForm on codeForm.codeFormAbbreviation = fr.formtype
			left join caseprogram on caseprogram.hvcasefk = fr.hvcasefk
			left join workerprogram on workerprogram.workerfk = case CurrentFSWFK
																	when CurrentFSWFK then
																		CurrentFSWFK
																	else
																		CurrentFAWFK
																end
			left join worker on worker.workerpk = workerprogram.supervisorfk
			inner join dbo.SplitString(@programfk,',') on fr.programfk = listitem
		where 
		ReviewedBy is NULL
		and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)		
		

)



,
cteFormsToBeReviewCount as
(

SELECT 
	   HVCasePK
	  ,count(qa1.PC1ID) AS NumOfFormsToBeReviewed
  
 FROM @tbl4QAReport16Detail qa1
 INNER JOIN cteFormsRequiringSupervisorReview fr ON fr.PC1ID = qa1.PC1ID
 GROUP BY HVCasePK
 )



	SELECT 
	   qa1.HVCasePK  
	 , PC1ID
	 , NumOfFormsToBeReviewed
	 , Supervisor
	 , Worker
	 , currentLevel
	INTO #tbl4QAReport16 -- Used temp table, because insert same into a variable table name like @tbl4QAReport14, SQL Server was taking 5 secs to complete ... Khalsa
	FROM cteFormsToBeReviewCount ft
	LEFT JOIN @tbl4QAReport16Detail qa1 ON qa1.HVCasePK = ft.HVCasePK
	ORDER BY Supervisor, Worker 



-- rspQAReport16 12 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0
SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport16Detail)  

DECLARE @numOfCasesOnLevelX INT = 0
SET @numOfCasesOnLevelX = (SELECT count(HVCasePK) FROM #tbl4QAReport16)  

DROP TABLE #tbl4QAReport16

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfCasesOnLevelX is null
SET @numOfCasesOnLevelX = 0


DECLARE @tbl4QAReport16Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport16Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(12 ,'Cases with Forms to be reviewed (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfCasesOnLevelX) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfCasesOnLevelX AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport16Summary	

END
ELSE
BEGIN

SELECT 
	   PC1ID
	 , NumOfFormsToBeReviewed
	 , Supervisor
	 , Worker
	 , currentLevel

 FROM #tbl4QAReport16
 --ORDER BY NumOfFormsToBeReviewed DESC
 
 
DROP TABLE #tbl4QAReport16

--- rspQAReport16 12 ,'summary'

END
GO
