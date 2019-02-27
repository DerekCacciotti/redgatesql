SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFormReview](@FormDate datetime=NULL,
@FormFK int=NULL,
@FormReviewCreator char(10)=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ReviewDateTime datetime=NULL,
@ReviewedBy varchar(10)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) FormReviewPK
FROM FormReview lastRow
WHERE 
@FormDate = lastRow.FormDate AND
@FormFK = lastRow.FormFK AND
@FormReviewCreator = lastRow.FormReviewCreator AND
@FormType = lastRow.FormType AND
@HVCaseFK = lastRow.HVCaseFK AND
@ProgramFK = lastRow.ProgramFK AND
@ReviewDateTime = lastRow.ReviewDateTime AND
@ReviewedBy = lastRow.ReviewedBy
ORDER BY FormReviewPK DESC) 
BEGIN
INSERT INTO FormReview(
FormDate,
FormFK,
FormReviewCreator,
FormType,
HVCaseFK,
ProgramFK,
ReviewDateTime,
ReviewedBy
)
VALUES(
@FormDate,
@FormFK,
@FormReviewCreator,
@FormType,
@HVCaseFK,
@ProgramFK,
@ReviewDateTime,
@ReviewedBy
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
