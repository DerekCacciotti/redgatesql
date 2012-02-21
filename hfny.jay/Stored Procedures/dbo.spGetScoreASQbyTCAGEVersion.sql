SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[spGetScoreASQbyTCAGEVersion]
@TCAge char(2) = NULL, @ASQVersion varchar(10)=NULL

AS
BEGIN
SET NOCOUNT ON;


SELECT AgeInterval , 
ASQVersion, 
CommunicationScore, 
FineMotorScore, 
GrossMotorScore, 
PersonalScore, 
ProblemSolvingScore, 
scoreASQPK, 
SocialEmotionalScore, 
TCAge,
MaximumASQSEScore,
MaximumASQScore 
FROM scoreASQ
WHERE TCAge = @TCAge and ASQVersion = @ASQVersion

END
GO
