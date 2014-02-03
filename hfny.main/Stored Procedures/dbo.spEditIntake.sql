
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
@ProgramFK int=NULL,
@MIECHV_Race_AmericanIndian bit=NULL,
@MIECHV_Race_Asian bit=NULL,
@MIECHV_Race_Black bit=NULL,
@MIECHV_Race_Hawaiian bit=NULL,
@MIECHV_Race_White bit=NULL,
@MIECHV_Hispanic nvarchar(1)=NULL)
AS
UPDATE Intake
SET 
FSWFK = @FSWFK, 
HVCaseFK = @HVCaseFK, 
IntakeDate = @IntakeDate, 
IntakeEditdate = @IntakeEditdate, 
IntakeEditor = @IntakeEditor, 
ProgramFK = @ProgramFK, 
MIECHV_Race_AmericanIndian = @MIECHV_Race_AmericanIndian, 
MIECHV_Race_Asian = @MIECHV_Race_Asian, 
MIECHV_Race_Black = @MIECHV_Race_Black, 
MIECHV_Race_Hawaiian = @MIECHV_Race_Hawaiian, 
MIECHV_Race_White = @MIECHV_Race_White, 
MIECHV_Hispanic = @MIECHV_Hispanic
WHERE IntakePK = @IntakePK
GO
