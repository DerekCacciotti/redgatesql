SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainingDetail](@CulturalCompetency bit=NULL,
@ProgramFK int=NULL,
@SubTopicFK int=NULL,
@SubTopicTime int=NULL,
@TopicFK int=NULL,
@TrainingDetailCreator varchar(max)=NULL,
@TrainingDetailPK_old int=NULL,
@TrainingFK int=NULL,
@ExemptDescription varchar(500)=NULL,
@ExemptType varchar(2)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TrainingDetailPK
FROM TrainingDetail lastRow
WHERE 
@CulturalCompetency = lastRow.CulturalCompetency AND
@ProgramFK = lastRow.ProgramFK AND
@SubTopicFK = lastRow.SubTopicFK AND
@SubTopicTime = lastRow.SubTopicTime AND
@TopicFK = lastRow.TopicFK AND
@TrainingDetailCreator = lastRow.TrainingDetailCreator AND
@TrainingDetailPK_old = lastRow.TrainingDetailPK_old AND
@TrainingFK = lastRow.TrainingFK AND
@ExemptDescription = lastRow.ExemptDescription AND
@ExemptType = lastRow.ExemptType
ORDER BY TrainingDetailPK DESC) 
BEGIN
INSERT INTO TrainingDetail(
CulturalCompetency,
ProgramFK,
SubTopicFK,
SubTopicTime,
TopicFK,
TrainingDetailCreator,
TrainingDetailPK_old,
TrainingFK,
ExemptDescription,
ExemptType
)
VALUES(
@CulturalCompetency,
@ProgramFK,
@SubTopicFK,
@SubTopicTime,
@TopicFK,
@TrainingDetailCreator,
@TrainingDetailPK_old,
@TrainingFK,
@ExemptDescription,
@ExemptType
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
