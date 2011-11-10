SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditIntake](@IntakePK int=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@IntakeDate datetime=NULL,
@IntakeEditdate datetime=NULL,
@IntakeEditor char(10)=NULL,
@ProgramFK int=NULL)
AS
UPDATE Intake
SET 
FSWFK = @FSWFK, 
HVCaseFK = @HVCaseFK, 
IntakeDate = @IntakeDate, 
IntakeEditdate = @IntakeEditdate, 
IntakeEditor = @IntakeEditor, 
ProgramFK = @ProgramFK
WHERE IntakePK = @IntakePK
GO
