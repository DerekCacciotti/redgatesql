SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCheersCheckIn](@CheersCheckInPK int)

AS


DELETE 
FROM CheersCheckIn
WHERE CheersCheckInPK = @CheersCheckInPK
GO
