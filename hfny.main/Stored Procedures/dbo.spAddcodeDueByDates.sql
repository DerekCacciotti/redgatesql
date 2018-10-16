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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
