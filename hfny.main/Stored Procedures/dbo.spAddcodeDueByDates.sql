SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeDueByDates](@DueBy int=NULL,
@EventDescription varchar(50)=NULL,
@Interval char(2)=NULL,
@MaximumDue int=NULL,
@MinimumDue int=NULL,
@ScheduledEvent varchar(20)=NULL,
@Frequency int=NULL,
@Optional bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeDueByDatesPK
FROM codeDueByDates lastRow
WHERE 
@DueBy = lastRow.DueBy AND
@EventDescription = lastRow.EventDescription AND
@Interval = lastRow.Interval AND
@MaximumDue = lastRow.MaximumDue AND
@MinimumDue = lastRow.MinimumDue AND
@ScheduledEvent = lastRow.ScheduledEvent AND
@Frequency = lastRow.Frequency AND
@Optional = lastRow.Optional
ORDER BY codeDueByDatesPK DESC) 
BEGIN
INSERT INTO codeDueByDates(
DueBy,
EventDescription,
Interval,
MaximumDue,
MinimumDue,
ScheduledEvent,
Frequency,
Optional
)
VALUES(
@DueBy,
@EventDescription,
@Interval,
@MaximumDue,
@MinimumDue,
@ScheduledEvent,
@Frequency,
@Optional
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
