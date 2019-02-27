SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddASQDeleted](@ASQPK int=NULL,
@ASQCreator char(10)=NULL,
@ProgramFK int=NULL,
@ASQCommunicationScore numeric(4, 1)=NULL,
@ASQDeleteDate datetime=NULL,
@ASQDeleter char(10)=NULL,
@ASQFineMotorScore numeric(4, 1)=NULL,
@ASQGrossMotorScore numeric(4, 1)=NULL,
@ASQInWindow bit=NULL,
@ASQPersonalSocialScore numeric(4, 1)=NULL,
@ASQProblemSolvingScore numeric(4, 1)=NULL,
@ASQTCReceiving char(1)=NULL,
@DateCompleted datetime=NULL,
@DevServicesStartDate date=NULL,
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
IF NOT EXISTS (SELECT TOP(1) ASQDeletedPK
FROM ASQDeleted lastRow
WHERE 
@ASQPK = lastRow.ASQPK AND
@ASQCreator = lastRow.ASQCreator AND
@ProgramFK = lastRow.ProgramFK AND
@ASQCommunicationScore = lastRow.ASQCommunicationScore AND
@ASQDeleteDate = lastRow.ASQDeleteDate AND
@ASQDeleter = lastRow.ASQDeleter AND
@ASQFineMotorScore = lastRow.ASQFineMotorScore AND
@ASQGrossMotorScore = lastRow.ASQGrossMotorScore AND
@ASQInWindow = lastRow.ASQInWindow AND
@ASQPersonalSocialScore = lastRow.ASQPersonalSocialScore AND
@ASQProblemSolvingScore = lastRow.ASQProblemSolvingScore AND
@ASQTCReceiving = lastRow.ASQTCReceiving AND
@DateCompleted = lastRow.DateCompleted AND
@DevServicesStartDate = lastRow.DevServicesStartDate AND
@DiscussedWithPC1 = lastRow.DiscussedWithPC1 AND
@FSWFK = lastRow.FSWFK AND
@HVCaseFK = lastRow.HVCaseFK AND
@ReviewCDS = lastRow.ReviewCDS AND
@TCAge = lastRow.TCAge AND
@TCIDFK = lastRow.TCIDFK AND
@TCReferred = lastRow.TCReferred AND
@UnderCommunication = lastRow.UnderCommunication AND
@UnderFineMotor = lastRow.UnderFineMotor AND
@UnderGrossMotor = lastRow.UnderGrossMotor AND
@UnderPersonalSocial = lastRow.UnderPersonalSocial AND
@UnderProblemSolving = lastRow.UnderProblemSolving AND
@VersionNumber = lastRow.VersionNumber
ORDER BY ASQDeletedPK DESC) 
BEGIN
INSERT INTO ASQDeleted(
ASQPK,
ASQCreator,
ProgramFK,
ASQCommunicationScore,
ASQDeleteDate,
ASQDeleter,
ASQFineMotorScore,
ASQGrossMotorScore,
ASQInWindow,
ASQPersonalSocialScore,
ASQProblemSolvingScore,
ASQTCReceiving,
DateCompleted,
DevServicesStartDate,
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
@ASQPK,
@ASQCreator,
@ProgramFK,
@ASQCommunicationScore,
@ASQDeleteDate,
@ASQDeleter,
@ASQFineMotorScore,
@ASQGrossMotorScore,
@ASQInWindow,
@ASQPersonalSocialScore,
@ASQProblemSolvingScore,
@ASQTCReceiving,
@DateCompleted,
@DevServicesStartDate,
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

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
