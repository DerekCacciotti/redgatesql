SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[FormReviewedTableList]
(
  @FormType  varchar(2),
  @ProgFK INT
)

RETURNS TABLE 
AS
RETURN 

		SELECT FormFK 
			,CASE WHEN fr.ReviewedBy IS NULL THEN  
				CASE WHEN fro.FormReviewStartDate <= fr.Formdate THEN 
					CASE WHEN fro.FormReviewEndDate IS NULL THEN '0' --reviews have started for training
					WHEN fro.FormReviewEndDate > fr.Formdate THEN '0' --reviews have started for training
					ELSE '' END  --review end date is greater than the training date for this training
				WHEN fro.FormReviewStartDate > fr.Formdate THEN ''  --reviews have NOT started for training
				WHEN fro.FormReviewStartDate IS Null THEN '' END--reviewing training NOT set
			ELSE 
				CASE WHEN fro.FormReviewStartDate <= fr.Formdate THEN '1' --approved and reviews have started for training
					--don't check end date for an approved training, as the user may wonder why an approval is not approved
				WHEN  fro.FormReviewStartDate > fr.Formdate THEN ''  --approved but someone changed review date into future
				WHEN  fro.FormReviewStartDate IS Null THEN '' END --approved but somehow reviewing training NOT set
			END AS 'IsApproved'
		FROM FormReview fr
	    INNER JOIN [dbo].[FormReviewOptions] fro ON fro.ProgramFK = fr.ProgramFK  
		WHERE fr.ProgramFK = @ProgFK
		AND fr.FormType=@FormType AND fro.FormType=@FormType	
GO
