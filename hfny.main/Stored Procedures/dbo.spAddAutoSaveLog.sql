SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAutoSaveLog](@AutoSaveDate datetime=NULL,
@AutoSaveCreator varchar(max)=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL)
AS
INSERT INTO AutoSaveLog(
AutoSaveDate,
AutoSaveCreator,
FormFK,
FormType
)
VALUES(
@AutoSaveDate,
@AutoSaveCreator,
@FormFK,
@FormType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
