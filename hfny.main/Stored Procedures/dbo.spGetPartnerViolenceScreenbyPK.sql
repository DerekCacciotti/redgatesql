SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPartnerViolenceScreenbyPK]

(@PartnerViolenceScreenPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM PartnerViolenceScreen
WHERE PartnerViolenceScreenPK = @PartnerViolenceScreenPK
GO
