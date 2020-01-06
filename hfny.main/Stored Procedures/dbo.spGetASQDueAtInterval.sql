SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetASQDueAtInterval] @TCDOB VARCHAR(max), @HVDate VARCHAR(max), @HVCaseFK INT AS



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
				where ScheduledEvent = 'ASQ'  
				and @TCAgeDays >= DueBy  
			 



			 --SELECT * FROM @PreviousInterval pi


			 INSERT into @NextInterval
			 (
			     interval
			 )
			
			
			 
				select min(Interval) As NextInterval  
				from codeDueByDates  
				where ScheduledEvent = 'ASQ'  
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
				IsRecivingServices
			)
			

			select  cdbdprev.EventDescription  
					,  case when ASQPK Is null then 0 else 1 end  
					, a.DateCompleted  
					, case when UnderCommunication = 1 or UnderFineMotor = 1 or UnderGrossMotor = 1 
													or UnderPersonalSocial = 1 or UnderProblemSolving = 1 then 1 else 0 end 
					, cdbdnext.EventDescription  
					,  dateadd(day, cdbdnext.DueBy, @TCDOB),
					CASE WHEN a.ASQTCReceiving IS NULL THEN 0 ELSE 1 end
			from @PreviousInterval pi2   
			inner join @NextInterval ni2  on 1 = 1  
			left outer join codeDueByDates cdbdprev on cdbdprev.Interval = pi2.interval and cdbdprev.ScheduledEvent = 'ASQ'  
			inner join codeDueByDates cdbdnext on cdbdnext.Interval = ni2.interval and cdbdnext.ScheduledEvent = 'ASQ'  
			left join ASQ a WITH (NOLOCK) on a.HVCaseFK = @HVCaseFK And a.TCAge = pi2.interval 


			SELECT * FROM @tblResults tr
GO
