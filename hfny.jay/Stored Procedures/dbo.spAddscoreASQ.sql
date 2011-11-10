SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddscoreASQ](@AgeInterval int=NULL,
@ASQVersion varchar(10)=NULL,
@CommunicationScore numeric(4, 2)=NULL,
@FineMotorScore numeric(4, 2)=NULL,
@GrossMotorScore numeric(4, 2)=NULL,
@MaximumASQScore numeric(3, 0)=NULL,
@MaximumASQSEScore numeric(3, 0)=NULL,
@PersonalScore numeric(4, 2)=NULL,
@ProblemSolvingScore numeric(4, 2)=NULL,
@SocialEmotionalScore numeric(6, 2)=NULL,
@TCAge char(4)=NULL)
AS
INSERT INTO scoreASQ(
AgeInterval,
ASQVersion,
CommunicationScore,
FineMotorScore,
GrossMotorScore,
MaximumASQScore,
MaximumASQSEScore,
PersonalScore,
ProblemSolvingScore,
SocialEmotionalScore,
TCAge
)
VALUES(
@AgeInterval,
@ASQVersion,
@CommunicationScore,
@FineMotorScore,
@GrossMotorScore,
@MaximumASQScore,
@MaximumASQSEScore,
@PersonalScore,
@ProblemSolvingScore,
@SocialEmotionalScore,
@TCAge
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
