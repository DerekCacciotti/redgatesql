SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditConfidentiality](@ConfidentialityPK int=NULL,
@Username varchar(max)=NULL,
@AcceptDate datetime=NULL)
AS
UPDATE Confidentiality
SET 
Username = @Username, 
AcceptDate = @AcceptDate
WHERE ConfidentialityPK = @ConfidentialityPK
GO
