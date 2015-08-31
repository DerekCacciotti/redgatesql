
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dhruv Patel
-- Create date: 2015-07-28
-- Description:	Adds an additional report to the QA report for Kempes
--				missing attachments
-- =============================================
CREATE procedure [dbo].[rspQAReport18](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
AS
declare @CutOffDate date
set @CutOffDate = '2015-05-01'


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

DECLARE @tbl4QAReportCohort TABLE(
	HVCaseFK int,
	PC1ID char(13),
	KempeDate datetime,
	CurrentWorkerName varchar(200),
	CurrentLevel varchar(20)
)

insert into @tbl4QAReportCohort
        ( HVCaseFK ,
		  PC1ID ,
          KempeDate ,
          CurrentWorkerName ,
          CurrentLevel
        )
     
select cp.HVCaseFK
		, PC1ID
		, KempeDate
		, ltrim(rtrim(w.firstname))+' '+ltrim(rtrim(w.lastname)) as CurrentWorkerName
		, CurrentLevel = cl.LevelName
from dbo.Kempe k 
inner join dbo.CaseProgram cp on cp.HVCaseFK = k.HVCaseFK
left join codeLevel cl on cp.CurrentLevelFK = cl.codeLevelPK
inner join Worker w ON w.WorkerPK = k.FAWFK
where k.ProgramFK = @ProgramFK 
		and KempeDate >= @CutOffDate
		and (cp.DischargeDate IS NULL  --- case not closed
				or cp.DischargeDate > @LastDayofPreviousMonth)
				
if @ReportType = 'summary'
	begin
		declare @cohortCount int=0
		set @cohortCount= (select count(PC1ID) from @tbl4QAReportCohort)
		
		declare @missingAttachCount int=0
		set @missingAttachCount = (select count(PC1ID) from @tbl4QAReportCohort qarc
									 left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'KE'
									 where a.AttachmentPK is null)
		
		DECLARE @tbl4QAReportMissingAttachSummary TABLE(
			[SummaryId] INT,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)
		insert into @tbl4QAReportMissingAttachSummary
		        ( SummaryId ,
		          SummaryText ,
		          SummaryTotal
		        )
		values  ( 18 , -- SummaryId - int
		          'Number of Kempe forms without attachment (N=' + CONVERT(varchar,@cohortCount) + ')', -- SummaryText - varchar(200)
		          CONVERT(varchar,@missingAttachCount) + ' (' + 
		          convert(varchar,round(coalesce(cast(@missingAttachCount as float) * 100 / nullif(@cohortCount,0),0),0)) + '%)' -- SummaryTotal - varchar(100)
		        )
		
		select * from @tbl4QAReportMissingAttachSummary
		
	end

else
	begin
		select PC1ID ,
               convert(varchar(10), KempeDate, 101) as [Kempe Date] ,
               CurrentWorkerName as [FAW Name],
               CurrentLevel
		from @tbl4QAReportCohort qarc
	    left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'KE'
		where a.AttachmentPK is null
	end
	
	
	

	
GO
