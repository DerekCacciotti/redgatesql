SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditNewsEntry](@NewsEntryPK int=NULL,
@EntryDate datetime=NULL)
AS
UPDATE NewsEntry
SET 
EntryDate = @EntryDate
WHERE NewsEntryPK = @NewsEntryPK
GO
