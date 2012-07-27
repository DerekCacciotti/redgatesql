SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeSubTopicDetail](@codeSubTopicDetailPK int=NULL,
@CompareToDate varchar(10)=NULL,
@DaysRequired int=NULL,
@Interval varchar(40)=NULL,
@RequiredBy varchar(4)=NULL,
@SATFK int=NULL,
@SubTopicFK int=NULL,
@SubTopicName varchar(64)=NULL,
@TopicFK int=NULL,
@TopicName varchar(100)=NULL,
@STDetailPK_old int=NULL)
AS
UPDATE codeSubTopicDetail
SET 
CompareToDate = @CompareToDate, 
DaysRequired = @DaysRequired, 
Interval = @Interval, 
RequiredBy = @RequiredBy, 
SATFK = @SATFK, 
SubTopicFK = @SubTopicFK, 
SubTopicName = @SubTopicName, 
TopicFK = @TopicFK, 
TopicName = @TopicName, 
STDetailPK_old = @STDetailPK_old
WHERE codeSubTopicDetailPK = @codeSubTopicDetailPK
GO
