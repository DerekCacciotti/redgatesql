SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionDeletedbyPK]

(@SupervisionDeletedPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionDeleted
WHERE SupervisionDeletedPK = @SupervisionDeletedPK
GO
