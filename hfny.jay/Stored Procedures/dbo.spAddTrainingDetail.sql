
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingDetail](@CulturalCompetency bit=NULL,
@ProgramFK int=NULL,
@SubTopicFK int=NULL,
@SubTopicTime int=NULL,
@TopicFK int=NULL,
@TrainingDetailCreator char(10)=NULL,
@TrainingDetailPK_old int=NULL,
@TrainingFK int=NULL)
AS
INSERT INTO TrainingDetail(
CulturalCompetency,
ProgramFK,
SubTopicFK,
SubTopicTime,
TopicFK,
TrainingDetailCreator,
TrainingDetailPK_old,
TrainingFK
)
VALUES(
@CulturalCompetency,
@ProgramFK,
@SubTopicFK,
@SubTopicTime,
@TopicFK,
@TrainingDetailCreator,
@TrainingDetailPK_old,
@TrainingFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
