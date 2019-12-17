SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetPHQ9AtCurrentInterval] @TCDOB VARCHAR(MAX), @HVDate VARCHAR(MAX), @HVCaseFK INT AS

DECLARE @TCAgeDays int
DECLARE @PreviousInterval TABLE
(interval CHAR(2))


DECLARE @NextInterval TABLE
(interval CHAR(2))

DECLARE @tblResults TABLE
( ScheduledEvent VARCHAR(max),
Completed BIT,
DateComplete DATETIME,
NextInterval VARCHAR(max),
NextDue DATETIME
)


--SET @HVDate = '09-25-19'

SET @TCAgeDays = DATEDIFF(DAY, @TCDOB, @HVDate)


INSERT INTO @PreviousInterval
(
    interval
)

 
			
				select case when max(Interval) is null then '' else max(Interval) end as PreviousInterval  
				from codeDueByDates  
				where ScheduledEvent = 'Follow Up'  
				and @TCAgeDays >= DueBy  
			 



			 --SELECT * FROM @PreviousInterval pi


			 INSERT into @NextInterval
			 (
			     interval
			 )
			
			
			 
				select min(Interval) As NextInterval  
				from codeDueByDates  
				where ScheduledEvent = 'Follow Up'  
				and @TCAgeDays < DueBy  
			
			--SELECT * FROM @NextInterval ni 




			INSERT INTO @tblResults
			(
			    ScheduledEvent,
			    Completed,
			    DateComplete,
			    NextInterval,
			    NextDue
			)
			

			select  cdbdprev.EventDescription  
					,  case when fu.FollowUpPK Is null then 0 else 1 end  
					, fu.FollowUpDate  		
					, cdbdnext.EventDescription  
					,  dateadd(day, cdbdnext.DueBy, @TCDOB)
						from @PreviousInterval pi2   
			inner join @NextInterval ni2  on 1 = 1  
			left outer join codeDueByDates cdbdprev on cdbdprev.Interval = pi2.interval and cdbdprev.ScheduledEvent = 'Follow Up'  
			inner join codeDueByDates cdbdnext on cdbdnext.Interval = ni2.interval and cdbdnext.ScheduledEvent = 'Follow Up'  
			LEFT JOIN FollowUp fu ON fu.HVCaseFK = @HVCaseFK AND fu.FollowUpInterval = pi2.interval


			SELECT * FROM @tblResults tr
GO
