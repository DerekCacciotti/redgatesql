SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 02/20/18
-- Description:	This stored procedure obtains the 50 most recently
-- viewed cases for a specific user.
-- (Code was created by Jay Robohn, I am just turning it into a stored procedure)
-- =============================================
CREATE PROCEDURE [dbo].[spGetRecentlyViewedCasesByUserName] (@UserName VARCHAR(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    WITH cteCaseViews AS 
	(
		SELECT TOP 1000 cv.PC1ID, MAX(cv.ViewDate) AS ViewDateMax 
			FROM CaseView cv
			WHERE cv.Username = @UserName 
			GROUP BY cv.PC1ID
			ORDER BY ViewDateMax DESC
	)

	SELECT TOP 50 PC1ID FROM cteCaseViews
END
GO
