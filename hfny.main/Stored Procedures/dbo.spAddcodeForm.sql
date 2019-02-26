SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeForm](@FormPKName varchar(20)=NULL,
@canBeReviewed bit=NULL,
@codeFormAbbreviation char(2)=NULL,
@codeFormName varchar(50)=NULL,
@CreatorFieldName varchar(40)=NULL,
@FormDateName varchar(20)=NULL,
@MainTableName varchar(20)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeFormPK
FROM codeForm lastRow
WHERE 
@FormPKName = lastRow.FormPKName AND
@canBeReviewed = lastRow.canBeReviewed AND
@codeFormAbbreviation = lastRow.codeFormAbbreviation AND
@codeFormName = lastRow.codeFormName AND
@CreatorFieldName = lastRow.CreatorFieldName AND
@FormDateName = lastRow.FormDateName AND
@MainTableName = lastRow.MainTableName
ORDER BY codeFormPK DESC) 
BEGIN
INSERT INTO codeForm(
FormPKName,
canBeReviewed,
codeFormAbbreviation,
codeFormName,
CreatorFieldName,
FormDateName,
MainTableName
)
VALUES(
@FormPKName,
@canBeReviewed,
@codeFormAbbreviation,
@codeFormName,
@CreatorFieldName,
@FormDateName,
@MainTableName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
