SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Procedure: spTCMedicalShowRecommendedCDCRecommended
-- Author:		Derek Cacciotti
-- Create date: April 2, 2019
-- Description:	CDC Schedule matched up with Immunization History

-- Modified: jayrobot
-- Mod Date: Feb. 3, 2020
-- Fix: Order by in while loop was character version of a date
-- =============================================
CREATE procedure [dbo].[spTCMedicalShowRecommendedCDCRecommended]
	@TCIDFK int
as

declare @TCDOB date ;
--DECLARE @TCIDFK int 
declare @NumberOfRowsCDCMaster int ;
declare @counter int ;
declare @CurrentScheduledEvent varchar(150) ;
declare @ChickenPoxStatus bit ;
declare @ImmunizationStatus bit ;

declare @TCAgeInDays int ;
declare @IsTCMoreThan3MonthsOld bit = 0 ;
declare @BeginningOfYear datetime = dateadd(yy, datediff(yy, 0, getdate()), 0) ;
declare @EndOfYear datetime = dateadd(yy, datediff(yy, 0, getdate())+1, -1) ;
set @counter = 0 ;
--SET @TCIDFK = 40494

--get the TCDOB
set @TCDOB = (select TCDOB from dbo.TCID where TCIDPK = @TCIDFK) ;
-- get the TC age in days 
set @TCAgeInDays = (select datediff(day, @TCDOB, getdate())) ;
-- check to see if the TC is greater or equal to 90 days old 
if (@TCAgeInDays >= 90) 
	begin
		set @IsTCMoreThan3MonthsOld = 1 ;
	end ;

--get the status of the chickenpox virus and overall immunizations
set @ChickenPoxStatus = (select VaricellaZoster from dbo.TCID where TCIDPK = @TCIDFK) ;
set @ImmunizationStatus = (select NoImmunization from dbo.TCID where TCIDPK = @TCIDFK) ;

--print @ChickenPoxStatus ;
--print @ImmunizationStatus ;

--This is my CDC Master Table
declare @CDCMaster table (
						ID	int identity(1, 1)
					, codeduebydatespk int
					, dueby int
					, eventdescription varchar(50)
					, interval char(2)
					, maxdue int
					, mindue int
					, scheduledevent varchar(20)
					, frequency int
					, optional bit
					, EventDate date
					, DisplayDate char(10)
					, estdate char(10)
						) ;

insert into @CDCMaster (
						codeduebydatespk, dueby, eventdescription, interval, maxdue, mindue
					, scheduledevent, frequency, optional, estdate
					)
select		codeDueByDatesPK
		, DueBy
		, EventDescription
		, Interval
		, MaximumDue
		, MinimumDue
		, ScheduledEvent
		, Frequency
		, Optional
		--DATEADD(day,DueBy, @TCDOB)
		, convert(char(10), dateadd(day, DueBy, @TCDOB), 1)

from		dbo.codeDueByDates
inner join	dbo.codeMedicalItem on MedicalItemTitle = ScheduledEvent
where		(MedicalItemGroup = 'Immunization')
order by	codeDueByDates.DueBy ;



set @NumberOfRowsCDCMaster = (select count (*)from @CDCMaster) ;

declare @TCIDImmunizations table (
								ImmunizationID	int identity(1, 1)
							, EventDescription varchar(120)
							, ScheduledEvent varchar(120)
							, Optional bit
							, DueBy int
							, EventDate date
							, DisplayDate char(10)
							, MedicalItemTitle varchar(10)
							, estdate char(10)
								) ;

insert into @TCIDImmunizations (
								--EventDescription,
								--ScheduledEvent,
								--Optional,
								--DueBy,
								EventDate, DisplayDate, MedicalItemTitle
							--estdate
							)
select --EventDescription,
	--ScheduledEvent,
	--Optional,
	--DueBy,
		TCItemDate
		, convert(char(10), TCItemDate, 1)
		, MedicalItemTitle
--, CONVERT(CHAR(10), DATEADD(DAY, DueBy, @TCDOB), 111) AS estdate
from		TCMedical
inner join	codeMedicalItem on MedicalItemCode = TCMedicalItem
--INNER JOIN dbo.codeDueByDates ON MedicalItemTitle = ScheduledEvent
where		(MedicalItemGroup = 'Immunization') and TCIDFK = @TCIDFK ;

--set the estimated dates for when the CDC wants the immunizations in the master table
--UPDATE @CDCMaster SET estdate = CONVERT(CHAR(10), DATEADD(DAY, DueBy, @TCDOB), 111) 

--SELECT * FROM @CDCMaster ORDER BY dueby
--SELECT * FROM @CDCMaster ORDER BY DisplayDate
--SELECT * FROM @CDCMaster ORDER BY EventDate
--select * from @TCIDImmunizations ti

while @counter <= @NumberOfRowsCDCMaster begin

	declare @ImmunizationDate as date = null ; --this is what we get from the @TCIDImmunizations table
	declare @idDelete as int = null ; --this is what the TCIDImmunizations pk that we will delete once we get the immunization date
	declare @myevent as varchar(10) = (select scheduledevent from @CDCMaster where ID = @counter) ;
	declare @ImmunizationDateFormatted as char(10) = null ;

	-- print 'Counter: ' + convert(varchar(5), @counter) ;

	set @ImmunizationDate = (
							select		top 1 DisplayDate
							from		@TCIDImmunizations
							where		MedicalItemTitle = @myevent
							order by	EventDate
							) ;
	
	-- print 'Immunization date: ' + convert(varchar(10), @ImmunizationDate) ;

	set @ImmunizationDateFormatted = convert(char(10), @ImmunizationDate, 1) ;

	set @idDelete = (
					select		top 1 ImmunizationID
					from		@TCIDImmunizations
					where		MedicalItemTitle = @myevent
					order by	EventDate
					) ;

	update	@CDCMaster
	set		DisplayDate = @ImmunizationDateFormatted
	where	ID = @counter ;
	delete from @TCIDImmunizations where ImmunizationID = @idDelete ;

	set @counter = @counter+1 ;
end ;

if (@ChickenPoxStatus = 1) 
	begin
		if (@IsTCMoreThan3MonthsOld = 0) 
			begin
				select	*
					, 'Past due' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) < getdate()
						and dateadd(day, dueby, @TCDOB) < getdate() and scheduledevent != 'VZ'
				union
				select	*
					, 'Nearing' as type
				from	@CDCMaster
				where	DisplayDate is null
						--AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() 
						and estdate between @BeginningOfYear and @EndOfYear and scheduledevent != 'VZ'
				union
				select	*
					, 'Done' as type
				from	@CDCMaster
				where	DisplayDate is not null or scheduledevent = 'VZ'
				union
				select	*
					, '' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
						and estdate > @EndOfYear ;
			end ;
		else -- @IsTCMoreThan3MonthsOld <> 0
			begin
				select	*
					, 'Past due' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) < getdate()
						and dateadd(day, dueby, @TCDOB) < getdate() and scheduledevent != 'VZ'
				union
				select	*
					, 'Nearing' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
						and estdate between @BeginningOfYear and @EndOfYear and scheduledevent != 'VZ'
				union
				select	*
					, 'Done' as type
				from	@CDCMaster
				where	DisplayDate is not null or scheduledevent = 'VZ'
				union
				select	*
					, '' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
						and estdate > @EndOfYear ;
			end ;
		end ;
-- else for the chicken pox virus check 
else
	if (@IsTCMoreThan3MonthsOld = 0) 
		begin
			begin
				select	*
					, 'Past due' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) < getdate()
						and dateadd(day, dueby, @TCDOB) < getdate()
				union
				select	*
					, 'Nearing' as type
				from	@CDCMaster
				where	DisplayDate is null
						--AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() 
						and estdate between @BeginningOfYear and @EndOfYear
						and not dateadd(month, -3, dateadd(day, dueby, @TCDOB)) < getdate()
						and not dateadd(day, dueby, @TCDOB) < getdate()
				union
				select *, 'Done' as type from @CDCMaster where DisplayDate is not null
				union
				select	*
					, '' as type
				from	@CDCMaster
				where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
						and estdate > @EndOfYear ;
			end ;
		end ;
	else -- @IsTCMoreThan3MonthsOld <> 0
		-- begin for the else 
		begin
			-- when TC is 3 months or older 
			select	*
				, 'Past due' as type
			from	@CDCMaster
			where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) < getdate()
					and dateadd(day, dueby, @TCDOB) < getdate()
			union
			select	*
				, 'Nearing' as type
			from	@CDCMaster
			where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
					and estdate between @BeginningOfYear and @EndOfYear
			union
			select *, 'Done' as type from @CDCMaster where DisplayDate is not null
			union
			select	*
				, '' as type
			from	@CDCMaster
			where	DisplayDate is null and dateadd(month, -3, dateadd(day, dueby, @TCDOB)) >= getdate()
					and estdate > @EndOfYear ;
		-- end for the else 
		end ;
GO
