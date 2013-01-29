
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetFormsGreaterThanDate]
(
    @eventdate AS DATETIME,
    @hvcasefk     INT
)
AS
	SELECT count(*) AS howmany
		 , codeFormName
	FROM
		codeForm, FormReview
	WHERE
		codeFormAbbreviation = FormReview.formType
		AND hvcasefk = @hvcasefk
		AND DATEADD(D, 0, DATEDIFF(D, 0, formdate)) > @eventdate
		--AND formdate > @eventdate
	GROUP BY
		codeFormName
GO
