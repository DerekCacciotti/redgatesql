SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPSI](@PSIPK int=NULL,
@DefensiveRespondingScore numeric(4, 0)=NULL,
@DifficultChildScore numeric(4, 0)=NULL,
@DifficultChildScoreMValid numeric(2, 0)=NULL,
@DifficultChildValid bit=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@ParentalDistressScore numeric(4, 0)=NULL,
@ParentalDistressScoreMValid numeric(2, 0)=NULL,
@ParentalDistressValid bit=NULL,
@ParentChildDisfunctionalInteractionScore numeric(4, 0)=NULL,
@ParentChildDysfunctionalInteractionScoreMValid numeric(2, 0)=NULL,
@ParentChildDysfunctionalInteractionValid bit=NULL,
@ProgramFK int=NULL,
@PSIDateComplete datetime=NULL,
@PSIEditor char(10)=NULL,
@PSIInterval char(2)=NULL,
@PSIInWindow bit=NULL,
@PSILanguage char(1)=NULL,
@PSIQ1 int=NULL,
@PSIQ2 int=NULL,
@PSIQ3 int=NULL,
@PSIQ4 int=NULL,
@PSIQ5 int=NULL,
@PSIQ6 int=NULL,
@PSIQ7 int=NULL,
@PSIQ8 int=NULL,
@PSIQ9 int=NULL,
@PSIQ10 int=NULL,
@PSIQ11 int=NULL,
@PSIQ12 int=NULL,
@PSIQ13 int=NULL,
@PSIQ14 int=NULL,
@PSIQ15 int=NULL,
@PSIQ16 int=NULL,
@PSIQ17 int=NULL,
@PSIQ18 int=NULL,
@PSIQ19 int=NULL,
@PSIQ20 int=NULL,
@PSIQ21 int=NULL,
@PSIQ22 int=NULL,
@PSIQ23 int=NULL,
@PSIQ24 int=NULL,
@PSIQ25 int=NULL,
@PSIQ26 int=NULL,
@PSIQ27 int=NULL,
@PSIQ28 int=NULL,
@PSIQ29 int=NULL,
@PSIQ30 int=NULL,
@PSIQ31 int=NULL,
@PSIQ32 int=NULL,
@PSIQ33 int=NULL,
@PSIQ34 int=NULL,
@PSIQ35 int=NULL,
@PSIQ36 int=NULL,
@PSITotalScore numeric(4, 0)=NULL,
@PSITotalScoreValid bit=NULL)
AS
UPDATE PSI
SET 
DefensiveRespondingScore = @DefensiveRespondingScore, 
DifficultChildScore = @DifficultChildScore, 
DifficultChildScoreMValid = @DifficultChildScoreMValid, 
DifficultChildValid = @DifficultChildValid, 
FSWFK = @FSWFK, 
HVCaseFK = @HVCaseFK, 
ParentalDistressScore = @ParentalDistressScore, 
ParentalDistressScoreMValid = @ParentalDistressScoreMValid, 
ParentalDistressValid = @ParentalDistressValid, 
ParentChildDisfunctionalInteractionScore = @ParentChildDisfunctionalInteractionScore, 
ParentChildDysfunctionalInteractionScoreMValid = @ParentChildDysfunctionalInteractionScoreMValid, 
ParentChildDysfunctionalInteractionValid = @ParentChildDysfunctionalInteractionValid, 
ProgramFK = @ProgramFK, 
PSIDateComplete = @PSIDateComplete, 
PSIEditor = @PSIEditor, 
PSIInterval = @PSIInterval, 
PSIInWindow = @PSIInWindow, 
PSILanguage = @PSILanguage, 
PSIQ1 = @PSIQ1, 
PSIQ2 = @PSIQ2, 
PSIQ3 = @PSIQ3, 
PSIQ4 = @PSIQ4, 
PSIQ5 = @PSIQ5, 
PSIQ6 = @PSIQ6, 
PSIQ7 = @PSIQ7, 
PSIQ8 = @PSIQ8, 
PSIQ9 = @PSIQ9, 
PSIQ10 = @PSIQ10, 
PSIQ11 = @PSIQ11, 
PSIQ12 = @PSIQ12, 
PSIQ13 = @PSIQ13, 
PSIQ14 = @PSIQ14, 
PSIQ15 = @PSIQ15, 
PSIQ16 = @PSIQ16, 
PSIQ17 = @PSIQ17, 
PSIQ18 = @PSIQ18, 
PSIQ19 = @PSIQ19, 
PSIQ20 = @PSIQ20, 
PSIQ21 = @PSIQ21, 
PSIQ22 = @PSIQ22, 
PSIQ23 = @PSIQ23, 
PSIQ24 = @PSIQ24, 
PSIQ25 = @PSIQ25, 
PSIQ26 = @PSIQ26, 
PSIQ27 = @PSIQ27, 
PSIQ28 = @PSIQ28, 
PSIQ29 = @PSIQ29, 
PSIQ30 = @PSIQ30, 
PSIQ31 = @PSIQ31, 
PSIQ32 = @PSIQ32, 
PSIQ33 = @PSIQ33, 
PSIQ34 = @PSIQ34, 
PSIQ35 = @PSIQ35, 
PSIQ36 = @PSIQ36, 
PSITotalScore = @PSITotalScore, 
PSITotalScoreValid = @PSITotalScoreValid
WHERE PSIPK = @PSIPK
GO
