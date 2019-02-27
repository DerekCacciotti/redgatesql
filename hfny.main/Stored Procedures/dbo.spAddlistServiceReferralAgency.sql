SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistServiceReferralAgency](@AgencyIsActive bit=NULL,
@AgencyName varchar(100)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listServiceReferralAgencyPK
FROM listServiceReferralAgency lastRow
WHERE 
@AgencyIsActive = lastRow.AgencyIsActive AND
@AgencyName = lastRow.AgencyName AND
@ProgramFK = lastRow.ProgramFK
ORDER BY listServiceReferralAgencyPK DESC) 
BEGIN
INSERT INTO listServiceReferralAgency(
AgencyIsActive,
AgencyName,
ProgramFK
)
VALUES(
@AgencyIsActive,
@AgencyName,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
