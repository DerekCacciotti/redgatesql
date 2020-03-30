SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeApp](@AppCode char(2)=NULL,
@AppCodeGroup varchar(50)=NULL,
@AppCodeText varchar(100)=NULL,
@AppCodeUsedWhere varchar(50)=NULL,
@OrderBy int=NULL,
@AppCodeSubGroup varchar(50)=NULL)
AS
INSERT INTO codeApp(
AppCode,
AppCodeGroup,
AppCodeText,
AppCodeUsedWhere,
OrderBy,
AppCodeSubGroup
)
VALUES(
@AppCode,
@AppCodeGroup,
@AppCodeText,
@AppCodeUsedWhere,
@OrderBy,
@AppCodeSubGroup
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
