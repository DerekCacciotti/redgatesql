SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingDetail](@isCulturalCompetent bit=NULL,
@ProgramFK int=NULL,
@SubTopicFK int=NULL,
@SubTopicTime int=NULL,
@TopicFK int=NULL,
@TrainingDetailCreator char(10)=NULL,
@TrainingDetailPK_old int=NULL,
@TrainingFK int=NULL)
AS
INSERT INTO TrainingDetail(
isCulturalCompetent,
ProgramFK,
SubTopicFK,
SubTopicTime,
TopicFK,
TrainingDetailCreator,
TrainingDetailPK_old,
TrainingFK
)
VALUES(
@isCulturalCompetent,
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
