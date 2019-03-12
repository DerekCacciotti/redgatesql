SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSubTopic](@ProgramFK int=NULL,
@RequiredBy char(4)=NULL,
@SATFK money=NULL,
@SubTopicCode char(1)=NULL,
@SubTopicCreator varchar(max)=NULL,
@SubTopicName char(100)=NULL,
@SubTopicPK_old int=NULL,
@TopicFK int=NULL,
@TrainingTickler nchar(3)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) SubTopicPK
FROM SubTopic lastRow
WHERE 
@ProgramFK = lastRow.ProgramFK AND
@RequiredBy = lastRow.RequiredBy AND
@SATFK = lastRow.SATFK AND
@SubTopicCode = lastRow.SubTopicCode AND
@SubTopicCreator = lastRow.SubTopicCreator AND
@SubTopicName = lastRow.SubTopicName AND
@SubTopicPK_old = lastRow.SubTopicPK_old AND
@TopicFK = lastRow.TopicFK AND
@TrainingTickler = lastRow.TrainingTickler
ORDER BY SubTopicPK DESC) 
BEGIN
INSERT INTO SubTopic(
ProgramFK,
RequiredBy,
SATFK,
SubTopicCode,
SubTopicCreator,
SubTopicName,
SubTopicPK_old,
TopicFK,
TrainingTickler
)
VALUES(
@ProgramFK,
@RequiredBy,
@SATFK,
@SubTopicCode,
@SubTopicCreator,
@SubTopicName,
@SubTopicPK_old,
@TopicFK,
@TrainingTickler
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
