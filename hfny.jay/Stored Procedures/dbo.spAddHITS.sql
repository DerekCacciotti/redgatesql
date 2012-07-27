SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHITS](@FormFK int=NULL,
@FormInterval char(2)=NULL,
@HITSCreator char(10)=NULL,
@HVCaseFK int=NULL,
@Invalid bit=NULL,
@Positive bit=NULL,
@TotalScore int=NULL,
@Hurt char(2)=NULL,
@Insult char(2)=NULL,
@NotDoneReason char(2)=NULL,
@ProgramFK nchar(10)=NULL,
@Scream char(2)=NULL,
@Threaten char(2)=NULL)
AS
INSERT INTO HITS(
FormFK,
FormInterval,
HITSCreator,
HVCaseFK,
Invalid,
Positive,
TotalScore,
Hurt,
Insult,
NotDoneReason,
ProgramFK,
Scream,
Threaten
)
VALUES(
@FormFK,
@FormInterval,
@HITSCreator,
@HVCaseFK,
@Invalid,
@Positive,
@TotalScore,
@Hurt,
@Insult,
@NotDoneReason,
@ProgramFK,
@Scream,
@Threaten
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
