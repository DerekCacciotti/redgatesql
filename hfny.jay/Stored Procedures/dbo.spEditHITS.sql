
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHITS](@HITSPK int=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HITSEditor char(10)=NULL,
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
UPDATE HITS
SET 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
FormType = @FormType, 
HITSEditor = @HITSEditor, 
HVCaseFK = @HVCaseFK, 
Invalid = @Invalid, 
Positive = @Positive, 
TotalScore = @TotalScore, 
Hurt = @Hurt, 
Insult = @Insult, 
NotDoneReason = @NotDoneReason, 
ProgramFK = @ProgramFK, 
Scream = @Scream, 
Threaten = @Threaten
WHERE HITSPK = @HITSPK
GO
