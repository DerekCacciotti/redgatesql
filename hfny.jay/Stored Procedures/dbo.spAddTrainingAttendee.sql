
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingAttendee](@TrainingFK int=NULL,
@WorkerFK int=NULL,
@TrainingAttendeeCreator nvarchar(50)=NULL)
AS
INSERT INTO TrainingAttendee(
TrainingFK,
WorkerFK,
TrainingAttendeeCreator
)
VALUES(
@TrainingFK,
@WorkerFK,
@TrainingAttendeeCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
