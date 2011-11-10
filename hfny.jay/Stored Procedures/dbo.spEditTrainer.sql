SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainer](@TrainerPK int=NULL,
@ProgramFK int=NULL,
@TrainerEditor char(10)=NULL,
@TrainerFirstName char(20)=NULL,
@TrainerLastName char(30)=NULL,
@TrainerOrganization char(30)=NULL,
@TrainerPK_old int=NULL,
@TrainingMethodName char(40)=NULL,
@TrainingMethodType char(2)=NULL)
AS
UPDATE Trainer
SET 
ProgramFK = @ProgramFK, 
TrainerEditor = @TrainerEditor, 
TrainerFirstName = @TrainerFirstName, 
TrainerLastName = @TrainerLastName, 
TrainerOrganization = @TrainerOrganization, 
TrainerPK_old = @TrainerPK_old, 
TrainingMethodName = @TrainingMethodName, 
TrainingMethodType = @TrainingMethodType
WHERE TrainerPK = @TrainerPK
GO
