SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelLoginHistory](@LoginHistoryPK int)

AS


DELETE 
FROM LoginHistory
WHERE LoginHistoryPK = @LoginHistoryPK
GO
