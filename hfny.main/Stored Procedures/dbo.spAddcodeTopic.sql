SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTopic](@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL,
@SATCompareDateField nvarchar(50)=NULL,
@SATInterval nvarchar(50)=NULL,
@SATName nvarchar(10)=NULL,
@SATReqBy nvarchar(50)=NULL,
@DaysAfter int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeTopicPK
FROM codeTopic lastRow
WHERE 
@TopicName = lastRow.TopicName AND
@TopicCode = lastRow.TopicCode AND
@TopicPK_old = lastRow.TopicPK_old AND
@SATCompareDateField = lastRow.SATCompareDateField AND
@SATInterval = lastRow.SATInterval AND
@SATName = lastRow.SATName AND
@SATReqBy = lastRow.SATReqBy AND
@DaysAfter = lastRow.DaysAfter
ORDER BY codeTopicPK DESC) 
BEGIN
INSERT INTO codeTopic(
TopicName,
TopicCode,
TopicPK_old,
SATCompareDateField,
SATInterval,
SATName,
SATReqBy,
DaysAfter
)
VALUES(
@TopicName,
@TopicCode,
@TopicPK_old,
@SATCompareDateField,
@SATInterval,
@SATName,
@SATReqBy,
@DaysAfter
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
