SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditUNCOPE](@UNCOPEPK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@FSWFK int=NULL,
@UNCOPEDate datetime=NULL,
@Used int=NULL,
@Neglected int=NULL,
@CutDown int=NULL,
@Objected int=NULL,
@Preoccupied int=NULL,
@EmotionalDiscomfort int=NULL,
@Score int=NULL,
@UNCOPEEditor varchar(max)=NULL)
AS
UPDATE UNCOPE
SET 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
FSWFK = @FSWFK, 
UNCOPEDate = @UNCOPEDate, 
Used = @Used, 
Neglected = @Neglected, 
CutDown = @CutDown, 
Objected = @Objected, 
Preoccupied = @Preoccupied, 
EmotionalDiscomfort = @EmotionalDiscomfort, 
Score = @Score, 
UNCOPEEditor = @UNCOPEEditor
WHERE UNCOPEPK = @UNCOPEPK
GO
