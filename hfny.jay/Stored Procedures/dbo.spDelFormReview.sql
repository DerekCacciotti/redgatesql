SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spDelFormReview](@FormReviewPK int)

AS


DELETE 
FROM FormReview
WHERE FormReviewPK = @FormReviewPK
GO
