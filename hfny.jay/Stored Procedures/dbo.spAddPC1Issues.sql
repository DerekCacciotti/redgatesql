SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC1Issues](@AlcoholAbuse char(1)=NULL,
@CriminalActivity char(1)=NULL,
@Depression char(1)=NULL,
@DomesticViolence char(1)=NULL,
@FinancialDifficulty char(1)=NULL,
@Homeless char(1)=NULL,
@HVCaseFK int=NULL,
@InadequateBasics char(1)=NULL,
@Interval char(2)=NULL,
@MaritalProblems char(1)=NULL,
@MentalIllness char(1)=NULL,
@OtherIssue char(1)=NULL,
@OtherIssueSpecify varchar(500)=NULL,
@PC1IssuesCreator char(10)=NULL,
@PC1IssuesDate datetime=NULL,
@PC1IssuesPK_old int=NULL,
@ProgramFK int=NULL,
@Smoking char(1)=NULL,
@SocialIsolation char(1)=NULL,
@Stress char(1)=NULL,
@SubstanceAbuse char(1)=NULL)
AS
INSERT INTO PC1Issues(
AlcoholAbuse,
CriminalActivity,
Depression,
DomesticViolence,
FinancialDifficulty,
Homeless,
HVCaseFK,
InadequateBasics,
Interval,
MaritalProblems,
MentalIllness,
OtherIssue,
OtherIssueSpecify,
PC1IssuesCreator,
PC1IssuesDate,
PC1IssuesPK_old,
ProgramFK,
Smoking,
SocialIsolation,
Stress,
SubstanceAbuse
)
VALUES(
@AlcoholAbuse,
@CriminalActivity,
@Depression,
@DomesticViolence,
@FinancialDifficulty,
@Homeless,
@HVCaseFK,
@InadequateBasics,
@Interval,
@MaritalProblems,
@MentalIllness,
@OtherIssue,
@OtherIssueSpecify,
@PC1IssuesCreator,
@PC1IssuesDate,
@PC1IssuesPK_old,
@ProgramFK,
@Smoking,
@SocialIsolation,
@Stress,
@SubstanceAbuse
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
