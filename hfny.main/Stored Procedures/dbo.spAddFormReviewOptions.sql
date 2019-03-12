SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFormReviewOptions](@FormReviewEndDate datetime=NULL,
@FormReviewOptionsCreator varchar(max)=NULL,
@FormReviewStartDate datetime=NULL,
@FormType char(2)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) FormReviewOptionsPK
FROM FormReviewOptions lastRow
WHERE 
@FormReviewEndDate = lastRow.FormReviewEndDate AND
@FormReviewOptionsCreator = lastRow.FormReviewOptionsCreator AND
@FormReviewStartDate = lastRow.FormReviewStartDate AND
@FormType = lastRow.FormType AND
@ProgramFK = lastRow.ProgramFK
ORDER BY FormReviewOptionsPK DESC) 
BEGIN
INSERT INTO FormReviewOptions(
FormReviewEndDate,
FormReviewOptionsCreator,
FormReviewStartDate,
FormType,
ProgramFK
)
VALUES(
@FormReviewEndDate,
@FormReviewOptionsCreator,
@FormReviewStartDate,
@FormType,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
