SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetASQSEDueAtInterval] @TCDOB VARCHAR(MAX), @HVDate VARCHAR(MAX), @HVCaseFK INT AS

DECLARE @TCAgeDays int
DECLARE @PreviousInterval TABLE
(interval CHAR(2))


DECLARE @NextInterval TABLE
(interval CHAR(2))

DECLARE @tblResults TABLE
( ScheduledEvent VARCHAR(max),
Completed BIT,
DateComplete DATETIME,
ASQUnderCutOff BIT,
NextInterval VARCHAR(max),
NextDue DATETIME,
IsReceivingServices bit
)


--SET @HVDate = '09-25-19'

SET @TCAgeDays = DATEDIFF(DAY, @TCDOB, @HVDate)


INSERT INTO @PreviousInterval
(
    interval
)

 
			
				select case when max(Interval) is null then '' else max(Interval) end as PreviousInterval  
				from codeDueByDates  
				where ScheduledEvent = 'ASQSE-1'  
				and @TCAgeDays >= DueBy  
			 



			 --SELECT * FROM @PreviousInterval pi


			 INSERT into @NextInterval
			 (
			     interval
			 )
			
			
			 
				select min(Interval) As NextInterval  
				from codeDueByDates  
				where ScheduledEvent = 'ASQSE-1'  
				and @TCAgeDays < DueBy  
			
			--SELECT * FROM @NextInterval ni 




			INSERT INTO @tblResults
			(
			    ScheduledEvent,
			    Completed,
			    DateComplete,
			    ASQUnderCutOff,
			    NextInterval,
			    NextDue,
				IsReceivingServices
			)
			

			select  cdbdprev.EventDescription  
					,  case when a.ASQSEPK Is null then 0 else 1 end  
					, a.ASQSEDateCompleted  
					, a.ASQSEOverCutOff			
					, cdbdnext.EventDescription  
					,  dateadd(day, cdbdnext.DueBy, @TCDOB),
					CASE WHEN a.ASQSEReceiving IS NULL THEN 0 ELSE 1 end
			from @PreviousInterval pi2   
			inner join @NextInterval ni2  on 1 = 1  
			left outer join codeDueByDates cdbdprev on cdbdprev.Interval = pi2.interval and cdbdprev.ScheduledEvent = 'ASQSE-1'  
			inner join codeDueByDates cdbdnext on cdbdnext.Interval = ni2.interval and cdbdnext.ScheduledEvent = 'ASQSE-1'  
			left join ASQSE a  WITH (NOLOCK) on a.HVCaseFK = @HVCaseFK And a.ASQSETCAge = pi2.interval 


			SELECT * FROM @tblResults tr
GO
