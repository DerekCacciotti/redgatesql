SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistReferralSource](@ProgramFK int=NULL,
@ReferralSourceName char(50)=NULL,
@RSIsActive bit=NULL,
@listReferralSourcePK_old int=NULL,
@IsMICHC bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listReferralSourcePK
FROM listReferralSource lastRow
WHERE 
@ProgramFK = lastRow.ProgramFK AND
@ReferralSourceName = lastRow.ReferralSourceName AND
@RSIsActive = lastRow.RSIsActive AND
@listReferralSourcePK_old = lastRow.listReferralSourcePK_old AND
@IsMICHC = lastRow.IsMICHC
ORDER BY listReferralSourcePK DESC) 
BEGIN
INSERT INTO listReferralSource(
ProgramFK,
ReferralSourceName,
RSIsActive,
listReferralSourcePK_old,
IsMICHC
)
VALUES(
@ProgramFK,
@ReferralSourceName,
@RSIsActive,
@listReferralSourcePK_old,
@IsMICHC
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
