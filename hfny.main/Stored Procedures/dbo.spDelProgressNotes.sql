SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelProgressNotes](@ProgressNotesPK int)

AS


DELETE 
FROM ProgressNotes
WHERE ProgressNotesPK = @ProgressNotesPK
GO
