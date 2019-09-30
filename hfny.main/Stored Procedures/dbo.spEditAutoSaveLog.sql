SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAutoSaveLog](@AutoSaveLogPK int=NULL,
@AutoSaveDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL)
AS
UPDATE AutoSaveLog
SET 
AutoSaveDate = @AutoSaveDate, 
FormFK = @FormFK, 
FormType = @FormType
WHERE AutoSaveLogPK = @AutoSaveLogPK
GO
