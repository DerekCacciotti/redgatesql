SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddASQSE](@ASQSECreator char(10)=NULL,
@ASQSEDateCompleted datetime=NULL,
@ASQSEInWindow bit=NULL,
@ASQSEOverCutOff bit=NULL,
@ASQSEReceiving char(1)=NULL,
@ASQSEReferred char(1)=NULL,
@ASQSETCAge char(2)=NULL,
@ASQSETotalScore numeric(3, 0)=NULL,
@ASQSEVersion varchar(10)=NULL,
@DiscussedWithPC1 bit=NULL,
@FSWFK int=NULL,
@ReviewCDS bit=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@TCIDFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) ASQSEPK
FROM ASQSE lastRow
WHERE 
@ASQSECreator = lastRow.ASQSECreator AND
@ASQSEDateCompleted = lastRow.ASQSEDateCompleted AND
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
ORDER BY ASQSEPK DESC) 
BEGIN
INSERT INTO ASQSE(
ASQSECreator,
ASQSEDateCompleted,
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
@ASQSECreator,
@ASQSEDateCompleted,
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
