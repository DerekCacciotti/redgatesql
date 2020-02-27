SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeApp](@codeAppPK int=NULL,
@AppCode char(2)=NULL,
@AppCodeGroup varchar(50)=NULL,
@AppCodeText varchar(100)=NULL,
@AppCodeUsedWhere varchar(50)=NULL,
@OrderBy int=NULL,
@AppCodeSubGroup varchar(50)=NULL)
AS
UPDATE codeApp
SET 
AppCode = @AppCode, 
AppCodeGroup = @AppCodeGroup, 
AppCodeText = @AppCodeText, 
AppCodeUsedWhere = @AppCodeUsedWhere, 
OrderBy = @OrderBy, 
AppCodeSubGroup = @AppCodeSubGroup
WHERE codeAppPK = @codeAppPK
GO
