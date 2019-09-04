SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelNewsEntryItem](@NewsEntryItemPK int)

AS


DELETE 
FROM NewsEntryItem
WHERE NewsEntryItemPK = @NewsEntryItemPK
GO
