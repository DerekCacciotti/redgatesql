SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 02/20/18
-- Description:	This stored procedure obtains the 50 most recently
-- viewed cases for a specific user and filters those results by program.
-- The @ProgramFK parameter is now optional.
-- =============================================
CREATE PROC [dbo].[spGetRecentlyViewedCases]
(
	@UserName VARCHAR(255),
	@ProgramFK INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CaseViews TABLE
	(
		PC1ID CHAR(13),
		ViewDateMax DATETIME
	);

	INSERT	INTO @CaseViews
	(
		PC1ID,
		ViewDateMax
	)
	SELECT	TOP 100
			cv.PC1ID,
			MAX(cv.ViewDate) AS ViewDateMax
	FROM	CaseView cv
		INNER JOIN CaseProgram cp
			ON cp.PC1ID = cv.PC1ID
	WHERE cv.Username = @UserName
		AND cp.ProgramFK = ISNULL(@ProgramFK, cp.ProgramFK)
	GROUP BY cv.PC1ID
	ORDER BY ViewDateMax DESC;

	SELECT	TOP 20
			PC1ID
	FROM	@CaseViews
	ORDER BY ViewDateMax DESC;
END;
GO
