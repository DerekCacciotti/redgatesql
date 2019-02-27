SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseFilterName](@FieldTitle varchar(50)=NULL,
@FilterType char(2)=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL,
@Inactive bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listCaseFilterNamePK
FROM listCaseFilterName lastRow
WHERE 
@FieldTitle = lastRow.FieldTitle AND
@FilterType = lastRow.FilterType AND
@Hint = lastRow.Hint AND
@ProgramFK = lastRow.ProgramFK AND
@Inactive = lastRow.Inactive
ORDER BY listCaseFilterNamePK DESC) 
BEGIN
INSERT INTO listCaseFilterName(
FieldTitle,
FilterType,
Hint,
ProgramFK,
Inactive
)
VALUES(
@FieldTitle,
@FilterType,
@Hint,
@ProgramFK,
@Inactive
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
