SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeServiceReferral](@ServiceReferralCategory char(3)=NULL,
@ServiceReferralCode char(2)=NULL,
@ServiceReferralType char(45)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeServiceReferralPK
FROM codeServiceReferral lastRow
WHERE 
@ServiceReferralCategory = lastRow.ServiceReferralCategory AND
@ServiceReferralCode = lastRow.ServiceReferralCode AND
@ServiceReferralType = lastRow.ServiceReferralType
ORDER BY codeServiceReferralPK DESC) 
BEGIN
INSERT INTO codeServiceReferral(
ServiceReferralCategory,
ServiceReferralCode,
ServiceReferralType
)
VALUES(
@ServiceReferralCategory,
@ServiceReferralCode,
@ServiceReferralType
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
