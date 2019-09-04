SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditNewsEntryItem](@NewsEntryItemPK int=NULL,
@Contents varchar(max)=NULL,
@OrderBy int=NULL,
@NewsEntryFK int=NULL)
AS
UPDATE NewsEntryItem
SET 
Contents = @Contents, 
OrderBy = @OrderBy, 
NewsEntryFK = @NewsEntryFK
WHERE NewsEntryItemPK = @NewsEntryItemPK
GO
