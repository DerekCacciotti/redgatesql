SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeLevel](@CaseWeight numeric(4, 2)=NULL,
@Enrolled bit=NULL,
@LevelGroup char(10)=NULL,
@LevelName char(30)=NULL,
@MaximumVisit numeric(2, 0)=NULL,
@MinimumVisit numeric(2, 0)=NULL)
AS
INSERT INTO codeLevel(
CaseWeight,
Enrolled,
LevelGroup,
LevelName,
MaximumVisit,
MinimumVisit
)
VALUES(
@CaseWeight,
@Enrolled,
@LevelGroup,
@LevelName,
@MaximumVisit,
@MinimumVisit
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
