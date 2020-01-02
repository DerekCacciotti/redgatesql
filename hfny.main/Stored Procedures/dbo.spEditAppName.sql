SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAppName](@AppNamePK int=NULL,
@Name varchar(50)=NULL)
AS
UPDATE AppName
SET 
Name = @Name
WHERE AppNamePK = @AppNamePK
GO
