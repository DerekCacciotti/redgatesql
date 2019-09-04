SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 07/5/18
-- Description:	This stored procedure returns all the news entries
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllNewsEntries]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT ne.NewsEntryPK FROM dbo.NewsEntry ne ORDER BY ne.EntryDate DESC
END
GO
