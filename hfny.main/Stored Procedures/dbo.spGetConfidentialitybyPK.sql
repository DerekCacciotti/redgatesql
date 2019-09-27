SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetConfidentialitybyPK]

(@ConfidentialityPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Confidentiality
WHERE ConfidentialityPK = @ConfidentialityPK
GO
