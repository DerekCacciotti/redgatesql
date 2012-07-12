SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 11, 2012>
-- Description: 
-- =============================================
CREATE procedure [dbo].[rspKempePC1Issues]
(
    @programfk    int    = null,
    @StartDt      DATETIME = null,
    @EndDt        DATETIME = null
)
as


--DECLARE @StartDt DATE = '01/01/2011'
--DECLARE @EndDt DATE = '12/31/2011'
--DECLARE @programfk INT = 17

; WITH inserviceReferral AS 
(
SELECT a.HVCasePK
, sum(CASE WHEN c.servicecode IN('49', '50') AND c.FamilyCode = '01' THEN 1 ELSE 0 END) MentalHealthServices
, sum(CASE WHEN c.servicecode = '51' AND c.FamilyCode = '01' THEN 1 ELSE 0 END) DomesticViolenceServices                  
, sum(CASE WHEN c.servicecode = '52'  AND c.FamilyCode = '01' THEN 1 ELSE 0 END) SubstanceAbuseServices         

FROM HVCase AS a 
JOIN ServiceReferral AS c ON c.HVCaseFK = a.HVCasePK
WHERE a.IntakeDate BETWEEN @StartDt AND @EndDt
AND c.ReferralDate - a.IntakeDate < 183 
GROUP BY a.HVCasePK
)

SELECT d.PC1ID
, convert(VARCHAR(12), a.KempeDate, 101) KempDate
, e.LevelName
, CASE WHEN (b.SubstanceAbuse = 1 OR b.AlcoholAbuse = 1)THEN 'Yes' ELSE '' END +
  CASE WHEN c.SubstanceAbuseServices > 0 AND (b.SubstanceAbuse = 1 OR b.AlcoholAbuse = 1) THEN ' *' ELSE '' END SubstanceAbuseServices
, CASE WHEN (b.MentalIllness = 1 OR b.Depression = 1) THEN 'Yes' ELSE '' END + 
  CASE WHEN c.MentalHealthServices > 0 AND (b.MentalIllness = 1 OR b.Depression = 1) THEN ' *' ELSE '' END MentalHealthServices
, CASE WHEN b.DomesticViolence = 1 THEN 'Yes' ELSE '' END + 
  CASE WHEN c.DomesticViolenceServices > 0 AND b.DomesticViolence = 1 THEN ' *' ELSE '' END DomesticViolenceServices
, ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) fswname
, ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor

, b.SubstanceAbuse, b.MentalIllness, b.DomesticViolence
, b.AlcoholAbuse, b.Depression, b.OtherIssue

FROM HVCase AS a 
JOIN PC1Issues AS b ON a.HVCasePK = b.HVCaseFK
JOIN CaseProgram AS d ON d.HVCaseFK = a.HVCasePK
JOIN codeLevel AS e ON d.CurrentLevelFK = e.codeLevelPK
LEFT OUTER JOIN inserviceReferral AS c ON c.HVCasePK = a.HVCasePK

inner join worker fsw on fsw.workerpk = d.currentfswfk
inner join workerprogram on workerfk = fsw.workerpk
inner join worker supervisor on supervisorfk = supervisor.workerpk

WHERE a.IntakeDate BETWEEN @StartDt AND @EndDt AND d.ProgramFK = @programfk
AND (d.DischargeDate IS NULL OR d.DischargeDate <= @EndDt)
ORDER BY supervisor, d.PC1ID





GO
