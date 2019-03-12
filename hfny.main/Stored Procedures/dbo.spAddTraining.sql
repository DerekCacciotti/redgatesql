SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTraining](@ProgramFK int=NULL,
@TrainerFK int=NULL,
@TrainingMethodFK int=NULL,
@TrainingCreator varchar(max)=NULL,
@TrainingDate datetime=NULL,
@TrainingDays int=NULL,
@TrainingDescription varchar(500)=NULL,
@TrainingDuration int=NULL,
@TrainingHours int=NULL,
@TrainingMinutes int=NULL,
@TrainingTitle char(70)=NULL,
@IsExempt bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TrainingPK
FROM Training lastRow
WHERE 
@ProgramFK = lastRow.ProgramFK AND
@TrainerFK = lastRow.TrainerFK AND
@TrainingMethodFK = lastRow.TrainingMethodFK AND
@TrainingCreator = lastRow.TrainingCreator AND
@TrainingDate = lastRow.TrainingDate AND
@TrainingDays = lastRow.TrainingDays AND
@TrainingDescription = lastRow.TrainingDescription AND
@TrainingDuration = lastRow.TrainingDuration AND
@TrainingHours = lastRow.TrainingHours AND
@TrainingMinutes = lastRow.TrainingMinutes AND
@TrainingTitle = lastRow.TrainingTitle AND
@IsExempt = lastRow.IsExempt
ORDER BY TrainingPK DESC) 
BEGIN
INSERT INTO Training(
ProgramFK,
TrainerFK,
TrainingMethodFK,
TrainingCreator,
TrainingDate,
TrainingDays,
TrainingDescription,
TrainingDuration,
TrainingHours,
TrainingMinutes,
TrainingTitle,
IsExempt
)
VALUES(
@ProgramFK,
@TrainerFK,
@TrainingMethodFK,
@TrainingCreator,
@TrainingDate,
@TrainingDays,
@TrainingDescription,
@TrainingDuration,
@TrainingHours,
@TrainingMinutes,
@TrainingTitle,
@IsExempt
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
