SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 1st, 2012>
-- Description:	<This QA report gets you 'PSIs for Active Cases '>
-- rspQAReport9 31, 'summary'	--- for summary page
-- rspQAReport9 20			--- for main report - location = 2
-- rspQAReport9 null			--- for main report for all locations
-- =============================================

CREATE procedure [dbo].[rspQAReport9] (@programfk int = null, @ReportType char(7) = null)
--with recompile
as

-- Last Day of Previous Month 
declare @LastDayofPreviousMonth datetime ;
set @LastDayofPreviousMonth = dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()), 0)) ; -- analysis point

-- table variable for holding Init Required Data
declare @tbl4QAReport9Cohort table (
									OldID [char](23)
								, HVCasePK int
								, [PC1ID] [char](13)
								, TCDOB [datetime]
								, Worker [varchar](200)
								, currentLevel [varchar](50)
								, IntakeDate [datetime]
								, DischargeDate [datetime]
								, CaseProgress [numeric](3)
								, XDateAge int
								, TCNumber int
								, MultipleBirth [char](3)
								, Missing bit
								, OutOfWindow bit
								, RecOK bit
								, CCIInterval [char](2)
								, HVCaseCreator [varchar](max)
								, HVCaseEditor [varchar](max)
									) ;

insert into @tbl4QAReport9Cohort (
								OldID	, HVCasePK, [PC1ID], TCDOB, Worker, currentLevel
								, IntakeDate, DischargeDate, CaseProgress, XDateAge, TCNumber
								, MultipleBirth, Missing, OutOfWindow, RecOK, CCIInterval
								, HVCaseCreator, HVCaseEditor
								)
select		cp.OldID
		, h.HVCasePK
		, cp.PC1ID
		, case when h.TCDOB is not null then h.TCDOB else h.EDC end as tcdob
		, ltrim(rtrim(fsw.FirstName))+' '+ltrim(rtrim(fsw.LastName)) as worker
		, codeLevel.LevelName
		, h.IntakeDate
		, cp.DischargeDate
		, h.CaseProgress
		, case
				when h.TCDOB is not null
					then datediff(dd, h.TCDOB, @LastDayofPreviousMonth)
				else datediff(dd, h.EDC, @LastDayofPreviousMonth)
			end as XDateAge
		, h.TCNumber
		, case when h.TCNumber > 1 then 'Yes' else 'No' end as [MultipleBirth]
		, 0 as Missing
		, 0 as OutOfWindow
		, 0 as RecOK
		, '' as CCIInterval
		, h.HVCaseCreator
		, h.HVCaseEditor


from		dbo.CaseProgram cp
inner join	dbo.SplitString(@programfk, ',') on cp.ProgramFK = ListItem
left join	codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
inner join	dbo.HVCase h on cp.HVCaseFK = h.HVCasePK
inner join	Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK


where		((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) and (h.IntakeDate is not null)) -- enrolled atleast 30 days as of analysis point		  
			and (cp.DischargeDate is null or cp.DischargeDate > @LastDayofPreviousMonth) --- case not closed as of analysis point
			and (((@LastDayofPreviousMonth > dateadd(d, 30, h.EDC)) and (h.TCDOB is null))
				or ((@LastDayofPreviousMonth > dateadd(d, 30, h.TCDOB)) and (h.EDC is null))
				) ; -- baby is atleast 30 days old as of analysis point





-- to get accurate count of case
update @tbl4QAReport9Cohort set TCNumber = 1 where TCNumber = 0 ;


--SELECT * FROM @tbl4QAReport9Cohort
--ORDER BY OldID


-- Equivelent to csrForm6 in foxpro	
--SELECT DISTINCT HVCasePK  FROM @tbl4QAReport9Cohort
----------SELECT * FROM @tbl4QAReport9Cohort  -- Equivelent to csrForm6 in foxpro
----------ORDER BY HVCasePK

---***********************************************************************************************
--*************************************************************************************************
--- rspQAReport9 8 ,'summary'

declare @tbl4QAReport9 table (
							HVCasePK int
						, [PC1ID] [char](13)
						, TCDOB [datetime]
						, Worker [varchar](200)
						, currentLevel [varchar](50)
						, IntakeDate [datetime]
						, DischargeDate [datetime]
						, CaseProgress [numeric](3)
						, XDateAge int
						, TCNumber int
						, MultipleBirth [char](3)
						, Missing bit
						, OutOfWindow bit
						, RecOK bit
						, [DueBy] [int] not null
						, [Interval] [char](2) not null
						, [MaximumDue] [int] not null
						, [MinimumDue] [int] not null
						, FormDoneDateCompleted [datetime]
						, FormNotReviewed bit
							) ;

declare @tbl4QAReport9Expected table (
									HVCasePK int
								, [PC1ID] [char](13)
								, TCDOB [datetime]
								, Worker [varchar](200)
								, currentLevel [varchar](50)
								, IntakeDate [datetime]
								, DischargeDate [datetime]
								, CaseProgress [numeric](3)
								, XDateAge int
								, TCNumber int
								, MultipleBirth [char](3)
								, Missing bit
								, OutOfWindow bit
								, RecOK bit
								, [DueBy] [int] not null
								, [Interval] [char](2) not null
								, [MaximumDue] [int] not null
								, [MinimumDue] [int] not null
								, FormDoneDateCompleted [datetime]
								, FormNotReviewed bit
									) ;

declare @tbl4QAReport9NotExpected table (
										HVCasePK int
									, [PC1ID] [char](13)
									, TCDOB [datetime]
									, Worker [varchar](200)
									, currentLevel [varchar](50)
									, IntakeDate [datetime]
									, DischargeDate [datetime]
									, CaseProgress [numeric](3)
									, XDateAge int
									, TCNumber int
									, MultipleBirth [char](3)
									, Missing bit
									, OutOfWindow bit
									, RecOK bit
									, [DueBy] [int] not null
									, [Interval] [char](2) not null
									, [MaximumDue] [int] not null
									, [MinimumDue] [int] not null
									, FormDoneDateCompleted [datetime]
									, FormNotReviewed bit
										) ;


declare @tbl4QAReport9Interval table (HVCasePK int, Interval char(2)) ;


insert into @tbl4QAReport9Interval (HVCasePK, Interval)
select		qa1.HVCasePK
		, max(Interval) as Interval

from		@tbl4QAReport9Cohort qa1
inner join	codeDueByDates on ScheduledEvent = 'CHEERS' and XDateAge >= DueBy
group by	HVCasePK ;


--SELECT * FROM @tbl4QAReport9Interval


-- get expected records that are due for the Interval
insert into @tbl4QAReport9Expected (
									HVCasePK, [PC1ID], TCDOB, Worker, currentLevel, IntakeDate
								, DischargeDate, CaseProgress, XDateAge, TCNumber, MultipleBirth
								, Missing, OutOfWindow, RecOK, [DueBy], [Interval], [MaximumDue]
								, [MinimumDue], FormDoneDateCompleted, FormNotReviewed
								)
select		qa1.HVCasePK
		, PC1ID
		, TCDOB
		, Worker
		, currentLevel
		, IntakeDate
		, DischargeDate
		, CaseProgress
		, XDateAge
		, qa1.TCNumber
		, qa1.MultipleBirth
		, 0 as Missing
		, case when (ObservationDate is not null 
						and ObservationDate not between dateadd(dd, cd.MinimumDue, TCDOB) 
							and dateadd(dd, cd.MaximumDue, TCDOB)) then 1 else 0 end as OutOfWindow
		, case when (ObservationDate is not null 
						and ObservationDate not between dateadd(dd, cd.MinimumDue, TCDOB) 
							and dateadd(dd, cd.MaximumDue, TCDOB)) then 0 else 1 end as RecOK
		, cd.[DueBy]
		, cd.[Interval]
		, cd.[MaximumDue]
		, cd.[MinimumDue]
		, ObservationDate as FormDoneDateCompleted
		, case
				when dbo.IsFormReviewed(ObservationDate, 'CC', CheersCheckInPK) = 1
					then 0
				else 1
			end as FormNotReviewed
from		@tbl4QAReport9Cohort qa1
inner join	@tbl4QAReport9Interval cteIn on qa1.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next, which we just added
inner join	codeDueByDates cd on ScheduledEvent = 'CHEERS' and cteIn.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
-- The following line gets those tcid's with CHEERS Check Ins that are due for the Interval
inner join	CheersCheckIn cci on HVCaseFK = cteIn.HVCasePK and cci.Interval = cteIn.Interval
order by	HVCasePK ;

--- rspQAReport9 8 ,'summary'
--SELECT * FROM @tbl4QAReport9Expected

-- missing CHEERS Check Ins
-- get expected records that are due for the Interval
insert into @tbl4QAReport9NotExpected (
									HVCasePK, [PC1ID], TCDOB, Worker, currentLevel, IntakeDate
									, DischargeDate, CaseProgress, XDateAge, TCNumber
									, MultipleBirth, Missing, OutOfWindow, RecOK, [DueBy]
									, [Interval], [MaximumDue], [MinimumDue]
									, FormDoneDateCompleted, FormNotReviewed
									)
select		qa2.HVCasePK
		, qa2.PC1ID
		, qa2.TCDOB
		, qa2.Worker
		, qa2.currentLevel
		, qa2.IntakeDate
		, qa2.DischargeDate
		, qa2.CaseProgress
		, qa2.XDateAge
		, qa2.TCNumber
		, qa2.MultipleBirth
		, 1 as Missing
		, qa2.OutOfWindow
		, qa2.RecOK
		, cd.[DueBy]
		, cteIn.[Interval]
		, cd.[MaximumDue]
		, cd.[MinimumDue]
		, FormDoneDateCompleted
		, null as FormNotReviewed

from		@tbl4QAReport9Cohort qa2

left join	@tbl4QAReport9Interval cteIn on qa2.HVCasePK = cteIn.HVCasePK -- we will use column 'Interval' next		
left join	@tbl4QAReport9Expected exp on exp.HVCasePK = qa2.HVCasePK
inner join	codeDueByDates cd on ScheduledEvent = 'CHEERS' and cteIn.[Interval] = cd.Interval -- to get dueby, max, min
where		exp.HVCasePK is null ;

--------------- rspQAReport9 8 ,'summary'

insert into @tbl4QAReport9
select * from @tbl4QAReport9Expected
union
select * from @tbl4QAReport9NotExpected ;



declare @tbl4QAReport9Main table (
								HVCasePK int
							, [PC1ID] [char](13)
							, TCDOB [datetime]
							, Worker [varchar](200)
							, currentLevel [varchar](50)
							, IntakeDate [datetime]
							, DischargeDate [datetime]
							, CaseProgress [numeric](3)
							, XDateAge int
							, TCNumber int
							, MultipleBirth [char](3)
							, Missing bit
							, OutOfWindow bit
							, RecOK bit
							, [DueBy] [int] not null
							, [Interval] [char](2) not null
							, [MaximumDue] [int] not null
							, [MinimumDue] [int] not null
							, FormDoneDateCompleted [datetime]
							, FormNotReviewed bit
							, FormDue [datetime]
								) ;


insert into @tbl4QAReport9Main (
								HVCasePK, PC1ID, TCDOB, Worker, currentLevel, IntakeDate
							, DischargeDate, CaseProgress, XDateAge, TCNumber, MultipleBirth
							, Missing, OutOfWindow, RecOK, [DueBy], [Interval], [MaximumDue]
							, [MinimumDue], FormDoneDateCompleted, FormNotReviewed, FormDue
							)
select	HVCasePK
	, PC1ID
	, TCDOB
	, Worker
	, currentLevel
	, IntakeDate
	, DischargeDate
	, CaseProgress
	, XDateAge
	, TCNumber
	, MultipleBirth
	, Missing
	, OutOfWindow
	, RecOK
	, [DueBy]
	, [Interval]
	, [MaximumDue]
	, [MinimumDue]
	, FormDoneDateCompleted
	, FormNotReviewed
	, case
			when (Interval = '00' and ((IntakeDate > TCDOB) and (TCDOB is not null)))
				then dateadd(dd, DueBy, IntakeDate)
			else dateadd(dd, DueBy, TCDOB)
		end as FormDue
from	@tbl4QAReport9 ;

--SELECT * FROM @tbl4QAReport9Main
--ORDER BY HVCasePK 


--- rspQAReport9 8 ,'summary'



if @ReportType = 'summary'

begin

	declare @numOfALLScreens int = 0 ;
	set @numOfALLScreens = (select count(HVCasePK)from @tbl4QAReport9Main) ;


	declare @numOfMissingCases int = 0 ;
	set @numOfMissingCases = (select count (HVCasePK)from @tbl4QAReport9Main where Missing = 1) ;

	declare @numOfOutOfWindowsORNotReviewedCases int = 0 ;
	set @numOfOutOfWindowsORNotReviewedCases = (
											select	count(HVCasePK)
											from	@tbl4QAReport9Main
											where	OutOfWindow = 1 or FormNotReviewed = 1
											) ;

	declare @numOfMissingAndOutOfWindowsCases int = 0 ;
	set @numOfMissingAndOutOfWindowsCases = (@numOfMissingCases
											+@numOfOutOfWindowsORNotReviewedCases
											) ;


	declare @tbl4QAReport9Summary table (
										[SummaryId] int
									, [SummaryText] [varchar](200)
									, [MissingCases] [varchar](200)
									, [NotOnTimeCases] [varchar](200)
									, [SummaryTotal] [varchar](100)
										) ;

	insert into @tbl4QAReport9Summary (
									[SummaryId], [SummaryText], [MissingCases]
									, [NotOnTimeCases], [SummaryTotal]
									)
	values (
			9
		, 'CHEERS Check Ins for Active Cases (N='+convert(varchar, @numOfALLScreens)+')'
		, convert(varchar, @numOfMissingCases)+' ('
		+convert(
					varchar
					, round(
							coalesce(
										cast(@numOfMissingCases as float)* 100
										/ nullif(@numOfALLScreens, 0), 0
									), 0
						)
				)+'%)'
		, convert(varchar, @numOfOutOfWindowsORNotReviewedCases)+' ('
		+convert(
					varchar
					, round(
							coalesce(
										cast(@numOfOutOfWindowsORNotReviewedCases as float)* 100
										/ nullif(@numOfALLScreens, 0), 0
									), 0
						)
				)+'%)'
		, convert(varchar, @numOfMissingAndOutOfWindowsCases)+' ('
		+convert(
					varchar
					, round(
							coalesce(
										cast(@numOfMissingAndOutOfWindowsCases as float)* 100
										/ nullif(@numOfALLScreens, 0), 0
									), 0
						)
				)+'%)'

		) ;

	select * from @tbl4QAReport9Summary ;

end ;
else begin


	select		PC1ID
			, EventDescription as IntervalDue
			--, qam.Interval		 
			, convert(varchar(10), FormDue, 101) as FormDue
			, convert(varchar(10), FormDoneDateCompleted, 101) as FormDoneDateCompleted
			, convert(varchar(10), TCDOB, 101) as TCDOB
			, Worker
			, FormNotReviewed
			, Missing
			, OutOfWindow
			, currentLevel
	from		@tbl4QAReport9Main qam
	inner join	codeDueByDates cdd on ScheduledEvent = 'CHEERS' and cdd.Interval = qam.Interval
	where		(Missing = 1 or OutOfWindow = 1 or FormNotReviewed = 1)
	order by	Worker
			, PC1ID ;


end ;

--- rspQAReport9 1 ,'summary'
GO
