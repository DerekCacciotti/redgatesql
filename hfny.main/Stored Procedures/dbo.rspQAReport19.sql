SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dhruv Patel
-- Create date: 2015-08-04
-- Description:	Adds an additional report to the QA report for Home 
--				Visit Logs missing attachments
-- =============================================
CREATE procedure [dbo].[rspQAReport19](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
as
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

DECLARE @tbl4QAReportMissingAttachHV TABLE(
	[PC1ID] char(13),
	VisitStartTime datetime,
	CurrentLevel varchar(20)
)

insert into @tbl4QAReportMissingAttachHV
        ( PC1ID ,
          VisitStartTime ,
          CurrentLevel
        )
select PC1ID
		, VisitStartTime
		, CurrentLevel = cl.LevelName
		from dbo.HVLog hv 
		left outer join dbo.Attachment a on hv.HVCaseFK = a.HVCaseFK and a.FormType = 'VL'
		inner join dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK
		left join codeLevel cl on cp.CurrentLevelFK = cl.codeLevelPK
		
		where hv.ProgramFK = @ProgramFK 
				and AttachmentPK is null
				and hv.VisitType <> '0001'
				and VisitStartTime >= @CutOffDate
				and (cp.DischargeDate IS NULL  --- case not closed
						or cp.DischargeDate > @LastDayofPreviousMonth)
						
if @ReportType = 'summary'
	begin
		declare @count int=0
		set @count= (select count(PC1ID) from @tbl4QAReportMissingAttachHV)		
		
		DECLARE @tbl4QAReportMissingAttachHVSummary TABLE(
			[SummaryId] INT,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)
		insert into @tbl4QAReportMissingAttachHVSummary
		        ( SummaryId ,
		          SummaryText ,
		          SummaryTotal
		        )
		values  ( 14 , -- SummaryId - int
		          'Number of HV Log forms without attachment' , -- SummaryText - varchar(200)
		          CONVERT(varchar,@count)  -- SummaryTotal - varchar(100)
		        )
		
		select * from @tbl4QAReportMissingAttachHVSummary
		
	end

else
	begin
		select PC1ID ,
               VisitStartTime , 
               CurrentLevel
		from @tbl4QAReportMissingAttachHV
	end
	
	
	

GO
