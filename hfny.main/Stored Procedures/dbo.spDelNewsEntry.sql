SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelNewsEntry](@NewsEntryPK int)

AS


DELETE 
FROM NewsEntry
WHERE NewsEntryPK = @NewsEntryPK
GO
