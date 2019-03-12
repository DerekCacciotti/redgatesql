SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC1Issues](@AlcoholAbuse char(1)=NULL,
@CriminalActivity char(1)=NULL,
@Depression char(1)=NULL,
@DevelopmentalDisability char(1)=NULL,
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
@OtherLegalProblems char(1)=NULL,
@PC1IssuesCreator varchar(max)=NULL,
@PC1IssuesDate datetime=NULL,
@PC1IssuesPK_old int=NULL,
@PhysicalDisability char(1)=NULL,
@ProgramFK int=NULL,
@Smoking char(1)=NULL,
@SocialIsolation char(1)=NULL,
@Stress char(1)=NULL,
@SubstanceAbuse char(1)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PC1IssuesPK
FROM PC1Issues lastRow
WHERE 
@AlcoholAbuse = lastRow.AlcoholAbuse AND
@CriminalActivity = lastRow.CriminalActivity AND
@Depression = lastRow.Depression AND
@DevelopmentalDisability = lastRow.DevelopmentalDisability AND
@DomesticViolence = lastRow.DomesticViolence AND
@FinancialDifficulty = lastRow.FinancialDifficulty AND
@Homeless = lastRow.Homeless AND
@HVCaseFK = lastRow.HVCaseFK AND
@InadequateBasics = lastRow.InadequateBasics AND
@Interval = lastRow.Interval AND
@MaritalProblems = lastRow.MaritalProblems AND
@MentalIllness = lastRow.MentalIllness AND
@OtherIssue = lastRow.OtherIssue AND
@OtherIssueSpecify = lastRow.OtherIssueSpecify AND
@OtherLegalProblems = lastRow.OtherLegalProblems AND
@PC1IssuesCreator = lastRow.PC1IssuesCreator AND
@PC1IssuesDate = lastRow.PC1IssuesDate AND
@PC1IssuesPK_old = lastRow.PC1IssuesPK_old AND
@PhysicalDisability = lastRow.PhysicalDisability AND
@ProgramFK = lastRow.ProgramFK AND
@Smoking = lastRow.Smoking AND
@SocialIsolation = lastRow.SocialIsolation AND
@Stress = lastRow.Stress AND
@SubstanceAbuse = lastRow.SubstanceAbuse
ORDER BY PC1IssuesPK DESC) 
BEGIN
INSERT INTO PC1Issues(
AlcoholAbuse,
CriminalActivity,
Depression,
DevelopmentalDisability,
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
OtherLegalProblems,
PC1IssuesCreator,
PC1IssuesDate,
PC1IssuesPK_old,
PhysicalDisability,
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
@DevelopmentalDisability,
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
@OtherLegalProblems,
@PC1IssuesCreator,
@PC1IssuesDate,
@PC1IssuesPK_old,
@PhysicalDisability,
@ProgramFK,
@Smoking,
@SocialIsolation,
@Stress,
@SubstanceAbuse
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
