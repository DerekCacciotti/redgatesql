
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTopic](@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL,
@SATCompareDateField nvarchar(50)=NULL,
@SATInterval nvarchar(50)=NULL,
@SATName nvarchar(10)=NULL)
AS
INSERT INTO codeTopic(
TopicName,
TopicCode,
TopicPK_old,
SATCompareDateField,
SATInterval,
SATName
)
VALUES(
@TopicName,
@TopicCode,
@TopicPK_old,
@SATCompareDateField,
@SATInterval,
@SATName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
