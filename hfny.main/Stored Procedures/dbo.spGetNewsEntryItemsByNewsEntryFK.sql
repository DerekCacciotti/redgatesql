SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/5/18
-- Description:	This stored procedure returns all the news entry items for
-- a specific news entry
-- =============================================
CREATE PROC [dbo].[spGetNewsEntryItemsByNewsEntryFK]
	@NewsEntryFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT * FROM dbo.NewsEntryItem nei WHERE nei.NewsEntryFK = @NewsEntryFK ORDER BY nei.OrderBy ASC
END
GO
