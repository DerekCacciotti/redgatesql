SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dorothy Baum
-- Create date: 3, 12, 2012
-- Description:	Procedure to return dueby (duedate), minimumdue, maximumdue, &
--     eventdescription
-- =============================================
create PROCEDURE [dbo].[spGetDueByDateInfo] @ScheduledEvent varchar(20), @interval char(2)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT [codeDueByDatesPK]
      ,[ScheduledEvent]
      ,[Interval]
      ,[DueBy]
      ,[MinimumDue]
      ,[MaximumDue]
      ,[EventDescription]
  FROM [dbo].[codeDueByDates]
  WHERE [ScheduledEvent] = @ScheduledEvent and [Interval] = @Interval
END

GO
