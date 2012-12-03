
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:    <Dar Chen>
-- Create date: <Jul 09, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspFSWPreIntakeTickler]
(
    @programfk    int    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)
as
	
-- Preassessment Table : CaseStatus, HVCaseFK, PADate, ProgramFK
-- CaseStatus = '01' : Engagement Efforts Continue into next month                                                
-- CaseStatus = '02' : Assessment Completed
-- CaseStatus = '03' : Engagement Efforts Terminated, Kempe not Completed

--DECLARE @programfk INT = 6
--DECLARE @workerfk INT = NULL
--DECLARE @supervisorfk INT = NULL
--DECLARE @rdate DATETIME = '01/01/2012'

; WITH lastpreintake AS 
(
(SELECT HVCaseFK, max(PIDate) [LastPreIntakeDate] FROM Preintake WHERE ProgramFK = @programfk
GROUP BY HVCaseFK) 
)

SELECT c.PC1ID [pc1ID]
, rtrim(b.PCFirstName)+ ' ' + rtrim(b.PCLastName) [Name] 
, rtrim(b.PCStreet) + CASE WHEN b.PCApt IS NULL THEN '' ELSE rtrim(b.PCApt) END [Street]
, rtrim(b.PCCity) + CASE WHEN b.PCCity IS NOT NULL OR len(b.PCCity) > 0 THEN ', NY' ELSE 'NY' END 
+ ' ' + rtrim(b.PCZip) [City]
, b.PCPhone [Phone]
, datediff(day, d.FSWAssignDate, @rdate) [DaysSinceFSW]
, convert(VARCHAR(12), DATEADD(day,30.44*3,CASE WHEN a.TCDOB IS NOT NULL THEN a.TCDOB ELSE a.EDC END)
, 101) [EnrollmentAgeOutDate]
, substring(convert(VARCHAR(30),  e.LastPreIntakeDate, 106),4, 20) [LastIntakeForm]
, ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) fswname
, ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) as supervisor
, d.PAFSWFK

, e.LastPreIntakeDate
, convert(VARCHAR(12), d.FSWAssignDate, 101) [FSWDateAssigned]
--, *
FROM HVCase  AS a 
JOIN PC AS b ON a.PC1FK = b.PCPK
JOIN CaseProgram AS c ON c.HVCaseFK = a.HVCasePK
JOIN Preassessment AS d ON a.HVCasePK = d.HVCaseFK AND d.CaseStatus = '02'
JOIN lastpreintake AS e ON e.HVCaseFK = a.HVCasePK

inner join worker fsw on fsw.workerpk = c.currentfswfk
inner join workerprogram on workerfk = fsw.workerpk
inner join worker supervisor on supervisorfk = supervisor.workerpk

WHERE c.DischargeDate IS NULL 
AND c.ProgramFK = @programfk
AND c.CurrentLevelFK IN (7, 8)
--and caseprogress >= 11
and c.currentFSWFK = isnull(@workerfk, c.currentFSWFK)
and supervisorfk = isnull(@supervisorfk, supervisorfk)

--where followup.hvcasefk is null
--and CaseProgress >= 11
--and CurrentFSWFK = isnull(@workerfk,CurrentFSWFK)
--and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
--and (DischargeDate is null)
--and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
--and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
GO
