SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 03/26/2019 
-- Description: Get records from codeDueByDates for a specific event
-- =============================================

CREATE PROC [dbo].[spGetCodeDueByDatesByScheduledEvent]
	@ScheduledEvent VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * FROM dbo.codeDueByDates cdbd 
	WHERE cdbd.ScheduledEvent = @ScheduledEvent
    
END

GO
