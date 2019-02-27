SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistFrequentlyAskedQuestion](@Category varchar(50)=NULL,
@Question varchar(max)=NULL,
@Answer varchar(max)=NULL,
@CategoryPosition int=NULL,
@QuestionPosition int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listFrequentlyAskedQuestionPK
FROM listFrequentlyAskedQuestion lastRow
WHERE 
@Category = lastRow.Category AND
@Question = lastRow.Question AND
@Answer = lastRow.Answer AND
@CategoryPosition = lastRow.CategoryPosition AND
@QuestionPosition = lastRow.QuestionPosition
ORDER BY listFrequentlyAskedQuestionPK DESC) 
BEGIN
INSERT INTO listFrequentlyAskedQuestion(
Category,
Question,
Answer,
CategoryPosition,
QuestionPosition
)
VALUES(
@Category,
@Question,
@Answer,
@CategoryPosition,
@QuestionPosition
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
