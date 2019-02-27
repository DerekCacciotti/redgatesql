SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTraining](@codeTrainingPK_old int=NULL,
@ProgramFK int=NULL,
@TrainingCode char(2)=NULL,
@TrainingCodeDescription char(40)=NULL,
@TrainingCodeGroup char(20)=NULL,
@TrainingCodeUsedWhere varchar(50)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeTrainingPK
FROM codeTraining lastRow
WHERE 
@codeTrainingPK_old = lastRow.codeTrainingPK_old AND
@ProgramFK = lastRow.ProgramFK AND
@TrainingCode = lastRow.TrainingCode AND
@TrainingCodeDescription = lastRow.TrainingCodeDescription AND
@TrainingCodeGroup = lastRow.TrainingCodeGroup AND
@TrainingCodeUsedWhere = lastRow.TrainingCodeUsedWhere
ORDER BY codeTrainingPK DESC) 
BEGIN
INSERT INTO codeTraining(
codeTrainingPK_old,
ProgramFK,
TrainingCode,
TrainingCodeDescription,
TrainingCodeGroup,
TrainingCodeUsedWhere
)
VALUES(
@codeTrainingPK_old,
@ProgramFK,
@TrainingCode,
@TrainingCodeDescription,
@TrainingCodeGroup,
@TrainingCodeUsedWhere
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
