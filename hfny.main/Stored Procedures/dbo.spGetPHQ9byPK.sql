SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPHQ9byPK]

(@PHQ9PK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM PHQ9
WHERE PHQ9PK = @PHQ9PK
GO
