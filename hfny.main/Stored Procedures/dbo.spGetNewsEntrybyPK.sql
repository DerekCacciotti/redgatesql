SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetNewsEntrybyPK]

(@NewsEntryPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM NewsEntry
WHERE NewsEntryPK = @NewsEntryPK
GO
