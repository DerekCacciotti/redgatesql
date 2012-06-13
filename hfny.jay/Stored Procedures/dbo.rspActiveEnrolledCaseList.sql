SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/11/2012
-- Description:	Active Enrolled Case List
-- =============================================
CREATE PROCEDURE [dbo].[rspActiveEnrolledCaseList] 
	-- Add the parameters for the stored procedure here
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS


--DECLARE @StartDate DATE = '01/01/2011'
--DECLARE @EndDate DATE = '05/31/2011'
--DECLARE @ProgramPK INT = 17

SELECT rtrim(PC.PCLastName) + cast(PC.PCPK AS VARCHAR(10)) [key01]
, rtrim(PC.PCLastName) + ', ' + rtrim(PC.PCFirstName) [Name]
, convert(VARCHAR(12), PC.PCDOB, 101) [DOB]
, PC.SSNo [SSNo]
, convert(VARCHAR(12), Kempe.KempeDate, 101) [KemptDate]
, convert(VARCHAR(12), HVScreen.ScreenDate, 101) [ScreenDate]
, rtrim(Worker.LastName) + ', ' + rtrim(Worker.FirstName) [FSW]
, convert(VARCHAR(12), Intake.IntakeDate, 101) [IntakeDate]
, CAST(DATEDIFF(YEAR, PC.PCDOB, Intake.IntakeDate) AS VARCHAR(10)) + ' y' [AgeAtIntake]
, CASE WHEN a.DischargeDate IS NULL THEN '' ELSE convert(VARCHAR(12), a.DischargeDate, 101) END [CloseDate]
, CASE WHEN a.DischargeDate IS NULL THEN 'Case Open' ELSE rtrim(codeDischarge.DischargeReason) END [CloseReason]
, CAST(DATEDIFF(month, Intake.IntakeDate, @EndDt) AS VARCHAR(10)) + ' m' [LengthInProgram]
, CASE WHEN ca.TANFServices = 1 THEN 'Yes' ELSE 'No' END [TANF]
, CASE WHEN ca.FormType = 'IN' THEN 'Intake' ELSE (
SELECT TOP 1 codeApp.AppCodeText FROM codeApp WHERE ca.FormInterval = codeApp.AppCode AND 
codeApp.AppCodeUsedWhere LIKE '%FU%' and codeApp.AppCodeGroup = 'TCAge' 
) END [TANFServiceAt]
,convert(VARCHAR(12), ca.FormDate, 101) [Eligible]
,(SELECT count(*) FROM HVLog WHERE VisitType <> '0001'AND VisitStartTime <= @EndDt 
AND VisitStartTime >= b.IntakeDate AND HVCaseFK = b.HVCasePK AND ProgramFK = @programfk) [HomeVisits]
-- folling fields are used for validating (to be removed)
,(
SELECT TOP 1 ca.CommonAttributesPK FROM CommonAttributes ca 
where ca.HVCaseFK = b.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
ORDER BY ca.FormDate DESC
) [CommonAttributesPKID]
,ca.FormDate, ca.TANFServices, ca.FormType, ca.FormInterval
,rtrim(T.TCLastName) + ', ' + rtrim(T.TCFirstName) [tcName]
,convert(VARCHAR(12), T.TCDOB, 101) [tcDOB]

FROM CaseProgram AS a
JOIN HVCase AS b 
ON a.HVCaseFK = b.HVCasePK

-- pc1 name, dob, and SS# = b.PC1FK <-> PC.PCPK -> PC.PCLastName + PC.PCFirstName, PC.PCDOB, PC.SSNo
JOIN PC ON PC.PCPK = b.PC1FK
-- screen date = a.HVCaseFK <-> Kempe.HVCaseFK -> Kempe.KempeDate
JOIN Kempe ON Kempe.HVCaseFK = b.HVCasePK
--
-- kempe date = a.HVCaseFK <-> HVScreen.HVCaseFK -> HVScreen.ScreenDate
JOIN HVScreen ON HVScreen.HVCaseFK = b.HVCasePK
--
-- FSW & site = a.CurrentFSWFK <-> Worker.WorkerPK -> Worker.LastName + Worker.FirstName ?? site ??
LEFT OUTER JOIN Worker ON Worker.WorkerPK = a.CurrentFSWFK
--
-- intake date & age at intake = a.HVCaseFK <-> Intake.HVCaseFK -> Intake.IntakeDate -> (PCDOB - IntakeDate)
JOIN Intake ON Intake.HVCaseFK = b.HVCasePK
--
-- closed date & close reason = a.DischargeDate, a.DischargeReason <-> codeDischarge.DischargeCode 
--                              -> codeDischarge.DischargeReason
LEFT OUTER JOIN codeDischarge ON a.DischargeReason = codeDischarge.DischargeCode
--
-- length in program = @EndDt - IntakeDate

-- TANFservices, &  eligible = CA (CommonAttributes) : a.HVCaseFK <-> CA.HVCaseFK and CA.FormType IN ('FU', 'IN')
-- , CA.FormDate <= @EndDt and CA.TANFServices = 1 
-- if CA.FormType = 'IN' then FormInterval = 'In Take' else CA.FormInterval <-> codeApp.AppCode and
-- codeApp.AppCodeUsedWhere LIKE '%FU%' and AppCodeGroup = 'TCAge' -> codeApp.AppCodeText
-- CA.FormDate = Eligible date
-- CA.TANFServices = TANF
-- ON ca.HVCaseFK = b.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
LEFT OUTER JOIN CommonAttributes ca 
ON ca.CommonAttributesPK = (SELECT TOP 1 CommonAttributesPK FROM CommonAttributes 
where HVCaseFK = b.HVCasePK AND FormDate <= @EndDt AND FormType IN ('FU', 'IN')
ORDER BY FormDate DESC)

-- # of actual home visits since intake = a.HVCaseFK <-> HVLog.HVCaseFK, ProgramFK, 
-- VisitType <> '0001', VisitStartTime < @EndDt and VisitStartTime >= b.IntakeDate

LEFT OUTER JOIN TCID T ON T.HVCaseFK = b.HVCasePK

WHERE b.IntakeDate < @EndDt AND (a.DischargeDate IS NULL OR a.DischargeDate > @StartDt)
AND a.ProgramFK = @programfk
ORDER BY [key01]


GO
