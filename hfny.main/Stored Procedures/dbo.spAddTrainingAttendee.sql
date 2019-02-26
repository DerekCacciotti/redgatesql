SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingAttendee](@TrainingAttendeeCreator nvarchar(50)=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TrainingAttendeePK
FROM TrainingAttendee lastRow
WHERE 
@TrainingAttendeeCreator = lastRow.TrainingAttendeeCreator AND
@TrainingFK = lastRow.TrainingFK AND
@WorkerFK = lastRow.WorkerFK
ORDER BY TrainingAttendeePK DESC) 
BEGIN
INSERT INTO TrainingAttendee(
TrainingAttendeeCreator,
TrainingFK,
WorkerFK
)
VALUES(
@TrainingAttendeeCreator,
@TrainingFK,
@WorkerFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
