SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddASQSEDeleted](@ASQSEPK int=NULL,
@ASQSECreator char(10)=NULL,
@ASQSEDateCompleted datetime=NULL,
@ASQSEDeleteDate datetime=NULL,
@ASQSEDeleter char(10)=NULL,
@ASQSEInWindow bit=NULL,
@ASQSEOverCutOff bit=NULL,
@ASQSEReceiving char(1)=NULL,
@ASQSEReferred char(1)=NULL,
@ASQSETCAge char(2)=NULL,
@ASQSETotalScore numeric(4, 1)=NULL,
@ASQSEVersion varchar(10)=NULL,
@DiscussedWithPC1 bit=NULL,
@FSWFK int=NULL,
@ReviewCDS bit=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@TCIDFK int=NULL)
AS
INSERT INTO ASQSEDeleted(
ASQSEPK,
ASQSECreator,
ASQSEDateCompleted,
ASQSEDeleteDate,
ASQSEDeleter,
ASQSEInWindow,
ASQSEOverCutOff,
ASQSEReceiving,
ASQSEReferred,
ASQSETCAge,
ASQSETotalScore,
ASQSEVersion,
DiscussedWithPC1,
FSWFK,
ReviewCDS,
HVCaseFK,
ProgramFK,
TCIDFK
)
VALUES(
@ASQSEPK,
@ASQSECreator,
@ASQSEDateCompleted,
@ASQSEDeleteDate,
@ASQSEDeleter,
@ASQSEInWindow,
@ASQSEOverCutOff,
@ASQSEReceiving,
@ASQSEReferred,
@ASQSETCAge,
@ASQSETotalScore,
@ASQSEVersion,
@DiscussedWithPC1,
@FSWFK,
@ReviewCDS,
@HVCaseFK,
@ProgramFK,
@TCIDFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
