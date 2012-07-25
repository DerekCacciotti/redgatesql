
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
	@programfk INT = NULL, 
    @supervisorfk INT = NULL, 
    @workerfk INT = NULL,
	@StartDt datetime,
	@EndDt datetime
AS


--DECLARE @programfk INT = 6 
--DECLARE @supervisorfk INT = NULL 
--DECLARE @workerfk INT = NULL
--DECLARE @StartDt DATETIME = '01/01/2012'
--DECLARE @EndDt DATETIME = '03/31/2012'

; WITH HVCaseInRange AS (
SELECT b.HVCaseFK
, CASE WHEN a.IntakeDate < @StartDt THEN @StartDt ELSE a.IntakeDate END [Start_Period]
, CASE WHEN b.DischargeDate IS NULL OR b.DischargeDate > @EndDt THEN @EndDt ELSE b.DischargeDate END [End_Period]
FROM HVCase AS a JOIN CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
WHERE a.IntakeDate <= @EndDt AND a.IntakeDate IS NOT NULL AND
(b.DischargeDate IS NULL OR b.DischargeDate > @EndDt)
)

SELECT 
LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor,
LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) worker,
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
x.n
FROM
(SELECT a.FSWFK, a.ServiceCode, count(*) [n]
FROM ServiceReferral a
JOIN HVCaseInRange AS b ON b.HVCaseFK = a.HVCaseFK
WHERE a.ProgramFK = @programfk 
AND a.ReferralDate Between @StartDt AND @EndDt 
AND a.ServiceReceived = 1
AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
GROUP BY a.FSWFK, a.ServiceCode) x
INNER JOIN worker fsw
ON x.FSWFK = fsw.workerpk
INNER JOIN workerprogram wp
ON wp.workerfk = fsw.workerpk
INNER JOIN worker supervisor
ON wp.supervisorfk = supervisor.workerpk
INNER JOIN codeServiceReferral b
ON x.ServiceCode = b.ServiceReferralCode

WHERE wp.supervisorfk = ISNULL(@supervisorfk, wp.supervisorfk)
ORDER BY supervisor, worker, ServiceReferralCategory, ServiceReferralCode





GO
