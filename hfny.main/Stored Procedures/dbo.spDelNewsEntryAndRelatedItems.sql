SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spDelNewsEntryAndRelatedItems](@NewsEntryPK INT)

AS

DELETE 
FROM dbo.NewsEntryItem 
WHERE NewsEntryFK = @NewsEntryPK

DELETE 
FROM NewsEntry
WHERE NewsEntryPK = @NewsEntryPK
GO
