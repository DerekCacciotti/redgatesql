SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetNewsCount] @date VARCHAR(MAX) AS

DECLARE @tblbadge TABLE
(badgecount INT)



INSERT INTO @tblbadge
(
    badgecount
)

SELECT COUNT(*) FROM NewsEntry ne INNER JOIN NewsEntryItem nei ON nei.NewsEntryFK = ne.NewsEntryPK
WHERE ne.EntryDate = @date 


SELECT * FROM @tblbadge t

GO
