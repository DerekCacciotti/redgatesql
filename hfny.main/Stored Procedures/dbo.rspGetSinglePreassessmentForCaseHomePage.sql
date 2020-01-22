SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[rspGetSinglePreassessmentForCaseHomePage] @papk INT AS
SELECT TOP 1 cp.PC1ID, hvs.ScreenDate, pa.PADate, pa.PAParentLetter
				, isnull(hc.TCDOB, hc.EDC) as TCDOB
				, '5. ' + case when hc.TCDOB is null then 'EDC:' else 'TC DOB:' end as DOBLabel,
--tcid.TCDOB, w.FirstName, w.LastName, pa.PAParentLetter,
pa.PACall2Parent,pa.PACallFromParent,pa.PAVisitAttempt,pa.PAVisitMade,pa.PAOtherHVProgram, pa.PAParent2Office,
pa.PAProgramMaterial,pa.PAGift,pa.PACaseReview, pa.PAOtherActivity, pa.CaseStatus, pa.KempeDate, pa.PAFSWFK,
w.FirstName AS 'Current Worker First Name', w.LastName AS 'Current Worker Last Name',
pa.FSWAssignDate, cp.DischargeDate, cp.DischargeReason, cd.DischargeReason AS DischareReasonText
FROM preassessment pa 
INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = pa.HVCaseFK 
LEFT JOIN  HVCase hc ON hc.HVCasePK = cp.HVCaseFK
inner JOIN dbo.HVScreen hvs ON hvs.HVCaseFK = pa.HVCaseFK
left JOIN dbo.TCID tcid ON tcid.HVCaseFK = pa.HVCaseFK 
INNER  JOIN dbo.Worker w ON w.WorkerPK = pa.PAFAWFK
left JOIN dbo.Worker currentworker ON currentworker.WorkerPK = cp.CurrentFSWFK
LEFT JOIN codeDischarge cd ON cd.DischargeCode = cp.DischargeReason
WHERE pa.PreassessmentPK = @papk
ORDER BY padate DESC
GO
