
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Service Referrals by Code
-- =============================================
CREATE PROCEDURE [dbo].[rspServiceReferralByCode] 
	-- Add the parameters for the stored procedure here
	@programfk VARCHAR(MAX) = null,
    @workerfk INT = NULL,
	@StartDt datetime,
	@EndDt DATETIME,
	@pc1id AS VARCHAR(13) = NULL,
    @doWorker AS INT = 0,
    @doPC1ID AS INT = 0
AS
if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
set @programfk = replace(@programfk,'"','')
	
--DECLARE @programfk INT = 5
--DECLARE @workerfk INT = NULL
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '06/30/2012'
--DECLARE @pc1id AS VARCHAR(13)
--DECLARE @doWorker AS INT = 0
--DECLARE @doPC1ID AS INT = 0

; WITH HVCaseInRange AS (
SELECT b.PC1ID, b.HVCaseFK
--, CASE WHEN a.IntakeDate < @StartDt THEN @StartDt ELSE a.IntakeDate END [Start_Period]
--, CASE WHEN b.DischargeDate IS NULL THEN @EndDt
--  WHEN b.DischargeDate > @EndDt THEN @EndDt ELSE b.DischargeDate END [End_Period]

, @StartDt [Start_Period]
, @EndDt  [End_Period]

FROM HVCase AS a JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
WHERE a.IntakeDate <= @EndDt AND a.IntakeDate IS NOT NULL AND
(b.DischargeDate IS NULL OR b.DischargeDate > @StartDt) 
AND b.PC1ID = ISNULL(@pc1id, b.PC1ID)
)

SELECT 
CASE WHEN @doWorker = 1 THEN 
LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) ELSE 'All Workers' END [worker], 
CASE WHEN @doPC1ID = 1 THEN PC1ID ELSE '' END [PC1ID],
ServiceReferralCategory =
		CASE b.servicereferralcategory
			WHEN 'HC' THEN 'Health Care'
			WHEN 'NUT' THEN 'Nutrition'
			WHEN 'DSS' THEN 'Public Benefits'
			WHEN 'FSS' THEN 'Family & Social Support Services'
			WHEN 'ETE' THEN 'Employment, Training & Education'
			WHEN 'CSS' THEN 'Counseling & Intensive Support Services'
			WHEN 'CON' THEN 'Concrete Services'
			WHEN 'OTH' THEN 'Other Services'
			ELSE 'No Match'
		END + ' (' + ltrim(rtrim(b.servicereferralcategory)) + ')',
b.ServiceReferralCode + '-' + ltrim(rtrim(b.ServiceReferralType)) [ServiceReferralCode],
ltrim(rtrim(b.servicereferralcategory)) [CategoryCode],
x.n
FROM
(SELECT 
CASE WHEN @doWorker = 1 THEN isnull(b.CurrentFSWFK, b.CurrentFAWFK) ELSE '' END [FSWFK], 
CASE WHEN @doPC1ID = 1 THEN b.PC1ID ELSE '' END [PC1ID], 
a.ServiceCode, count(*) [n]
FROM ServiceReferral a
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
JOIN HVCaseInRange AS b1 ON b1.HVCaseFK = a.HVCaseFK
WHERE 
--a.ProgramFK = @programfk AND 
a.ReferralDate Between @StartDt AND @EndDt
--AND a.ServiceReceived = 1
--AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
AND isnull(b.CurrentFSWFK, b.CurrentFAWFK) = ISNULL(@workerfk, isnull(b.CurrentFSWFK, b.CurrentFAWFK))

GROUP BY 
CASE WHEN @doWorker = 1 THEN isnull(b.CurrentFSWFK, b.CurrentFAWFK) ELSE '' END, 
CASE WHEN @doPC1ID = 1 THEN b.PC1ID ELSE '' END, 
a.ServiceCode) x
LEFT OUTER JOIN worker fsw
ON x.FSWFK = fsw.workerpk
--INNER JOIN workerprogram wp
--ON wp.workerfk = fsw.workerpk
INNER JOIN codeServiceReferral b
ON x.ServiceCode = b.ServiceReferralCode
ORDER BY worker, PC1ID, ServiceReferralCategory, ServiceReferralCode





GO
