SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTopic](@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL)
AS
INSERT INTO codeTopic(
TopicName,
TopicCode,
TopicPK_old
)
VALUES(
@TopicName,
@TopicCode,
@TopicPK_old
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
