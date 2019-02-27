SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddscoreASQ](@ASQVersion varchar(10)=NULL,
@CommunicationScore numeric(4, 2)=NULL,
@FineMotorScore numeric(4, 2)=NULL,
@GrossMotorScore numeric(4, 2)=NULL,
@MaximumASQScore numeric(3, 0)=NULL,
@PersonalScore numeric(4, 2)=NULL,
@ProblemSolvingScore numeric(4, 2)=NULL,
@TCAge char(4)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) scoreASQPK
FROM scoreASQ lastRow
WHERE 
@ASQVersion = lastRow.ASQVersion AND
@CommunicationScore = lastRow.CommunicationScore AND
@FineMotorScore = lastRow.FineMotorScore AND
@GrossMotorScore = lastRow.GrossMotorScore AND
@MaximumASQScore = lastRow.MaximumASQScore AND
@PersonalScore = lastRow.PersonalScore AND
@ProblemSolvingScore = lastRow.ProblemSolvingScore AND
@TCAge = lastRow.TCAge
ORDER BY scoreASQPK DESC) 
BEGIN
INSERT INTO scoreASQ(
ASQVersion,
CommunicationScore,
FineMotorScore,
GrossMotorScore,
MaximumASQScore,
PersonalScore,
ProblemSolvingScore,
TCAge
)
VALUES(
@ASQVersion,
@CommunicationScore,
@FineMotorScore,
@GrossMotorScore,
@MaximumASQScore,
@PersonalScore,
@ProblemSolvingScore,
@TCAge
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
