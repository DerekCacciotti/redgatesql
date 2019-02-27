SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHITS](@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HITSCreator char(10)=NULL,
@Hurt char(2)=NULL,
@HVCaseFK int=NULL,
@Insult char(2)=NULL,
@Invalid bit=NULL,
@NotDoneReason char(2)=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@Scream char(2)=NULL,
@Threaten char(2)=NULL,
@TotalScore int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HITSPK
FROM HITS lastRow
WHERE 
@FormFK = lastRow.FormFK AND
@FormInterval = lastRow.FormInterval AND
@FormType = lastRow.FormType AND
@HITSCreator = lastRow.HITSCreator AND
@Hurt = lastRow.Hurt AND
@HVCaseFK = lastRow.HVCaseFK AND
@Insult = lastRow.Insult AND
@Invalid = lastRow.Invalid AND
@NotDoneReason = lastRow.NotDoneReason AND
@Positive = lastRow.Positive AND
@ProgramFK = lastRow.ProgramFK AND
@Scream = lastRow.Scream AND
@Threaten = lastRow.Threaten AND
@TotalScore = lastRow.TotalScore
ORDER BY HITSPK DESC) 
BEGIN
INSERT INTO HITS(
FormFK,
FormInterval,
FormType,
HITSCreator,
Hurt,
HVCaseFK,
Insult,
Invalid,
NotDoneReason,
Positive,
ProgramFK,
Scream,
Threaten,
TotalScore
)
VALUES(
@FormFK,
@FormInterval,
@FormType,
@HITSCreator,
@Hurt,
@HVCaseFK,
@Insult,
@Invalid,
@NotDoneReason,
@Positive,
@ProgramFK,
@Scream,
@Threaten,
@TotalScore
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
