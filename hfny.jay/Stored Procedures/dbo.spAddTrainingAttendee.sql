SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingAttendee](@ExemptDescription varchar(500)=NULL,
@ExemptType char(2)=NULL,
@IsExempt bit=NULL,
@ProgramFK int=NULL,
@SubtopicFK int=NULL,
@TopicFK int=NULL,
@TrainingAttendeeCreator char(10)=NULL,
@TrainingAttendeePK_old int=NULL,
@TrainingDetailFK int=NULL,
@TrainingFK int=NULL,
@WorkerFK int=NULL)
AS
INSERT INTO TrainingAttendee(
ExemptDescription,
ExemptType,
IsExempt,
ProgramFK,
SubtopicFK,
TopicFK,
TrainingAttendeeCreator,
TrainingAttendeePK_old,
TrainingDetailFK,
TrainingFK,
WorkerFK
)
VALUES(
@ExemptDescription,
@ExemptType,
@IsExempt,
@ProgramFK,
@SubtopicFK,
@TopicFK,
@TrainingAttendeeCreator,
@TrainingAttendeePK_old,
@TrainingDetailFK,
@TrainingFK,
@WorkerFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
