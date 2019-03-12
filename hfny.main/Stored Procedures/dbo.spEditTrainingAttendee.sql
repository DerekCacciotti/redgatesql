SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainingAttendee](@TrainingAttendeePK int=NULL,
@TrainingAttendeeEditor varchar(max)=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
UPDATE TrainingAttendee
SET 
TrainingAttendeeEditor = @TrainingAttendeeEditor, 
TrainingFK = @TrainingFK, 
WorkerFK = @WorkerFK
WHERE TrainingAttendeePK = @TrainingAttendeePK
GO
