
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddASQ](@ASQCreator char(10)=NULL,
@ProgramFK int=NULL,
@ASQCommunicationScore numeric(4, 1)=NULL,
@ASQFineMotorScore numeric(4, 1)=NULL,
@ASQGrossMotorScore numeric(4, 1)=NULL,
@ASQInWindow bit=NULL,
@ASQPersonalSocialScore numeric(4, 1)=NULL,
@ASQProblemSolvingScore numeric(4, 1)=NULL,
@ASQTCReceiving char(1)=NULL,
@DateCompleted datetime=NULL,
@DiscussedWithPC1 bit=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@ReviewCDS bit=NULL,
@TCAge char(2)=NULL,
@TCIDFK int=NULL,
@TCReferred char(1)=NULL,
@UnderCommunication bit=NULL,
@UnderFineMotor bit=NULL,
@UnderGrossMotor bit=NULL,
@UnderPersonalSocial bit=NULL,
@UnderProblemSolving bit=NULL,
@VersionNumber varchar(10)=NULL)
AS
INSERT INTO ASQ(
ASQCreator,
ProgramFK,
ASQCommunicationScore,
ASQFineMotorScore,
ASQGrossMotorScore,
ASQInWindow,
ASQPersonalSocialScore,
ASQProblemSolvingScore,
ASQTCReceiving,
DateCompleted,
DiscussedWithPC1,
FSWFK,
HVCaseFK,
ReviewCDS,
TCAge,
TCIDFK,
TCReferred,
UnderCommunication,
UnderFineMotor,
UnderGrossMotor,
UnderPersonalSocial,
UnderProblemSolving,
VersionNumber
)
VALUES(
@ASQCreator,
@ProgramFK,
@ASQCommunicationScore,
@ASQFineMotorScore,
@ASQGrossMotorScore,
@ASQInWindow,
@ASQPersonalSocialScore,
@ASQProblemSolvingScore,
@ASQTCReceiving,
@DateCompleted,
@DiscussedWithPC1,
@FSWFK,
@HVCaseFK,
@ReviewCDS,
@TCAge,
@TCIDFK,
@TCReferred,
@UnderCommunication,
@UnderFineMotor,
@UnderGrossMotor,
@UnderPersonalSocial,
@UnderProblemSolving,
@VersionNumber
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
