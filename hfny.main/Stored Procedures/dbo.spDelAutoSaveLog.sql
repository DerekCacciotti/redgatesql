SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelAutoSaveLog](@AutoSaveLogPK int)

AS


DELETE 
FROM AutoSaveLog
WHERE AutoSaveLogPK = @AutoSaveLogPK
GO
