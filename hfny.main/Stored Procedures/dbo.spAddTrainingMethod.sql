SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingMethod](@TrainingCode char(2)=NULL,
@MethodName varchar(75)=NULL,
@ProgramFK int=NULL,
@OldTMethodPK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TrainingMethodPK
FROM TrainingMethod lastRow
WHERE 
@TrainingCode = lastRow.TrainingCode AND
@MethodName = lastRow.MethodName AND
@ProgramFK = lastRow.ProgramFK AND
@OldTMethodPK = lastRow.OldTMethodPK
ORDER BY TrainingMethodPK DESC) 
BEGIN
INSERT INTO TrainingMethod(
TrainingCode,
MethodName,
ProgramFK,
OldTMethodPK
)
VALUES(
@TrainingCode,
@MethodName,
@ProgramFK,
@OldTMethodPK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
