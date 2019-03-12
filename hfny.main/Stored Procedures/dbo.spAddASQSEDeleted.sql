SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddASQSEDeleted](@ASQSEPK int=NULL,
@ASQSECreator varchar(max)=NULL,
@ASQSEDateCompleted datetime=NULL,
@ASQSEDeleteDate datetime=NULL,
@ASQSEDeleter varchar(max)=NULL,
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
IF NOT EXISTS (SELECT TOP(1) ASQSEDeletedPK
FROM ASQSEDeleted lastRow
WHERE 
@ASQSEPK = lastRow.ASQSEPK AND
@ASQSECreator = lastRow.ASQSECreator AND
@ASQSEDateCompleted = lastRow.ASQSEDateCompleted AND
@ASQSEDeleteDate = lastRow.ASQSEDeleteDate AND
@ASQSEDeleter = lastRow.ASQSEDeleter AND
@ASQSEInWindow = lastRow.ASQSEInWindow AND
@ASQSEOverCutOff = lastRow.ASQSEOverCutOff AND
@ASQSEReceiving = lastRow.ASQSEReceiving AND
@ASQSEReferred = lastRow.ASQSEReferred AND
@ASQSETCAge = lastRow.ASQSETCAge AND
@ASQSETotalScore = lastRow.ASQSETotalScore AND
@ASQSEVersion = lastRow.ASQSEVersion AND
@DiscussedWithPC1 = lastRow.DiscussedWithPC1 AND
@FSWFK = lastRow.FSWFK AND
@ReviewCDS = lastRow.ReviewCDS AND
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK AND
@TCIDFK = lastRow.TCIDFK
ORDER BY ASQSEDeletedPK DESC) 
BEGIN
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

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
