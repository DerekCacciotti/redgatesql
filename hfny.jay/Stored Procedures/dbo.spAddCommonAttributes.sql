
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCommonAttributes](@AvailableMonthlyIncome numeric(4, 0)=NULL,
@CommonAttributesCreator char(10)=NULL,
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
@HIUnknown bit=NULL,
@HoursPerMonth int=NULL,
@HVCaseFK int=NULL,
@IsCurrentlyEmployed char(1)=NULL,
@LanguageSpecify varchar(100)=NULL,
@Looked4Employment char(1)=NULL,
@MaritalStatus char(2)=NULL,
@MonthlyIncomeUnknown bit=NULL,
@NumberEmployed int=NULL,
@NumberInHouse int=NULL,
@OBPInHome char(1)=NULL,
@OBPInvolvement char(2)=NULL,
@OBPInvolvementSpecify varchar(500)=NULL,
@Parity char(2)=NULL,
@PBEmergencyAssistance char(1)=NULL,
@PBEmergencyAssistanceAmount numeric(4, 0)=NULL,
@PBEmergencyAssistanceAtFollowUp char(1)=NULL,
@PBFoodStamps char(1)=NULL,
@PBFoodStampsAmount numeric(4, 0)=NULL,
@PBFoodStampsAtFollowUp char(1)=NULL,
@PBSSI char(1)=NULL,
@PBSSIAmount numeric(4, 0)=NULL,
@PBSSIAtFollowUp char(1)=NULL,
@PBTANF char(1)=NULL,
@PBTANFAmount numeric(4, 0)=NULL,
@PBTANFAtFollowUp char(1)=NULL,
@PBWIC char(1)=NULL,
@PBWICAmount numeric(4, 0)=NULL,
@PBWICAtFollowUp char(1)=NULL,
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
@TCHIPrivateInsurance bit=NULL,
@TCHIOther bit=NULL,
@TCHIOtherSpecify varchar(100)=NULL,
@TCHIUninsured bit=NULL,
@TCHIUnknown bit=NULL,
@TCMedicalFacilityFK int=NULL,
@TCMedicalProviderFK int=NULL,
@TCReceivingMedicaid char(1)=NULL,
@TimeBreastFed char(2)=NULL,
@WasBreastFed bit=NULL,
@WhyNotBreastFed char(2)=NULL)
AS
INSERT INTO CommonAttributes(
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
HIUnknown,
HoursPerMonth,
HVCaseFK,
IsCurrentlyEmployed,
LanguageSpecify,
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
PBEmergencyAssistanceAtFollowUp,
PBFoodStamps,
PBFoodStampsAmount,
PBFoodStampsAtFollowUp,
PBSSI,
PBSSIAmount,
PBSSIAtFollowUp,
PBTANF,
PBTANFAmount,
PBTANFAtFollowUp,
PBWIC,
PBWICAmount,
PBWICAtFollowUp,
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
TCHIPrivateInsurance,
TCHIOther,
TCHIOtherSpecify,
TCHIUninsured,
TCHIUnknown,
TCMedicalFacilityFK,
TCMedicalProviderFK,
TCReceivingMedicaid,
TimeBreastFed,
WasBreastFed,
WhyNotBreastFed
)
VALUES(
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
@HIUnknown,
@HoursPerMonth,
@HVCaseFK,
@IsCurrentlyEmployed,
@LanguageSpecify,
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
@PBEmergencyAssistanceAtFollowUp,
@PBFoodStamps,
@PBFoodStampsAmount,
@PBFoodStampsAtFollowUp,
@PBSSI,
@PBSSIAmount,
@PBSSIAtFollowUp,
@PBTANF,
@PBTANFAmount,
@PBTANFAtFollowUp,
@PBWIC,
@PBWICAmount,
@PBWICAtFollowUp,
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
@TCHIPrivateInsurance,
@TCHIOther,
@TCHIOtherSpecify,
@TCHIUninsured,
@TCHIUnknown,
@TCMedicalFacilityFK,
@TCMedicalProviderFK,
@TCReceivingMedicaid,
@TimeBreastFed,
@WasBreastFed,
@WhyNotBreastFed
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
