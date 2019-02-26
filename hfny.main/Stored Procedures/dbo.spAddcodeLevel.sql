SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeLevel](@CaseWeight numeric(4, 2)=NULL,
@ConstantName varchar(50)=NULL,
@Enrolled bit=NULL,
@LevelGroup char(10)=NULL,
@LevelName varchar(50)=NULL,
@MaximumVisit numeric(4, 2)=NULL,
@MinimumVisit numeric(4, 2)=NULL,
@SubLevelFK int=NULL,
@LevelAbbr varchar(10)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeLevelPK
FROM codeLevel lastRow
WHERE 
@CaseWeight = lastRow.CaseWeight AND
@ConstantName = lastRow.ConstantName AND
@Enrolled = lastRow.Enrolled AND
@LevelGroup = lastRow.LevelGroup AND
@LevelName = lastRow.LevelName AND
@MaximumVisit = lastRow.MaximumVisit AND
@MinimumVisit = lastRow.MinimumVisit AND
@SubLevelFK = lastRow.SubLevelFK AND
@LevelAbbr = lastRow.LevelAbbr
ORDER BY codeLevelPK DESC) 
BEGIN
INSERT INTO codeLevel(
CaseWeight,
ConstantName,
Enrolled,
LevelGroup,
LevelName,
MaximumVisit,
MinimumVisit,
SubLevelFK,
LevelAbbr
)
VALUES(
@CaseWeight,
@ConstantName,
@Enrolled,
@LevelGroup,
@LevelName,
@MaximumVisit,
@MinimumVisit,
@SubLevelFK,
@LevelAbbr
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
