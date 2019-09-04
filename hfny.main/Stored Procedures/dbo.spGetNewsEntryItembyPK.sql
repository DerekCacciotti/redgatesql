SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetNewsEntryItembyPK]

(@NewsEntryItemPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM NewsEntryItem
WHERE NewsEntryItemPK = @NewsEntryItemPK
GO
