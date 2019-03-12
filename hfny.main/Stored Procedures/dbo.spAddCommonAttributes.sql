SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCommonAttributes](@AvailableMonthlyBenefits numeric(4, 0)=NULL,
@AvailableMonthlyBenefitsUnknown bit=NULL,
@AvailableMonthlyIncome numeric(5, 0)=NULL,
@CommonAttributesCreator varchar(max)=NULL,
@EducationalEnrollment char(1)=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(8)=NULL,
@Gravida char(2)=NULL,
@HIFamilyChildHealthPlus bit=NULL,
@HighestGrade char(2)=NULL,
@HIMedicaidCaseNumber varchar(20)=NULL,
@HIOther bit=NULL,
@HIOtherSpecify varchar(100)=NULL,
@HIPCAP bit=NULL,
@HIPCAPCaseNumber varchar(20)=NULL,
@HIPrivate bit=NULL,
@HIUninsured bit=NULL,
@HIUnknown bit=NULL,
@HoursPerMonth int=NULL,
@HVCaseFK int=NULL,
@IsCurrentlyEmployed char(1)=NULL,
@LanguageSpecify varchar(100)=NULL,
@LivingArrangement char(2)=NULL,
@LivingArrangementSpecific char(2)=NULL,
@Looked4Employment char(1)=NULL,
@MaritalStatus char(2)=NULL,
@MonthlyIncomeUnknown bit=NULL,
@NumberEmployed int=NULL,
@NumberInHouse int=NULL,
@OBPInHome char(1)=NULL,
@OBPInvolvement char(2)=NULL,
@OBPInvolvementSpecify varchar(500)=NULL,
@Parity int=NULL,
@PBEmergencyAssistance char(1)=NULL,
@PBEmergencyAssistanceAmount numeric(4, 0)=NULL,
@PBFoodStamps char(1)=NULL,
@PBFoodStampsAmount numeric(4, 0)=NULL,
@PBSSI char(1)=NULL,
@PBSSIAmount numeric(4, 0)=NULL,
@PBTANF char(1)=NULL,
@PBTANFAmount numeric(4, 0)=NULL,
@PBWIC char(1)=NULL,
@PBWICAmount numeric(4, 0)=NULL,
@PC1HasMedicalProvider char(1)=NULL,
@PC1MedicalFacilityFK int=NULL,
@PC1MedicalProviderFK int=NULL,
@PC1ReceivingMedicaid char(1)=NULL,
@PCFK int=NULL,
@PreviouslyEmployed char(1)=NULL,
@PrimaryLanguage char(2)=NULL,
@ProgramFK int=NULL,
@ReceivingPreNatalCare char(1)=NULL,
@ReceivingPublicBenefits char(1)=NULL,
@SIDomesticViolence char(1)=NULL,
@SICPSACS char(1)=NULL,
@SIMentalHealth char(1)=NULL,
@SISubstanceAbuse char(1)=NULL,
@TANFServices bit=NULL,
@TANFServicesNo char(2)=NULL,
@TANFServicesNoSpecify varchar(100)=NULL,
@TCHasMedicalProvider char(1)=NULL,
@TCHIFamilyChildHealthPlus bit=NULL,
@TCHIMedicaidCaseNumber varchar(20)=NULL,
@TCHIPrivateInsurance bit=NULL,
@TCHIOther bit=NULL,
@TCHIOtherSpecify varchar(100)=NULL,
@TCHIUninsured bit=NULL,
@TCHIUnknown bit=NULL,
@TCMedicalCareSource char(2)=NULL,
@TCMedicalCareSourceOtherSpecify varchar(100)=NULL,
@TCMedicalFacilityFK int=NULL,
@TCMedicalProviderFK int=NULL,
@TCReceivingMedicaid char(1)=NULL,
@TimeBreastFed char(2)=NULL,
@WasBreastFed bit=NULL,
@WhyNotBreastFed char(2)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CommonAttributesPK
FROM CommonAttributes lastRow
WHERE 
@AvailableMonthlyBenefits = lastRow.AvailableMonthlyBenefits AND
@AvailableMonthlyBenefitsUnknown = lastRow.AvailableMonthlyBenefitsUnknown AND
@AvailableMonthlyIncome = lastRow.AvailableMonthlyIncome AND
@CommonAttributesCreator = lastRow.CommonAttributesCreator AND
@EducationalEnrollment = lastRow.EducationalEnrollment AND
@FormDate = lastRow.FormDate AND
@FormFK = lastRow.FormFK AND
@FormInterval = lastRow.FormInterval AND
@FormType = lastRow.FormType AND
@Gravida = lastRow.Gravida AND
@HIFamilyChildHealthPlus = lastRow.HIFamilyChildHealthPlus AND
@HighestGrade = lastRow.HighestGrade AND
@HIMedicaidCaseNumber = lastRow.HIMedicaidCaseNumber AND
@HIOther = lastRow.HIOther AND
@HIOtherSpecify = lastRow.HIOtherSpecify AND
@HIPCAP = lastRow.HIPCAP AND
@HIPCAPCaseNumber = lastRow.HIPCAPCaseNumber AND
@HIPrivate = lastRow.HIPrivate AND
@HIUninsured = lastRow.HIUninsured AND
@HIUnknown = lastRow.HIUnknown AND
@HoursPerMonth = lastRow.HoursPerMonth AND
@HVCaseFK = lastRow.HVCaseFK AND
@IsCurrentlyEmployed = lastRow.IsCurrentlyEmployed AND
@LanguageSpecify = lastRow.LanguageSpecify AND
@LivingArrangement = lastRow.LivingArrangement AND
@LivingArrangementSpecific = lastRow.LivingArrangementSpecific AND
@Looked4Employment = lastRow.Looked4Employment AND
@MaritalStatus = lastRow.MaritalStatus AND
@MonthlyIncomeUnknown = lastRow.MonthlyIncomeUnknown AND
@NumberEmployed = lastRow.NumberEmployed AND
@NumberInHouse = lastRow.NumberInHouse AND
@OBPInHome = lastRow.OBPInHome AND
@OBPInvolvement = lastRow.OBPInvolvement AND
@OBPInvolvementSpecify = lastRow.OBPInvolvementSpecify AND
@Parity = lastRow.Parity AND
@PBEmergencyAssistance = lastRow.PBEmergencyAssistance AND
@PBEmergencyAssistanceAmount = lastRow.PBEmergencyAssistanceAmount AND
@PBFoodStamps = lastRow.PBFoodStamps AND
@PBFoodStampsAmount = lastRow.PBFoodStampsAmount AND
@PBSSI = lastRow.PBSSI AND
@PBSSIAmount = lastRow.PBSSIAmount AND
@PBTANF = lastRow.PBTANF AND
@PBTANFAmount = lastRow.PBTANFAmount AND
@PBWIC = lastRow.PBWIC AND
@PBWICAmount = lastRow.PBWICAmount AND
@PC1HasMedicalProvider = lastRow.PC1HasMedicalProvider AND
@PC1MedicalFacilityFK = lastRow.PC1MedicalFacilityFK AND
@PC1MedicalProviderFK = lastRow.PC1MedicalProviderFK AND
@PC1ReceivingMedicaid = lastRow.PC1ReceivingMedicaid AND
@PCFK = lastRow.PCFK AND
@PreviouslyEmployed = lastRow.PreviouslyEmployed AND
@PrimaryLanguage = lastRow.PrimaryLanguage AND
@ProgramFK = lastRow.ProgramFK AND
@ReceivingPreNatalCare = lastRow.ReceivingPreNatalCare AND
@ReceivingPublicBenefits = lastRow.ReceivingPublicBenefits AND
@SIDomesticViolence = lastRow.SIDomesticViolence AND
@SICPSACS = lastRow.SICPSACS AND
@SIMentalHealth = lastRow.SIMentalHealth AND
@SISubstanceAbuse = lastRow.SISubstanceAbuse AND
@TANFServices = lastRow.TANFServices AND
@TANFServicesNo = lastRow.TANFServicesNo AND
@TANFServicesNoSpecify = lastRow.TANFServicesNoSpecify AND
@TCHasMedicalProvider = lastRow.TCHasMedicalProvider AND
@TCHIFamilyChildHealthPlus = lastRow.TCHIFamilyChildHealthPlus AND
@TCHIMedicaidCaseNumber = lastRow.TCHIMedicaidCaseNumber AND
@TCHIPrivateInsurance = lastRow.TCHIPrivateInsurance AND
@TCHIOther = lastRow.TCHIOther AND
@TCHIOtherSpecify = lastRow.TCHIOtherSpecify AND
@TCHIUninsured = lastRow.TCHIUninsured AND
@TCHIUnknown = lastRow.TCHIUnknown AND
@TCMedicalCareSource = lastRow.TCMedicalCareSource AND
@TCMedicalCareSourceOtherSpecify = lastRow.TCMedicalCareSourceOtherSpecify AND
@TCMedicalFacilityFK = lastRow.TCMedicalFacilityFK AND
@TCMedicalProviderFK = lastRow.TCMedicalProviderFK AND
@TCReceivingMedicaid = lastRow.TCReceivingMedicaid AND
@TimeBreastFed = lastRow.TimeBreastFed AND
@WasBreastFed = lastRow.WasBreastFed AND
@WhyNotBreastFed = lastRow.WhyNotBreastFed
ORDER BY CommonAttributesPK DESC) 
BEGIN
INSERT INTO CommonAttributes(
AvailableMonthlyBenefits,
AvailableMonthlyBenefitsUnknown,
AvailableMonthlyIncome,
CommonAttributesCreator,
EducationalEnrollment,
FormDate,
FormFK,
FormInterval,
FormType,
Gravida,
HIFamilyChildHealthPlus,
HighestGrade,
HIMedicaidCaseNumber,
HIOther,
HIOtherSpecify,
HIPCAP,
HIPCAPCaseNumber,
HIPrivate,
HIUninsured,
HIUnknown,
HoursPerMonth,
HVCaseFK,
IsCurrentlyEmployed,
LanguageSpecify,
LivingArrangement,
LivingArrangementSpecific,
Looked4Employment,
MaritalStatus,
MonthlyIncomeUnknown,
NumberEmployed,
NumberInHouse,
OBPInHome,
OBPInvolvement,
OBPInvolvementSpecify,
Parity,
PBEmergencyAssistance,
PBEmergencyAssistanceAmount,
PBFoodStamps,
PBFoodStampsAmount,
PBSSI,
PBSSIAmount,
PBTANF,
PBTANFAmount,
PBWIC,
PBWICAmount,
PC1HasMedicalProvider,
PC1MedicalFacilityFK,
PC1MedicalProviderFK,
PC1ReceivingMedicaid,
PCFK,
PreviouslyEmployed,
PrimaryLanguage,
ProgramFK,
ReceivingPreNatalCare,
ReceivingPublicBenefits,
SIDomesticViolence,
SICPSACS,
SIMentalHealth,
SISubstanceAbuse,
TANFServices,
TANFServicesNo,
TANFServicesNoSpecify,
TCHasMedicalProvider,
TCHIFamilyChildHealthPlus,
TCHIMedicaidCaseNumber,
TCHIPrivateInsurance,
TCHIOther,
TCHIOtherSpecify,
TCHIUninsured,
TCHIUnknown,
TCMedicalCareSource,
TCMedicalCareSourceOtherSpecify,
TCMedicalFacilityFK,
TCMedicalProviderFK,
TCReceivingMedicaid,
TimeBreastFed,
WasBreastFed,
WhyNotBreastFed
)
VALUES(
@AvailableMonthlyBenefits,
@AvailableMonthlyBenefitsUnknown,
@AvailableMonthlyIncome,
@CommonAttributesCreator,
@EducationalEnrollment,
@FormDate,
@FormFK,
@FormInterval,
@FormType,
@Gravida,
@HIFamilyChildHealthPlus,
@HighestGrade,
@HIMedicaidCaseNumber,
@HIOther,
@HIOtherSpecify,
@HIPCAP,
@HIPCAPCaseNumber,
@HIPrivate,
@HIUninsured,
@HIUnknown,
@HoursPerMonth,
@HVCaseFK,
@IsCurrentlyEmployed,
@LanguageSpecify,
@LivingArrangement,
@LivingArrangementSpecific,
@Looked4Employment,
@MaritalStatus,
@MonthlyIncomeUnknown,
@NumberEmployed,
@NumberInHouse,
@OBPInHome,
@OBPInvolvement,
@OBPInvolvementSpecify,
@Parity,
@PBEmergencyAssistance,
@PBEmergencyAssistanceAmount,
@PBFoodStamps,
@PBFoodStampsAmount,
@PBSSI,
@PBSSIAmount,
@PBTANF,
@PBTANFAmount,
@PBWIC,
@PBWICAmount,
@PC1HasMedicalProvider,
@PC1MedicalFacilityFK,
@PC1MedicalProviderFK,
@PC1ReceivingMedicaid,
@PCFK,
@PreviouslyEmployed,
@PrimaryLanguage,
@ProgramFK,
@ReceivingPreNatalCare,
@ReceivingPublicBenefits,
@SIDomesticViolence,
@SICPSACS,
@SIMentalHealth,
@SISubstanceAbuse,
@TANFServices,
@TANFServicesNo,
@TANFServicesNoSpecify,
@TCHasMedicalProvider,
@TCHIFamilyChildHealthPlus,
@TCHIMedicaidCaseNumber,
@TCHIPrivateInsurance,
@TCHIOther,
@TCHIOtherSpecify,
@TCHIUninsured,
@TCHIUnknown,
@TCMedicalCareSource,
@TCMedicalCareSourceOtherSpecify,
@TCMedicalFacilityFK,
@TCMedicalProviderFK,
@TCReceivingMedicaid,
@TimeBreastFed,
@WasBreastFed,
@WhyNotBreastFed
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
