SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionOldbyPK]

(@SupervisionOldPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionOld
WHERE SupervisionOldPK = @SupervisionOldPK
GO
