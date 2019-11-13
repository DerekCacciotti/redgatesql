SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[rspGetSinglePreassessmentForCaseHomePage] @papk INT as
	
SELECT TOP 1 cp.PC1ID, hvs.ScreenDate, pa.PADate, tcid.TCDOB, w.FirstName, w.LastName, pa.PAParentLetter,
pa.PACall2Parent,pa.PACallFromParent,pa.PAVisitAttempt,pa.PAVisitMade,pa.PAOtherHVProgram, pa.PAParent2Office,
pa.PAProgramMaterial,pa.PAGift,pa.PACaseReview, pa.PAOtherActivity, pa.CaseStatus, pa.KempeDate, pa.PAFSWFK,
w.FirstName AS 'Current Worker First Name', w.LastName AS 'Current Worker Last Name',
pa.FSWAssignDate
FROM preassessment pa 
INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = pa.HVCaseFK 
inner JOIN dbo.HVScreen hvs ON hvs.HVCaseFK = pa.HVCaseFK
left JOIN dbo.TCID tcid ON tcid.HVCaseFK = pa.HVCaseFK 
INNER JOIN dbo.Worker w ON w.WorkerPK = pa.PAFAWFK
INNER JOIN dbo.Worker currentworker ON currentworker.WorkerPK = cp.CurrentFSWFK

WHERE pa.PreassessmentPK = @papk
ORDER BY padate DESC
GO
