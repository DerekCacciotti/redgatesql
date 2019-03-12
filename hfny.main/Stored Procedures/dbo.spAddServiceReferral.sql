SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddServiceReferral](@FamilyCode char(2)=NULL,
@FamilyCodeSpecify varchar(100)=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@NatureOfReferral char(2)=NULL,
@OtherServiceSpecify varchar(500)=NULL,
@ProgramFK int=NULL,
@ProvidingAgencyFK int=NULL,
@ReasonNoService char(2)=NULL,
@ReasonNoServiceSpecify varchar(500)=NULL,
@ReferralDate datetime=NULL,
@ServiceCode char(2)=NULL,
@ServiceReceived char(1)=NULL,
@ServiceReferralCreator varchar(max)=NULL,
@StartDate datetime=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) ServiceReferralPK
FROM ServiceReferral lastRow
WHERE 
@FamilyCode = lastRow.FamilyCode AND
@FamilyCodeSpecify = lastRow.FamilyCodeSpecify AND
@FSWFK = lastRow.FSWFK AND
@HVCaseFK = lastRow.HVCaseFK AND
@NatureOfReferral = lastRow.NatureOfReferral AND
@OtherServiceSpecify = lastRow.OtherServiceSpecify AND
@ProgramFK = lastRow.ProgramFK AND
@ProvidingAgencyFK = lastRow.ProvidingAgencyFK AND
@ReasonNoService = lastRow.ReasonNoService AND
@ReasonNoServiceSpecify = lastRow.ReasonNoServiceSpecify AND
@ReferralDate = lastRow.ReferralDate AND
@ServiceCode = lastRow.ServiceCode AND
@ServiceReceived = lastRow.ServiceReceived AND
@ServiceReferralCreator = lastRow.ServiceReferralCreator AND
@StartDate = lastRow.StartDate
ORDER BY ServiceReferralPK DESC) 
BEGIN
INSERT INTO ServiceReferral(
FamilyCode,
FamilyCodeSpecify,
FSWFK,
HVCaseFK,
NatureOfReferral,
OtherServiceSpecify,
ProgramFK,
ProvidingAgencyFK,
ReasonNoService,
ReasonNoServiceSpecify,
ReferralDate,
ServiceCode,
ServiceReceived,
ServiceReferralCreator,
StartDate
)
VALUES(
@FamilyCode,
@FamilyCodeSpecify,
@FSWFK,
@HVCaseFK,
@NatureOfReferral,
@OtherServiceSpecify,
@ProgramFK,
@ProvidingAgencyFK,
@ReasonNoService,
@ReasonNoServiceSpecify,
@ReferralDate,
@ServiceCode,
@ServiceReceived,
@ServiceReferralCreator,
@StartDate
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
