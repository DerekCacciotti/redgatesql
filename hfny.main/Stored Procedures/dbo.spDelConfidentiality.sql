SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelConfidentiality](@ConfidentialityPK int)

AS


DELETE 
FROM Confidentiality
WHERE ConfidentialityPK = @ConfidentialityPK
GO
