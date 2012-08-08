
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeSubTopicDetail](@CompareToDate varchar(10)=NULL,
@DaysRequired int=NULL,
@Interval varchar(40)=NULL,
@RequiredBy varchar(4)=NULL,
@SATFK money=NULL,
@SubTopicFK int=NULL,
@SubTopicName varchar(64)=NULL,
@TopicFK int=NULL,
@TopicName varchar(100)=NULL,
@STDetailPK_old int=NULL)
AS
INSERT INTO codeSubTopicDetail(
CompareToDate,
DaysRequired,
Interval,
RequiredBy,
SATFK,
SubTopicFK,
SubTopicName,
TopicFK,
TopicName,
STDetailPK_old
)
VALUES(
@CompareToDate,
@DaysRequired,
@Interval,
@RequiredBy,
@SATFK,
@SubTopicFK,
@SubTopicName,
@TopicFK,
@TopicName,
@STDetailPK_old
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
