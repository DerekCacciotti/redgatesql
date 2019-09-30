SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetAutoSaveLogbyPK]

(@AutoSaveLogPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM AutoSaveLog
WHERE AutoSaveLogPK = @AutoSaveLogPK
GO
