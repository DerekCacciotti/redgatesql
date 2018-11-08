SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVScreen](@FAWFK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ReferralMade char(1)=NULL,
@ReferralSource char(2)=NULL,
@ReferralSourceFK int=NULL,
@ReferralSourceSpecify varchar(500)=NULL,
@Relation2TC char(2)=NULL,
@Relation2TCSpecify varchar(100)=NULL,
@RiskAbortionHistory char(1)=NULL,
@RiskAbortionTry char(1)=NULL,
@RiskAdoption char(1)=NULL,
@RiskDepressionHistory char(1)=NULL,
@RiskEducation char(1)=NULL,
@RiskInadequateSupports char(1)=NULL,
@RiskMaritalProblems char(1)=NULL,
@RiskNoPhone char(1)=NULL,
@RiskNoPrenatalCare char(1)=NULL,
@RiskNotMarried char(1)=NULL,
@RiskPartnerJobless char(1)=NULL,
@RiskPoor char(1)=NULL,
@RiskPsychiatricHistory char(1)=NULL,
@RiskSubstanceAbuseHistory char(1)=NULL,
@RiskUnder21 char(1)=NULL,
@RiskUnstableHousing char(1)=NULL,
@ScreenCreator char(10)=NULL,
@ScreenDate datetime=NULL,
@ScreenerFirstName varchar(200)=NULL,
@ScreenerLastName varchar(200)=NULL,
@ScreenerMiddleInitial char(1)=NULL,
@ScreenerPhone char(12)=NULL,
@ScreenResult char(1)=NULL,
@ScreenVersion char(2)=NULL,
@TargetArea char(1)=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
INSERT INTO HVScreen(
FAWFK,
HVCaseFK,
ProgramFK,
ReferralMade,
ReferralSource,
ReferralSourceFK,
ReferralSourceSpecify,
Relation2TC,
Relation2TCSpecify,
RiskAbortionHistory,
RiskAbortionTry,
RiskAdoption,
RiskDepressionHistory,
RiskEducation,
RiskInadequateSupports,
RiskMaritalProblems,
RiskNoPhone,
RiskNoPrenatalCare,
RiskNotMarried,
RiskPartnerJobless,
RiskPoor,
RiskPsychiatricHistory,
RiskSubstanceAbuseHistory,
RiskUnder21,
RiskUnstableHousing,
ScreenCreator,
ScreenDate,
ScreenerFirstName,
ScreenerLastName,
ScreenerMiddleInitial,
ScreenerPhone,
ScreenResult,
ScreenVersion,
TargetArea,
TransferredtoProgram
)
VALUES(
@FAWFK,
@HVCaseFK,
@ProgramFK,
@ReferralMade,
@ReferralSource,
@ReferralSourceFK,
@ReferralSourceSpecify,
@Relation2TC,
@Relation2TCSpecify,
@RiskAbortionHistory,
@RiskAbortionTry,
@RiskAdoption,
@RiskDepressionHistory,
@RiskEducation,
@RiskInadequateSupports,
@RiskMaritalProblems,
@RiskNoPhone,
@RiskNoPrenatalCare,
@RiskNotMarried,
@RiskPartnerJobless,
@RiskPoor,
@RiskPsychiatricHistory,
@RiskSubstanceAbuseHistory,
@RiskUnder21,
@RiskUnstableHousing,
@ScreenCreator,
@ScreenDate,
@ScreenerFirstName,
@ScreenerLastName,
@ScreenerMiddleInitial,
@ScreenerPhone,
@ScreenResult,
@ScreenVersion,
@TargetArea,
@TransferredtoProgram
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
