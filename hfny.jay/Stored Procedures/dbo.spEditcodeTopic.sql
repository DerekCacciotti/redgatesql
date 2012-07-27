SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeTopic](@codeTopicPK int=NULL,
@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL)
AS
UPDATE codeTopic
SET 
TopicName = @TopicName, 
TopicCode = @TopicCode, 
TopicPK_old = @TopicPK_old
WHERE codeTopicPK = @codeTopicPK
GO
