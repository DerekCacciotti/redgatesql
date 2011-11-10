SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainer](@ProgramFK int=NULL,
@TrainerCreator char(10)=NULL,
@TrainerFirstName char(20)=NULL,
@TrainerLastName char(30)=NULL,
@TrainerOrganization char(30)=NULL,
@TrainerPK_old int=NULL,
@TrainingMethodName char(40)=NULL,
@TrainingMethodType char(2)=NULL)
AS
INSERT INTO Trainer(
ProgramFK,
TrainerCreator,
TrainerFirstName,
TrainerLastName,
TrainerOrganization,
TrainerPK_old,
TrainingMethodName,
TrainingMethodType
)
VALUES(
@ProgramFK,
@TrainerCreator,
@TrainerFirstName,
@TrainerLastName,
@TrainerOrganization,
@TrainerPK_old,
@TrainingMethodName,
@TrainingMethodType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
