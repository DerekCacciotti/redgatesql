SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[rspHomeVisitsServedinTimePeriod] @BeginOfMonth date
											, @EndOfMonth date
											, @ProgramFK varchar(200)
as

if	@ProgramFK is null begin
	select	@ProgramFK = substring((
								select		','+ltrim(rtrim(str(HVProgramPK)))
								from		HVProgram
								for xml path('')
								), 2, 8000
								) ;
end ;
set @ProgramFK = replace(@ProgramFK, '"', '') ;



select			rtrim(c.LastName)+', '+rtrim(c.FirstName) as WorkerName
			, b.PC1ID
			, convert(varchar(10), a.VisitStartTime, 101) as StartDate
			, format(cast(a.VisitStartTime as datetime), 'hh:mm tt') as StartTime
			--, CASE WHEN SUBSTRING(a.VisitType,1,1) = '1' THEN 'In primary participant home ' ELSE '' END + 
			-- CASE WHEN SUBSTRING(a.VisitType,1,2) = '11' THEN '/ ' ELSE '' END + 
			-- CASE WHEN SUBSTRING(a.VisitType,2,1) = '1' THEN 'In father figure home ' ELSE '' END + 
			-- CASE WHEN SUBSTRING(a.VisitType,3,1) = '1' THEN 'Outside of PC1 or father figure home ' ELSE '' END + 
			-- CASE WHEN SUBSTRING(a.VisitType,4,1) = '1' THEN 'Attempted - Family not home or unable to meet after visit to home' ELSE '' END 
			-- AS TypeOfVisit
			-- CASE WHEN e.AttachmentPK IS NOT NULL THEN 'Yes' ELSE 'No' END NarrativeAttached
			, case when d.ReviewedBy is not null then 'Yes' else 'No' end Reviewed
			--, d.ReviewedBy
			, case when FormComplete = 1 then 'Y' else 'N' end [Form Complete]
			, PCCity
			, a.VisitLengthHour
			, a.VisitLengthMinute
--, convert(char(5), a.VisitStartTime, 108) [time]
--, a.VisitType, a.VisitStartTime, a.FSWFK
from			HVLog as a
join			CaseProgram as b on a.HVCaseFK = b.HVCaseFK
join			Worker as c on c.WorkerPK = a.FSWFK
inner join		HVCase hc on hc.HVCasePK = a.HVCaseFK
inner join		PC on PC.PCPK = hc.PC1FK
inner join		dbo.SplitString(@ProgramFK, ',') on a.ProgramFK = ListItem

left outer join FormReview as d on a.HVLogPK = d.FormFK and a.ProgramFK = d.ProgramFK
								and d.FormType = 'VL'
left outer join Attachment as e on a.HVLogPK = e.FormFK and a.ProgramFK = e.ProgramFK
								and e.FormType = 'VL'
where --a.ProgramFK = @ProgramFK
				a.VisitStartTime between @BeginOfMonth and @EndOfMonth
order by		c.LastName
			, c.FirstName
			, PC1ID
			, a.VisitStartTime ;


GO
