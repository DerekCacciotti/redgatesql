
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S Khalsa
-- Create date: 11/05/2012
-- Description:	Got it from FamSys
-- =============================================
CREATE FUNCTION [dbo].[IsFormReviewed]
(
	@DateCheck as DateTime, --the date of the form in question
	@FType as CHAR(2), --the Form Type in question
	@FormFK as INT  --the specific FormFK in question
)
RETURNS bit
AS
BEGIN

	DECLARE @IsReviewed as bit

	SET @IsReviewed = 1

	-- Declare the return variable here
	
		IF dbo.IsFormReviewTurnedOn(@DateCheck,@FType,@FormFK) > 0 
			BEGIN 
			
				SELECT @IsReviewed = CASE WHEN FormReviewOptionsPK IS NULL THEN 1
				WHEN FormReviewOptions.FormType IS NULL THEN 1
				WHEN @DateCheck < FormReviewStartDate THEN 1 
				WHEN @DateCheck > FormReviewENDDate THEN 1
				WHEN ReviewedBy IS NOT NULL THEN 1
				ELSE 0
				END
				FROM formreview 
				LEFT JOIN formreviewoptions
				ON FormReview.ProgramFK=FormReviewOptions.Programfk AND FormReviewOptions.FormType=@Ftype
				where formreview.FormFK=@FormFK 
				 and formreview.FormType=@FType 
				 and formreview.formdate=@DateCheck
			END 
	
	RETURN @IsReviewed
END
GO
