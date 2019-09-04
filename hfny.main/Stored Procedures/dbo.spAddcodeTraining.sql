SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTraining](@ProgramFK int=NULL,
@TrainingCode char(2)=NULL,
@TrainingCodeDescription char(40)=NULL,
@TrainingCodeGroup char(20)=NULL,
@TrainingCodeUsedWhere varchar(50)=NULL)
AS
INSERT INTO codeTraining(
ProgramFK,
TrainingCode,
TrainingCodeDescription,
TrainingCodeGroup,
TrainingCodeUsedWhere
)
VALUES(
@ProgramFK,
@TrainingCode,
@TrainingCodeDescription,
@TrainingCodeGroup,
@TrainingCodeUsedWhere
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
