
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- =============================================
CREATE PROCEDURE [dbo].[rspProgramDemographics] 
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @programfk INT = 6 
--DECLARE @StartDt DATETIME = '06/01/2012'
--DECLARE @EndDt DATETIME = '06/30/2012'

; WITH MotherWithOtherChildren as (
SELECT count(DISTINCT a.HVCasePK) [8MotherWithOtherChild]
FROM dbo.HVCase AS a
JOIN dbo.CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN PC AS c ON c.PCPK = a.PC1FK
JOIN Intake AS d ON d.HVCaseFK = a.HVCasePK
JOIN OtherChild AS oc ON oc.FormFK = d.IntakePK AND oc.FormType = 'IN' AND oc.Relation2PC1 = '01'
WHERE (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt) AND a.IntakeDate <= @EndDt
AND b.ProgramFK = @programfk
)
, TCMedicaid_5 AS (
SELECT
 a.HVCasePK
, tc.MultipleBirth [MultipleBirth]
, tc.NumberofChildren [NumberofChildren]
, caTC.TCReceivingMedicaid [TCMedicaid]
, caTC.CommonAttributesPK [TCIDStatus]
FROM dbo.HVCase AS a
JOIN dbo.CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN PC AS c ON c.PCPK = a.PC1FK
JOIN Intake AS d ON d.HVCaseFK = a.HVCasePK
JOIN TCID AS tc ON tc.HVCaseFK = a.HVCasePK AND tc.TCDOB <= @EndDt
JOIN CommonAttributes AS caTC ON caTC.FormFK = tc.TCIDPK AND caTC.FormType = 'TC'
WHERE (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt) AND a.IntakeDate <= @EndDt
AND b.ProgramFK = @programfk
)

, TCMedicaid AS (
SELECT 
  sum(CASE WHEN TCMedicaid = 1 THEN 1 ELSE 0 END) [5TCMedicaid]
, count(*) [5TC]
FROM TCMedicaid_5
)

, x AS (
select DISTINCT a.HVCasePK
, c.Race [Race]
, cast(str(datediff(dd, c.PCDOB,  a.IntakeDate) / 365.25, 6) AS INT) [Age]
, cast(datediff(dd, a.IntakeDate, 
  CASE WHEN b.DischargeDate IS NOT NULL AND b.DischargeDate <= @EndDt THEN b.DischargeDate ELSE @EndDt END) /365.25 AS INT) [yrEnrolled]
, ca1.HighestGrade [Edu]
, ca1.IsCurrentlyEmployed [pc1Employed]
, ca2.IsCurrentlyEmployed [pc2Employed]

, caOBP.IsCurrentlyEmployed [obpEmployed]
, caOBP.EducationalEnrollment [obpTrainingProgram]
, pc.PCPK [OBPMaleInHoushold]

, ca1.EducationalEnrollment [pc1TrainingProgram]
, ca2.EducationalEnrollment [pc2TrainingProgram]
, ca.PC1ReceivingMedicaid [pc1Medicaid]
, ca.PBFoodStamps [FoodStamps]
, ca.PBTANF [TANF]
, ca1.MaritalStatus [pc1MaritalStatus]
, caOBP.CommonAttributesPK [OBPInHoushold]
, ca2.CommonAttributesPK [PC2InHoushold]
, CASE WHEN b.DischargeDate IS NOT NULL AND b.DischargeDate <= @EndDt THEN b.DischargeDate ELSE @EndDt END [lastdate]

, CASE WHEN isnull(t.TCDOB, a.EDC) > a.IntakeDate THEN 1 ELSE 0 END [PrenatalStatus]
, CASE WHEN ca1.PrimaryLanguage IN ('02', '03') THEN 1 ELSE 0 END [NeedInterpreter]

FROM dbo.HVCase AS a
JOIN dbo.CaseProgram AS b ON a.HVCasePK = b.HVCaseFK
JOIN PC AS c ON c.PCPK = a.PC1FK
JOIN Intake AS d ON d.HVCaseFK = a.HVCasePK
LEFT OUTER JOIN CommonAttributes AS	ca ON ca.FormFK = d.IntakePK AND ca.FormType = 'IN'
LEFT OUTER JOIN CommonAttributes AS	ca1 ON ca1.FormFK = d.IntakePK AND ca1.FormType = 'IN-PC1'
LEFT OUTER JOIN CommonAttributes AS	ca2 ON ca2.FormFK = d.IntakePK AND ca2.FormType = 'IN-PC2'
LEFT OUTER JOIN CommonAttributes AS	caOBP ON caOBP.FormFK = d.IntakePK AND caOBP.FormType = 'IN-OBP'
LEFT OUTER JOIN PC AS pc ON pc.PCPK = caOBP.PCFK AND pc.Gender = '02'

LEFT OUTER JOIN 
(SELECT HVCaseFK, min(TCDOB) [TCDOB]
FROM TCID GROUP BY HVCaseFK) AS t ON t.HVCaseFK = a.HVCasePK

WHERE (b.DischargeDate IS NULL OR b.DischargeDate >= @StartDt) AND a.IntakeDate <= @EndDt
AND b.ProgramFK = @programfk
)

, y AS (
SELECT 
  count(*) [n]
, sum(CASE WHEN x.Race = '01' THEN 1 ELSE 0 END) [1White]
, sum(CASE WHEN x.Race = '02' THEN 1 ELSE 0 END) [1Black]
, sum(CASE WHEN x.Race = '03' THEN 1 ELSE 0 END) [1Hispanic]
, sum(CASE WHEN x.Race = '04' THEN 1 ELSE 0 END) [1Asian]
, sum(CASE WHEN x.Race = '05' THEN 1 ELSE 0 END) [1NativeAmerican]
, sum(CASE WHEN x.Race = '06' THEN 1 ELSE 0 END) [1Multiracial]
, sum(CASE WHEN x.Race = '07' THEN 1 ELSE 0 END) [1Other]
, sum(CASE WHEN x.Age < 18 THEN 1 ELSE 0 END) [2Age_17]
, sum(CASE WHEN x.Age BETWEEN 18 AND 19 THEN 1 ELSE 0 END) [2Age_18_20]
, sum(CASE WHEN x.Age BETWEEN 20 AND 29 THEN 1 ELSE 0 END) [2Age_21_30]
, sum(CASE WHEN x.Age >= 30 THEN 1 ELSE 0 END) [2Age_30+]
, sum(CASE WHEN x.Edu IN ('01', '02') THEN 1 ELSE 0 END) [3Less12Yr]
, sum(CASE WHEN x.Edu IN ('03', '04') THEN 1 ELSE 0 END) [3HighSchool]
, sum(CASE WHEN x.Edu IN ('05', '06', '07', '08') THEN 1 ELSE 0 END) [3PostSecondary]
, sum(CASE WHEN x.pc1Employed = 1 THEN 1 ELSE 0 END) [4PC1Employed]
, sum(CASE WHEN x.pc2Employed = 1 OR x.obpEmployed = 1 THEN 1 ELSE 0 END) [4PC2Employed]
, sum(CASE WHEN x.pc1Employed = 1 OR x.pc2Employed = 1 OR x.obpEmployed = 1 THEN 1 ELSE 0 END) [4PC1orPC2Employed]
, sum(CASE WHEN x.pc1TrainingProgram = 1 THEN 1 ELSE 0 END) [4PC1TrainingProgram]
, sum(CASE WHEN x.pc2TrainingProgram = 1 OR x.obpTrainingProgram = 1 THEN 1 ELSE 0 END) [4PC2TrainingProgram]
, sum(CASE WHEN x.pc1Medicaid = 1 THEN 1 ELSE 0 END) [5PC1Medicaid]
, sum(CASE WHEN x.TANF = 1 THEN 1 ELSE 0 END) [5TANF]
, sum(CASE WHEN x.FoodStamps = 1 THEN 1 ELSE 0 END) [5FoodStamps]
, sum(CASE WHEN x.pc1MaritalStatus = '01' THEN 1 ELSE 0 END) [6Married]
, sum(CASE WHEN x.OBPMaleInHoushold IS NOT null THEN 1 ELSE 0 END) [7OBPInHousehold]
, sum(CASE WHEN x.PC2InHoushold IS NOT null THEN 1 ELSE 0 END) [7PC2InHousehold]
, sum(CASE WHEN x.yrEnrolled < 1 THEN 1 ELSE 0 END) [9LessThan1Yr]
, sum(CASE WHEN x.yrEnrolled = 1 THEN 1 ELSE 0 END) [9UpTo2Yr]
, sum(CASE WHEN x.yrEnrolled = 2 THEN 1 ELSE 0 END) [9UpTo3Yr]
, sum(CASE WHEN x.yrEnrolled >= 3 THEN 1 ELSE 0 END) [9Over3Yr]
, sum(CASE WHEN x.PrenatalStatus = 1 THEN 1 ELSE 0 END) [10PrenatalAtEnrolled]
, sum(CASE WHEN x.NeedInterpreter = 1 THEN 1 ELSE 0 END) [11NeedInterpreter]
FROM x AS x
)

, z AS (
SELECT y.*, CASE WHEN y.[n] = 0 THEN 1 ELSE y.[n] END [m]
, f.[8MotherWithOtherChild], g.[5TCMedicaid]
, case when g.[5TC] = 0 then 1 else g.[5TC] end [5TCm], g.[5TC] 
FROM y
join MotherWithOtherChildren as f on 1 = 1
join TCMedicaid as g on 1 = 1

)

SELECT n
, str([1White],5) + ' (' + str(round((100.0 * [1White] / [m]), 0),3) + '%)' [1White]
, str([1Black],5) + ' (' + str(round((100.0 * [1Black] / [m]), 0),3) + '%)' [1Black]
, str([1Hispanic],5) + ' (' + str(round((100.0 * [1Hispanic] / [m]), 0),3) + '%)' [1Hispanic]
, str([1Asian],5) + ' (' + str(round((100.0 * [1Asian] / [m]), 0),3) + '%)' [1Asian]
, str([1NativeAmerican],5) + ' (' + str(round((100.0 * [1NativeAmerican] / [m]), 0),3) + '%)' [1NativeAmerican]
, str([1Multiracial],5) + ' (' + str(round((100.0 * [1Multiracial] / [m]), 0),3) + '%)' [1Multiracial]
, str([1Other],5) + ' (' + str(round((100.0 * [1Other] / [m]), 0),3) + '%)' [1Other]

, str([2Age_18_20],5) + ' (' + str(round((100.0 * [2Age_18_20] / [m]), 0),3) + '%)' [2Age_18_20]
, str([2Age_17],5) + ' (' + str(round((100.0 * [2Age_17] / [m]), 0),3) + '%)' [2Age_17]
, str([2Age_21_30],5) + ' (' + str(round((100.0 * [2Age_21_30] / [m]), 0),3) + '%)' [2Age_21_30]
, str([2Age_30+],5) + ' (' + str(round((100.0 * [2Age_30+] / [m]), 0),3) + '%)' [2Age_30+]
, str([3Less12Yr],5) + ' (' + str(round((100.0 * [3Less12Yr] / [m]), 0),3) + '%)' [3Less12Yr]
, str([3HighSchool],5) + ' (' + str(round((100.0 * [3HighSchool] / [m]), 0),3) + '%)' [3HighSchool]
, str([3PostSecondary],5) + ' (' + str(round((100.0 * [3PostSecondary] / [m]), 0),3) + '%)' [3PostSecondary]
, str([4PC1Employed],5) + ' (' + str(round((100.0 * [4PC1Employed] / [m]), 0),3) + '%)' [4PC1Employed]
, str([4PC2Employed],5) + ' (' + str(round((100.0 * [4PC2Employed] / [m]), 0),3) + '%)' [4PC2Employed]
, str([4PC1orPC2Employed],5) + ' (' + str(round((100.0 * [4PC1orPC2Employed] / [m]), 0),3) + '%)' [4PC1orPC2Employed]
, str([4PC1TrainingProgram],5) + ' (' + str(round((100.0 * [4PC1TrainingProgram] / [m]), 0),3) + '%)' [4PC1TrainingProgram]
, str([4PC2TrainingProgram],5) + ' (' + str(round((100.0 * [4PC2TrainingProgram] / [m]), 0),3) + '%)' [4PC2TrainingProgram]
, str([5PC1Medicaid],5) + ' (' + str(round((100.0 * [5PC1Medicaid] / [m]), 0),3) + '%)' [5PC1Medicaid]
, str([5TANF],5) + ' (' + str(round((100.0 * [5TANF] / [m]), 0),3) + '%)' [5TANF]
, str([5FoodStamps],5) + ' (' + str(round((100.0 * [5FoodStamps] / [m]), 0),3) + '%)' [5FoodStamps]
, str([6Married],5) + ' (' + str(round((100.0 * [6Married] / [m]), 0),3) + '%)' [6Married]
, str([7OBPInHousehold],5) + ' (' + str(round((100.0 * [7OBPInHousehold] / [m]), 0),3) + '%)' [7OBPInHousehold]
, str([7PC2InHousehold],5) + ' (' + str(round((100.0 * [7PC2InHousehold] / [m]), 0),3) + '%)' [7PC2InHousehold]
, str([9LessThan1Yr],5) + ' (' + str(round((100.0 * [9LessThan1Yr] / [m]), 0),3) + '%)' [9LessThan1Yr]
, str([9UpTo2Yr],5) + ' (' + str(round((100.0 * [9UpTo2Yr] / [m]), 0),3) + '%)' [9UpTo2Yr]
, str([9UpTo3Yr],5) + ' (' + str(round((100.0 * [9UpTo3Yr] / [m]), 0),3) + '%)' [9UpTo3Yr]
, str([9Over3Yr],5) + ' (' + str(round((100.0 * [9Over3Yr] / [m]), 0),3) + '%)' [9Over3Yr]
, str([10PrenatalAtEnrolled],5) + ' (' + str(round((100.0 * [10PrenatalAtEnrolled] / [m]), 0),3) + '%)' [10PrenatalAtEnrolled]
, str([11NeedInterpreter],5) + ' (' + str(round((100.0 * [11NeedInterpreter] / [m]), 0),3) + '%)' [11NeedInterpreter]

, str(n-[8MotherWithOtherChild],5) + ' (' + str(round((100.0 * (n-[8MotherWithOtherChild]) / [m]), 0),3) + '%)' [8FirstTimeMom]
, str([5TCMedicaid],5) + ' (' + str(round((100.0 * [5TCMedicaid] / [5TCm]), 0),3) + '%)' [5TCMedicaid]
, [5TC]

FROM z

GO
