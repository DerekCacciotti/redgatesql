SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[rspHomeVisitsServedinTimePeriod] @BeginOfMonth  DATE, @EndOfMonth  DATE, @ProgramFK VARCHAR(200) AS 

if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @ProgramFK = replace(@ProgramFK,'"','')



SELECT 
RTRIM(c.LastName) + ', ' + RTRIM(c.FirstName) AS WorkerName
, b.PC1ID
, CONVERT (VARCHAR(10), a.VisitStartTime, 101) AS StartDate
, FORMAT(CAST(a.VisitStartTime AS DATETIME),'hh:mm tt') AS StartTime
--, CASE WHEN SUBSTRING(a.VisitType,1,1) = '1' THEN 'In primary participant home ' ELSE '' END + 
-- CASE WHEN SUBSTRING(a.VisitType,1,2) = '11' THEN '/ ' ELSE '' END + 
-- CASE WHEN SUBSTRING(a.VisitType,2,1) = '1' THEN 'In father figure home ' ELSE '' END + 
-- CASE WHEN SUBSTRING(a.VisitType,3,1) = '1' THEN 'Outside of PC1 or father figure home ' ELSE '' END + 
-- CASE WHEN SUBSTRING(a.VisitType,4,1) = '1' THEN 'Attempted - Family not home or unable to meet after visit to home' ELSE '' END 
-- AS TypeOfVisit
-- CASE WHEN e.AttachmentPK IS NOT NULL THEN 'Yes' ELSE 'No' END NarrativeAttached
, CASE WHEN d.ReviewedBy IS NOT NULL THEN 'Yes' ELSE 'No' END Reviewed
--, d.ReviewedBy
, case when FormComplete=1 then 'Y' else 'N' end [Form Complete]
, PCCity
--, convert(char(5), a.VisitStartTime, 108) [time]
--, a.VisitType, a.VisitStartTime, a.FSWFK
FROM HVLog AS a
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
JOIN Worker AS c ON c.WorkerPK = a.FSWFK
inner join HVCase hc on hc.HVCasePK = a.HVCaseFK
inner join pc on PC.PCPK = hc.PC1FK
LEFT OUTER JOIN FormReview AS d ON a.HVLogPK = d.FormFK AND a.ProgramFK = d.ProgramFK AND d.FormType = 'VL'
LEFT OUTER JOIN Attachment AS e ON a.HVLogPK = e.FormFK AND a.ProgramFK = e.ProgramFK AND e.FormType = 'VL'
WHERE --a.ProgramFK = @ProgramFK
 a.VisitStartTime BETWEEN @BeginOfMonth AND @EndOfMonth
order BY c.LastName,c.FirstName,PC1id, a.VisitStartTime


GO
