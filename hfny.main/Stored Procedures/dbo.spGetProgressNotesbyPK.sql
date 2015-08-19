SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetProgressNotesbyPK]

(@ProgressNotesPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM ProgressNotes
WHERE ProgressNotesPK = @ProgressNotesPK
GO
