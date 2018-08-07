SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCheersCheckInbyPK]

(@CheersCheckInPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CheersCheckIn
WHERE CheersCheckInPK = @CheersCheckInPK
GO
