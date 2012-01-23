
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
@MinimumVisit numeric(4, 2)=NULL)
AS
INSERT INTO codeLevel(
CaseWeight,
ConstantName,
Enrolled,
LevelGroup,
LevelName,
MaximumVisit,
MinimumVisit
)
VALUES(
@CaseWeight,
@ConstantName,
@Enrolled,
@LevelGroup,
@LevelName,
@MaximumVisit,
@MinimumVisit
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
