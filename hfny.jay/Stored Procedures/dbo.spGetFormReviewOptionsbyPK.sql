SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetFormReviewOptionsbyPK]

(@FormReviewOptionsPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM FormReviewOptions
WHERE FormReviewOptionsPK = @FormReviewOptionsPK
GO
