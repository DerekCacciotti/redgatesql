SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa/Dar Chen>
-- Create date: <Apr/28/2015>
-- Description:	<This QA report gets you 'Kempe assessment completed but Not data entered '>
-- rspQAReport17 2, 'summary'	--- for summary page
-- rspQAReport17 2				--- for main report - location = 2
-- rspQAReport17 null			--- for main report for all locations
-- =============================================


CREATE procedure [dbo].[rspQAReport17](
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

-- give them 30 days for grace period
Set @LastDayofPreviousMonth = DATEADD(day, -15, @LastDayofPreviousMonth) -- analysis point - 30 days

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport17Detail TABLE(
	[PC1ID] [char](13),
	KempeDate [datetime],
	PADate [datetime],
	CurrentFAW [varchar](200)
)

INSERT INTO @tbl4QAReport17Detail(
	PC1ID,
	KempeDate,
	PADate,
	CurrentFAW
)
select DISTINCT
	cp.PC1ID,
	h.KempeDate,
	p.PADate,
	LTRIM(RTRIM(faw.firstname))+' '+LTRIM(RTRIM(faw.lastname)) as CurrentFAW			
	
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	
	LEFT OUTER JOIN dbo.Kempe AS k ON k.HVCaseFK = cp.HVCaseFK
	
	INNER JOIN Preassessment AS p ON p.HVCaseFK = cp.HVCaseFK AND p.KempeDate IS NOT NULL
	INNER JOIN Worker faw ON faw.WorkerPK = cp.CurrentFAWFK		
	
	where
		k.HVCaseFK IS NULL  -- no kempe form
		AND h.KempeDate <= @LastDayofPreviousMonth
		AND cp.DischargeDate IS NULL  --- case not closed
		
--- rspQAReport17 2 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0
SET @numOfALLScreens = (SELECT count(PC1ID) FROM @tbl4QAReport17Detail)


DECLARE @numOfScreensNoPAThisMonth INT = 0
SET @numOfScreensNoPAThisMonth = @numOfALLScreens


-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfScreensNoPAThisMonth is null
SET @numOfScreensNoPAThisMonth = 0


DECLARE @tbl4QAReport17Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport17Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(17 ,'Kempe assessment completed but not data entered within 15 days (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')'
,CONVERT(VARCHAR,@numOfScreensNoPAThisMonth) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfScreensNoPAThisMonth AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport17Summary	

END
ELSE
BEGIN


SELECT PC1ID,
		case
		   when KempeDate is not null then
			   convert(varchar(10),KempeDate,101)
		   else
			   ''
		end as KempeDate,

		case
		   when PADate is not null then
			   convert(varchar(10),PADate,101)
		   else
			   ''
		end as PreassessmentFormDate,

		
	 CurrentFAW
	
 FROM @tbl4QAReport17Detail	

ORDER BY CurrentFAW,PC1ID 		


END
GO
