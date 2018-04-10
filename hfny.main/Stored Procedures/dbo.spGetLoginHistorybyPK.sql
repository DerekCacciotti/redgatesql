SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetLoginHistorybyPK]

(@LoginHistoryPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM LoginHistory
WHERE LoginHistoryPK = @LoginHistoryPK
GO
