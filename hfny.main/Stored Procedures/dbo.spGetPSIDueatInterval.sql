SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetPSIDueatInterval] @TCDOB VARCHAR(MAX), @HVDate VARCHAR(MAX), @HVCaseFK INT AS 

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
IsRecivingServices bit
)


--SET @HVDate = '09-25-19'

SET @TCAgeDays = DATEDIFF(DAY, @TCDOB, @HVDate)


INSERT INTO @PreviousInterval
(
    interval
)

 
			
				select case when max(Interval) is null then '' else max(Interval) end as PreviousInterval  
				from codeDueByDates  
				where ScheduledEvent = 'PSI'  
				and @TCAgeDays >= DueBy  
			 



			 --SELECT * FROM @PreviousInterval pi


			 INSERT into @NextInterval
			 (
			     interval
			 )
			
			
			 
				select min(Interval) As NextInterval  
				from codeDueByDates  
				where ScheduledEvent = 'PSI'  
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
					,  case when p.PSIPK Is null then 0 else 1 end  
					, p.PSIDateComplete  			
					, cdbdnext.EventDescription  
					,  dateadd(day, cdbdnext.DueBy, @TCDOB)
					
			from @PreviousInterval pi2   
			inner join @NextInterval ni2  on 1 = 1  
			left outer join codeDueByDates cdbdprev on cdbdprev.Interval = pi2.interval and cdbdprev.ScheduledEvent = 'PSI'  
			inner join codeDueByDates cdbdnext on cdbdnext.Interval = ni2.interval and cdbdnext.ScheduledEvent = 'PSI'  
			left join PSI p  WITH (NOLOCK) on p.HVCaseFK = @HVCaseFK AND p.PSIInterval = pi2.interval 


			SELECT * FROM @tblResults tr
GO
