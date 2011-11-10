SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTraining](@TrainingPK int=NULL,
@ProgramFK int=NULL,
@TrainerFK int=NULL,
@TrainingDate datetime=NULL,
@TrainingDays int=NULL,
@TrainingDescription varchar(500)=NULL,
@TrainingDuration int=NULL,
@TrainingEditor char(10)=NULL,
@TrainingHours int=NULL,
@TrainingMinutes int=NULL,
@TrainingPK_old int=NULL,
@TrainingTitle char(70)=NULL)
AS
UPDATE Training
SET 
ProgramFK = @ProgramFK, 
TrainerFK = @TrainerFK, 
TrainingDate = @TrainingDate, 
TrainingDays = @TrainingDays, 
TrainingDescription = @TrainingDescription, 
TrainingDuration = @TrainingDuration, 
TrainingEditor = @TrainingEditor, 
TrainingHours = @TrainingHours, 
TrainingMinutes = @TrainingMinutes, 
TrainingPK_old = @TrainingPK_old, 
TrainingTitle = @TrainingTitle
WHERE TrainingPK = @TrainingPK
GO
