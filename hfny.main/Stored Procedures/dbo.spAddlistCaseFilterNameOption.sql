SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseFilterNameOption](@CaseFilterNameFK int=NULL,
@FilterOption varchar(50)=NULL,
@FilterOptionCode varchar(50)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listCaseFilterNameOptionPK
FROM listCaseFilterNameOption lastRow
WHERE 
@CaseFilterNameFK = lastRow.CaseFilterNameFK AND
@FilterOption = lastRow.FilterOption AND
@FilterOptionCode = lastRow.FilterOptionCode
ORDER BY listCaseFilterNameOptionPK DESC) 
BEGIN
INSERT INTO listCaseFilterNameOption(
CaseFilterNameFK,
FilterOption,
FilterOptionCode
)
VALUES(
@CaseFilterNameFK,
@FilterOption,
@FilterOptionCode
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
