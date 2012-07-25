SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: Jul/23/2012
-- Description:	Home Visit Log Summary Quarterly
-- =============================================
CREATE PROCEDURE [dbo].[rspHomeVisitLogSummaryQuarterly] 
	@programfk INT = NULL, 
	@StartDt datetime,
	@EndDt datetime
AS

--DECLARE @programfk INT = 6 
--DECLARE @StartDt DATETIME = '01/01/2012'
--DECLARE @EndDt DATETIME = '03/31/2012'

DECLARE @xDate DATETIME = '07/01/' + str(year(@StartDt))
DECLARE @StartDtX DATETIME = CASE WHEN @xDate > @StartDt THEN '07/01/' + str(year(@StartDt)-1) ELSE @xDate END
DECLARE @EndDtX DATETIME = @EndDt

DECLARE @x INT = 0
DECLARE @y INT = 0
DECLARE @OutOfHome INT = 0
SELECT 
  @y = count(*)
, @x = sum(CASE WHEN substring(a.VisitType,4,1) = '1' THEN 0 ELSE 1 END)
, @OutOfHome = sum(CASE WHEN substring(a.VisitType,4,1) != '1' AND substring(a.VisitType,3,1) = '1' THEN 1 ELSE 0 END)
FROM HVLog AS a 
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE b.ProgramFK = @programfk AND a.VisitStartTime BETWEEN @StartDt AND @EndDt
AND (b.DischargeDate IS NULL OR b.DischargeDate > @EndDt)
IF @x = 0 
BEGIN
  SET @x = 1
END
IF @y = 0 
BEGIN
  SET @y = 1
END
IF @OutOfHome = 0 
BEGIN
  SET @OutOfHome = 1
END

--SELECT @StartDt, @StartDtX

DECLARE @xX INT = 0
DECLARE @yX INT = 0
DECLARE @OutOfHomeX INT = 0
SELECT 
  @yX = count(*)
, @xX = sum(CASE WHEN substring(a.VisitType,4,1) = '1' THEN 0 ELSE 1 END)
, @OutOfHomeX = sum(CASE WHEN substring(a.VisitType,4,1) != '1' AND substring(a.VisitType,3,1) = '1' THEN 1 ELSE 0 END)
FROM HVLog AS a 
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCaseFK
WHERE b.ProgramFK = @programfk AND a.VisitStartTime BETWEEN @StartDtX AND @EndDtX
AND (b.DischargeDate IS NULL OR b.DischargeDate > @EndDtX)
IF @xX = 0 
BEGIN
  SET @xX = 1
END
IF @yX = 0 
BEGIN
  SET @yX = 1
END
IF @OutOfHomeX = 0 
BEGIN
  SET @OutOfHomeX = 1
END

; WITH q1 AS
(
SELECT 
count(*) AS [n]
, sum(CASE WHEN substring(c.VisitType,4,1) = '1' THEN 1 ELSE 0 END) [Attemped]
, avg(CASE WHEN substring(c.VisitType,4,1) != '1' THEN c.VisitLengthMinute ELSE NULL END) [AverageLength]
, str(sum(CASE WHEN isnull(a.TCDOB, a.EDC) >= c.VisitStartTime THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + '%' [Prenatal]
, str(sum(CASE WHEN isnull(a.TCDOB, a.EDC) < c.VisitStartTime THEN 1 ELSE 0 END) * 100.0 / @y, 10, 0) + '%'  [Postnatal]

, str(sum(CASE WHEN substring(c.VisitType,1,1) = '1' OR substring(c.VisitType,2,1) = '1' THEN 1 ELSE 0 END)
 * 100.0 / @x, 10, 0) + '%'  [InParticipantHome]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitType,1,1) != '1' 
  AND substring(c.VisitType,2,1) != '1' THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [OutParticipantHome]
, str(sum(CASE WHEN (substring(c.VisitType,1,1) = '1' OR substring(c.VisitType,2,1) = '1')
  AND substring(c.VisitType,3,1) = '1' 
  THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%'  [InOutParticipantHome]
  
, sum(CASE WHEN substring(c.VisitType,4,1) != '1' AND substring(c.VisitType,3,1) = '1' THEN 1 ELSE 0 END) [OutOfHome]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,1,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHome, 10, 0) + '%' [MedicalProviderOffice]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,2,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHome, 10, 0) + '%'  [OtherProviderOffice]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,3,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHome, 10, 0) + '%'  [HomeVisitOffice]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,4,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHome, 10, 0) + '%'  [Hospital]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,5,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHome, 10, 0) + '%'  [OtherLocation]

, str(sum(CASE WHEN c.PC1Participated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [PC1Participated]
, str(sum(CASE WHEN c.PC2Participated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [PC2Participated]
, str(sum(CASE WHEN c.OBPParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [OBPParticipated]
, str(sum(CASE WHEN c.FatherFigureParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [FatherFigureParticipated]
, str(sum(CASE WHEN c.TCParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [TCParticipated]
, str(sum(CASE WHEN c.GrandParentParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [GrandParentParticipated]
, str(sum(CASE WHEN c.SiblingParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [SiblingParticipated]
, str(sum(CASE WHEN c.NonPrimaryFSWParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [NonPrimaryFSWParticipated]
, str(sum(CASE WHEN c.HVSupervisorParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [HVSupervisorParticipated]
, str(sum(CASE WHEN c.SupervisorObservation = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [SupervisorObservation]
, str(sum(CASE WHEN c.OtherParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @x, 10, 0) + '%' [OtherParticipated]

, str(sum(CASE WHEN (isnull(c.CDChildDevelopment, '00') = '00' AND isnull(c.CDToys, '00') = '00' 
AND isnull(c.CDOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [ChildDevelopment]

, str(sum(CASE WHEN (isnull(c.PCChildInteraction, '00') = '00' AND isnull(c.PCChildManagement, '00') = '00' 
AND isnull(c.PCFeelings, '00') = '00' AND isnull(c.PCStress, '00') = '00' 
AND isnull(c.PCBasicNeeds, '00') = '00' AND isnull(c.PCShakenBaby, '00') = '00' AND isnull(c.PCShakenBabyVideo, '00') = '00' 
AND isnull(c.PCOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [PCInteraction]

, str(sum(CASE WHEN (isnull(c.HCGeneral, '00') = '00' AND isnull(c.HCChild, '00') = '00' AND isnull(c.HCDental, '00') = '00' 
AND isnull(c.HCFeeding, '00') = '00' AND isnull(c.HCBreastFeeding, '00') = '00' 
AND isnull(c.HCNutrition, '00') = '00' AND isnull(c.HCFamilyPlanning, '00') = '00' AND isnull(c.HCProviders, '00') = '00' 
AND isnull(c.HCFASD, '00') = '00' AND isnull(c.HCSexEducation, '00') = '00' 
AND isnull(c.HCPrenatalCare, '00') = '00' AND isnull(c.HCMedicalAdvocacy, '00') = '00' AND isnull(c.HCSafety, '00') = '00' 
AND isnull(c.HCSmoking, '00') = '00' AND isnull(c.HCSIDS, '00') = '00' 
AND isnull(c.HCOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [HealthCare]

, str(sum(CASE WHEN (isnull(c.FFDomesticViolence, '00') = '00' AND isnull(c.FFFamilyRelations, '00') = '00' 
AND isnull(c.FFSubstanceAbuse, '00') = '00' 
AND isnull(c.FFMentalHealth, '00') = '00' AND isnull(c.FFCommunication, '00') = '00' 
AND isnull(c.FFOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [FamilyFunction]

, str(sum(CASE WHEN (isnull(c.SSCalendar, '00') = '00' AND isnull(c.SSHousekeeping, '00') = '00' 
AND isnull(c.SSTransportation, '00') = '00' AND isnull(c.SSEmployment, '00') = '00' 
AND isnull(c.SSMoneyManagement, '00') = '00' AND isnull(c.SSChildCare, '00') = '00' 
AND isnull(c.SSProblemSolving, '00') = '00' AND isnull(c.SSEducation, '00') = '00' AND isnull(c.SSJob, '00') = '00' 
AND isnull(c.SSOther, '00') = '00' ) OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [SelfSufficincy]

, str(sum(CASE WHEN (isnull(c.CIProblems, '00') = '00' AND isnull(c.CIOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [CrisisIntervention]

, str(sum(CASE WHEN (isnull(c.PAForms, '00') = '00' AND isnull(c.PAVideo, '00') = '00'
AND isnull(c.PAGroups, '00') = '00' AND isnull(c.PAIFSP, '00') = '00'
AND isnull(c.PARecreation, '00') = '00' AND isnull(c.PAOther, '00') = '00'
) OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [ProgramActivity]

, str(sum(CASE WHEN (isnull(c.CATransportation, '00') = '00' AND isnull(c.CAGoods, '00') = '00' AND isnull(c.CALegal, '00') = '00' 
AND isnull(c.CAHousing, '00') = '00' 
AND isnull(c.CAAdvocacy, '00') = '00' AND isnull(c.CATranslation, '00') = '00' AND isnull(c.CALaborSupport, '00') = '00' 
AND isnull(c.CAChildSupport, '00') = '00' 
AND isnull(c.CAParentRights, '00') = '00' AND isnull(c.CAVisitation, '00') = '00' AND isnull(c.CAOther, '00') = '00') 
OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @x, 10, 0) + '%' [ConcreteAcivities]

FROM HVCase AS a 
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCasePK
JOIN HVLog  AS c ON a.HVCasePK = c.HVCaseFK
WHERE b.ProgramFK = @programfk AND c.VisitStartTime BETWEEN @StartDt AND @EndDt
AND (b.DischargeDate IS NULL OR b.DischargeDate > @EndDt)
),

---------------------------------------------------------------------

q2 AS (

SELECT 
count(*) AS [nX]
, sum(CASE WHEN substring(c.VisitType,4,1) = '1' THEN 1 ELSE 0 END) [AttempedX]
, avg(CASE WHEN substring(c.VisitType,4,1) != '1' THEN c.VisitLengthMinute ELSE NULL END) [AverageLengthX]
, str(sum(CASE WHEN isnull(a.TCDOB, a.EDC) >= c.VisitStartTime THEN 1 ELSE 0 END) * 100.0 / @yX, 10, 0) + '%' [PrenatalX]
, str(sum(CASE WHEN isnull(a.TCDOB, a.EDC) < c.VisitStartTime THEN 1 ELSE 0 END) * 100.0 / @yX, 10, 0) + '%'  [PostnatalX]

, str(sum(CASE WHEN substring(c.VisitType,1,1) = '1' OR substring(c.VisitType,2,1) = '1' THEN 1 ELSE 0 END)
 * 100.0 / @xX, 10, 0) + '%'  [InParticipantHomeX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitType,1,1) != '1' 
  AND substring(c.VisitType,2,1) != '1' THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [OutParticipantHomeX]
, str(sum(CASE WHEN (substring(c.VisitType,1,1) = '1' OR substring(c.VisitType,2,1) = '1')
  AND substring(c.VisitType,3,1) = '1' 
  THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%'  [InOutParticipantHomeX]
  
, sum(CASE WHEN substring(c.VisitType,4,1) != '1' AND substring(c.VisitType,3,1) = '1' THEN 1 ELSE 0 END) [OutOfHomeX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,1,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHomeX, 10, 0) + '%' [MedicalProviderOfficeX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,2,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHomeX, 10, 0) + '%'  [OtherProviderOfficeX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,3,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHomeX, 10, 0) + '%'  [HomeVisitOfficeX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,4,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHomeX, 10, 0) + '%'  [HospitalX]
, str(sum(CASE WHEN substring(c.VisitType,3,1) = '1' AND substring(c.VisitLocation,5,1) = '1' THEN 1 ELSE 0 END) * 100.0 / @OutOfHomeX, 10, 0) + '%'  [OtherLocationX]

, str(sum(CASE WHEN c.PC1Participated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [PC1ParticipatedX]
, str(sum(CASE WHEN c.PC2Participated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [PC2ParticipatedX]
, str(sum(CASE WHEN c.OBPParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [OBPParticipatedX]
, str(sum(CASE WHEN c.FatherFigureParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [FatherFigureParticipatedX]
, str(sum(CASE WHEN c.TCParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [TCParticipatedX]
, str(sum(CASE WHEN c.GrandParentParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [GrandParentParticipatedX]
, str(sum(CASE WHEN c.SiblingParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [SiblingParticipatedX]
, str(sum(CASE WHEN c.NonPrimaryFSWParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [NonPrimaryFSWParticipatedX]
, str(sum(CASE WHEN c.HVSupervisorParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [HVSupervisorParticipatedX]
, str(sum(CASE WHEN c.SupervisorObservation = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [SupervisorObservationX]
, str(sum(CASE WHEN c.OtherParticipated = 1 THEN 1 ELSE 0 END) * 100.0 / @xX, 10, 0) + '%' [OtherParticipatedX]

, str(sum(CASE WHEN (isnull(c.CDChildDevelopment, '00') = '00' AND isnull(c.CDToys, '00') = '00' 
AND isnull(c.CDOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [ChildDevelopmentX]

, str(sum(CASE WHEN (isnull(c.PCChildInteraction, '00') = '00' AND isnull(c.PCChildManagement, '00') = '00' 
AND isnull(c.PCFeelings, '00') = '00' AND isnull(c.PCStress, '00') = '00' 
AND isnull(c.PCBasicNeeds, '00') = '00' AND isnull(c.PCShakenBaby, '00') = '00' AND isnull(c.PCShakenBabyVideo, '00') = '00' 
AND isnull(c.PCOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [PCInteractionX]

, str(sum(CASE WHEN (isnull(c.HCGeneral, '00') = '00' AND isnull(c.HCChild, '00') = '00' AND isnull(c.HCDental, '00') = '00' 
AND isnull(c.HCFeeding, '00') = '00' AND isnull(c.HCBreastFeeding, '00') = '00' 
AND isnull(c.HCNutrition, '00') = '00' AND isnull(c.HCFamilyPlanning, '00') = '00' AND isnull(c.HCProviders, '00') = '00' 
AND isnull(c.HCFASD, '00') = '00' AND isnull(c.HCSexEducation, '00') = '00' 
AND isnull(c.HCPrenatalCare, '00') = '00' AND isnull(c.HCMedicalAdvocacy, '00') = '00' AND isnull(c.HCSafety, '00') = '00' 
AND isnull(c.HCSmoking, '00') = '00' AND isnull(c.HCSIDS, '00') = '00' 
AND isnull(c.HCOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [HealthCareX]

, str(sum(CASE WHEN (isnull(c.FFDomesticViolence, '00') = '00' AND isnull(c.FFFamilyRelations, '00') = '00' 
AND isnull(c.FFSubstanceAbuse, '00') = '00' 
AND isnull(c.FFMentalHealth, '00') = '00' AND isnull(c.FFCommunication, '00') = '00' 
AND isnull(c.FFOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [FamilyFunctionX]

, str(sum(CASE WHEN (isnull(c.SSCalendar, '00') = '00' AND isnull(c.SSHousekeeping, '00') = '00' 
AND isnull(c.SSTransportation, '00') = '00' AND isnull(c.SSEmployment, '00') = '00' 
AND isnull(c.SSMoneyManagement, '00') = '00' AND isnull(c.SSChildCare, '00') = '00' 
AND isnull(c.SSProblemSolving, '00') = '00' AND isnull(c.SSEducation, '00') = '00' AND isnull(c.SSJob, '00') = '00' 
AND isnull(c.SSOther, '00') = '00' ) OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [SelfSufficincyX]

, str(sum(CASE WHEN (isnull(c.CIProblems, '00') = '00' AND isnull(c.CIOther, '00') = '00') OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [CrisisInterventionX]


, str(sum(CASE WHEN (isnull(c.PAForms, '00') = '00' AND isnull(c.PAVideo, '00') = '00'
AND isnull(c.PAGroups, '00') = '00' AND isnull(c.PAIFSP, '00') = '00'
AND isnull(c.PARecreation, '00') = '00' AND isnull(c.PAOther, '00') = '00'
) OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [ProgramActivityX]

, str(sum(CASE WHEN (isnull(c.CATransportation, '00') = '00' AND isnull(c.CAGoods, '00') = '00' AND isnull(c.CALegal, '00') = '00' 
AND isnull(c.CAHousing, '00') = '00' 
AND isnull(c.CAAdvocacy, '00') = '00' AND isnull(c.CATranslation, '00') = '00' AND isnull(c.CALaborSupport, '00') = '00' 
AND isnull(c.CAChildSupport, '00') = '00' 
AND isnull(c.CAParentRights, '00') = '00' AND isnull(c.CAVisitation, '00') = '00' AND isnull(c.CAOther, '00') = '00') 
OR substring(c.VisitType,4,1) = '1' 
THEN 0 ELSE 1 END) * 100.0 / @xX, 10, 0) + '%' [ConcreteAcivitiesX]

FROM HVCase AS a 
JOIN CaseProgram AS b ON b.HVCaseFK = a.HVCasePK
JOIN HVLog  AS c ON a.HVCasePK = c.HVCaseFK
WHERE b.ProgramFK = @programfk AND c.VisitStartTime BETWEEN @StartDtX AND @EndDtX
AND (b.DischargeDate IS NULL OR b.DischargeDate > @EndDtX)
)

SELECT * FROM q1
JOIN q2 ON 1 = 1


























GO
