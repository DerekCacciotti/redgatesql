
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTraining](@ProgramFK int=NULL,
@TrainerFK int=NULL,
@TrainingCreator char(10)=NULL,
@TrainingDate datetime=NULL,
@TrainingDays int=NULL,
@TrainingDescription varchar(500)=NULL,
@TrainingDuration int=NULL,
@TrainingHours int=NULL,
@TrainingMinutes int=NULL,
@TrainingTitle char(70)=NULL,
@TrainingMethodFK int=NULL,
@IsExempt bit=NULL)
AS
INSERT INTO Training(
ProgramFK,
TrainerFK,
TrainingCreator,
TrainingDate,
TrainingDays,
TrainingDescription,
TrainingDuration,
TrainingHours,
TrainingMinutes,
TrainingTitle,
TrainingMethodFK,
IsExempt
)
VALUES(
@ProgramFK,
@TrainerFK,
@TrainingCreator,
@TrainingDate,
@TrainingDays,
@TrainingDescription,
@TrainingDuration,
@TrainingHours,
@TrainingMinutes,
@TrainingTitle,
@TrainingMethodFK,
@IsExempt
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
