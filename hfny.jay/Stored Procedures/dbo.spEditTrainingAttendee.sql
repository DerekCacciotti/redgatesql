
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainingAttendee](@TrainingAttendeePK int=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL,
@TrainingAttendeeEditor nvarchar(50)=NULL)
AS
UPDATE TrainingAttendee
SET 
TrainingFK = @TrainingFK, 
WorkerFK = @WorkerFK, 
TrainingAttendeeEditor = @TrainingAttendeeEditor
WHERE TrainingAttendeePK = @TrainingAttendeePK
GO
