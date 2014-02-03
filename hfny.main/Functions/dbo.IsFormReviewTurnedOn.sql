SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S Khalsa
-- Create date: 12/20/2012
-- Usuage:  select dbo.IsFormReviewTurnedOn('20120716', 'PS',53277)
-- =============================================
CREATE FUNCTION [dbo].[IsFormReviewTurnedOn]
(
	@DateCheck as DateTime, --the date of the form in question
	@FType as CHAR(2), --the Form Type in question
	@FormFK as INT  --the specific FormFK in question
)
RETURNS INT
AS
BEGIN

-- If we @numOfRecords = 0 then formreview is not turned yet, else yes

	DECLARE @numOfRecords as INT 


	SET @numOfRecords = ( SELECT count(FormReviewPK) FROM formreview 
		LEFT JOIN formreviewoptions
		ON FormReview.ProgramFK=FormReviewOptions.Programfk AND FormReviewOptions.FormType=@Ftype
		where formreview.FormFK=@FormFK 
		 and formreview.FormType=@FType 
		 and formreview.formdate=@DateCheck)



	RETURN @numOfRecords
END
GO
