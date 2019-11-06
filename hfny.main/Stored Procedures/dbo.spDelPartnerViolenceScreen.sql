SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPartnerViolenceScreen](@PartnerViolenceScreenPK int)

AS


DELETE 
FROM PartnerViolenceScreen
WHERE PartnerViolenceScreenPK = @PartnerViolenceScreenPK
GO
