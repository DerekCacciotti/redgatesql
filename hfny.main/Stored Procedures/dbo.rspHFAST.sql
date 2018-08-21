SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[rspHFAST]-- Add the parameters for the stored procedure here
(
    @sDate as datetime,
	@eDate as datetime,
	@programfk  as VARCHAR(MAX)
)
as
begin
	set nocount on;
	IF @programfk IS NULL begin
		select @programfk = 
			substring((select ',' + ltrim(rtrim(str(HVProgramPK))) 
						from HVProgram
						for xml path('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	declare @tblFinalExport as table(
	RowNumber int
	, ItemNumber varchar(4)
	, Item varchar(max)
	, Response varchar(max)
	, Header bit
	)

	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(1, 'B2', 'Number of home visits completed in 2017', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(2, 'B3', 'How many PEOPLE worked in Assessment role at the end of last year?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(3, 'B4', 'What was your total FTEs in Family Assessment Worker?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(4, 'B5', 'How many PEOPLE worked in Home Visitor role at the end?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(5, 'B6', 'What was your total FTEs in Home Visitor role?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(6, 'B8', 'Etnnicity: Number of Home Visitors who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(7, 'B8', 'Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(8, 'B8', 'Non-Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(9, 'B8', 'Ethnicity Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(10, 'B9', 'Race: Number of Home Visitors who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(11, 'B9', 'White', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(12, 'B9', 'African-American', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(13, 'B9', 'Asian', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(14, 'B9', 'American Indian/Alaskan Native', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(15, 'B9', 'Native Hawaiian/Pacific Islander', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(16, 'B9', 'Multi-race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(17, 'B9', 'Race Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(18, 'B9', 'Other Race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(19, NULL, 'How many families:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(20, 'B10', 'Received at least 1 home visit?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(21, 'B11', 'Were MIECHV funded (at least 25%)?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(22, 'B12', 'Received their first home visit?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(23, 'B13', 'Received their first home visit prenatally?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(24, 'B14', 'Received their first home visit prenatally before 31 weeks?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(25, 'B15', 'With a father involved in home visiting (attended more than 1)?', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(26, 'B16', 'Number of target children served', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(27, 'B17', 'Number of non-target children served', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(28, NULL, 'How many primary participants were:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(29, 'B18', 'Female', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(30, 'B19', 'Male', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(31, 'B20', 'Gender Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(32, 'B21', 'First time parent', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(33, 'B22', 'Grandparent of target child', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(34, 'B23', 'HS graduate/GED or higher at enrollment', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(35, 'B24', 'Less than HS Graduate/GED at enrollment', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(36, 'B25', 'Education Level Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(37, 'B26', 'Developmentally delayed', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(38, 'B27', 'Medicaid Eligible', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(39, 'B28', 'Military personnel or spouse', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(40, 'B29', 'Have substance abuse history', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(41, 'B30', 'In need of substance abuse treatment', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(42, 'B31', 'Abused or neglected as a child', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(43, 'B32', 'Involved in Child Welfare System as caregiver', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(44, 'B33', 'Single parent', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(45, 'B34', 'Over cutoff on depression screen', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(46, 'B35', 'Insurance Status of PC1 (when last assessed)', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(47, 'B35', 'No insurance', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(48, 'B35', 'Title XIX (Meicaid) / Title XXI (SCHIP) or Tri-Care', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(49, 'B35', 'Private or other insurance', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(50, 'B35', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(51, 'B35', 'Insurance Status of TC (when last assessed)', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(52, 'B35', 'No insurance', 0)	
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(53, 'B35', 'Title XIX (Meicaid) / Title XXI (SCHIP) or Tri-Care', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(54, 'B35', 'Private or other insurance', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(56, 'B35', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(57, 'B36', 'Housing Status of PC1 (when last assessed)', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(58, 'B36', 'renting or own home', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(59, 'B36', 'living with parent or family member', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(60, 'B36', 'sharing housing', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(61, 'B36', 'homeless', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(62, 'B36', 'unknown housing situation', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(63, 'B37', 'PC1 employment status', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(64, 'B37', 'employed full time', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(65, 'B37', 'employed part time', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(66, 'B37', 'not employed (whether seeking work or not)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(67, 'B37', 'unknown employment situation', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(68, 'B40', 'How many PC1s were', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(69, 'B40', 'Low risk on Initial Assessment(Parent Survey < 25', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(70, 'B40', 'Medium risk on Initial Assessment(Parent Survey 25-35)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(71, 'B40', 'Higher risk on Initial Assessment(Parent Survey 40+)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(72, 'B41', 'TC age at Last Home Visit', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(73, 'B41', '0-5 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(74, 'B41', '6-11 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(75, 'B41', '12-23 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(76, 'B41', '24-35 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(77, 'B41', '36 months or older', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(78, 'B41', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(79, 'B42', 'Child Issues: Number of children who were', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(80, 'B42', 'Born at low birth weight, less than 2500 grams or 5lbs 8oz', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(81, 'B42', 'Born premature, born before 37 weeks completed', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(82, 'B42', 'Developmentally delayed or disalbed (known or suspected)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(83, 'B42', 'Medicaid eligible', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(84, 'B43', 'PC1 Age at Enrollment', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(85, 'B43', 'Less than 18', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(86, 'B43', '18-19', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(87, 'B43', '20-21', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(88, 'B43', '22-24', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(89, 'B43', '25-34', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(90, 'B43', '35-54', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(91, 'B43', '55 or more', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(92, 'B43', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(93, 'B44', 'Ethnicity: Number of Primary Participants who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(94, 'B44', 'Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(95, 'B44', 'Non-Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(96, 'B44', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(97, 'B45', 'Race: Number of Primary Participants who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(98, 'B45', 'White', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(99, 'B45', 'African-American', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(100, 'B45', 'Asian', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(101, 'B45', 'American Indian/Alaskan Native', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(102, 'B45', 'Native Hawaiian/Pacific Islander', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(103, 'B45', 'Multi-race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(104, 'B45', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(105, 'B45', 'Other race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(106, 'B45', 'Other race specify', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(107, 'B46', 'Primary Participant Language', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(108, 'B46', 'Primary Language English', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(109, 'B46', 'Primary Language Spanish', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(110, 'B46', 'Primary Language not English nor Spanish', 0)

	--B2 row 1
	--Number of home visits completed
	declare @hvLogCount int
	set @hvLogCount = ( select count(hvlogpk) 
						from dbo.HVLog hl
						inner join dbo.CaseProgram cp on cp.HVCaseFK = hl.HVCaseFK
						inner join dbo.SplitString(@programfk,',') ON hl.programfk  = listitem
						where hl.VisitStartTime between @sDate and @eDate
						      and substring(hl.VisitType, 4, 1) <> '1');
	update @tblFinalExport set Response = @hvLogCount where [@tblFinalExport].RowNumber = 1 
	--End B2--

	--B3 - B9 Cohort
	declare @tblWorkers as table (
		WorkerProgramPK int
		,FAWStartDate date
		,FAWEndDate date
		,FSWStartDate date
		,FSWEndDate date
		,FTE numeric(5,2)
		,Race varchar(max)
		,RaceSpecify varchar(max)
	)
	insert into @tblWorkers
		(
		  WorkerProgramPK
		, FAWStartDate
		, FAWEndDate
		, FSWStartDate
		, FSWEndDate
		, FTE
		, Race
		, RaceSpecify
		)	
	select WorkerProgramPK
		, FAWStartDate
		, FAWEndDate
		, FSWStartDate
		, FSWEndDate
		, case FTE
			when '01' then 1.0
			when '02' then 0.5
			when '03' then 0.25
		  end as FTE
		, Race
		, RaceSpecify
		from dbo.WorkerProgram wp
		inner join dbo.Worker w on w.WorkerPK = wp.WorkerFK
		inner join dbo.SplitString(@programfk,',') ON wp.programfk  = listitem
		and 
		(
			(wp.FAWStartDate < @eDate and (wp.FAWEndDate is null or wp.FAWEndDate > @eDate))
			or
			(wp.FSWStartDate < @eDate and (wp.FSWEndDate is null or wp.FSWEndDate > @eDate))
		)

		--Cohort  All home visit logs for cases that had a home visit in given year
	declare @tblHomeVisits as table (
		hvcasefk int index idx1 nonClustered
		,VisitStartTime date
		,PC1ID varchar(13)
		,TCDOB date
		,EDC date
		,DischargeDate date
		,FatherFigureParticipated bit
		,TCNumber int
		,RowNum int
	)
	--Cohort All home visits for cases that had a home visit in given year
	insert into @tblHomeVisits(
	  hvcasefk
	, VisitStartTime
	, PC1ID
	, TCDOB
	, EDC
	, DischargeDate
	, FatherFigureParticipated
	, RowNum
	)
	select hv.hvcasefk
	      , hv.VisitStartTime
		  , cp.PC1ID
		  , hc.TCDOB
		  , hc.EDC
		  , DischargeDate
		  , hv.FatherFigureParticipated	  
		  , row_number() over(partition by hv.hvcasefk order by hv.VisitStartTime asc)
	from hvlog hv
	inner join dbo.SplitString(@programfk,',') on hv.programfk  = listitem
	inner join dbo.HVCase hc on hc.HVCasePK = hv.HVCaseFK
	inner join dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK
	WHERE substring(VisitType, 4, 1) <> '1'
	      and hv.hvcasefk in (select hvcasefk from hvlog where VisitStartTime BETWEEN @sDate AND @eDate)
	
	--B3 row 2
	--Number of people who worked in assessment role at the end of the year
	declare @fawCount int
	set @fawCount = ( select count(workerprogrampk) 
					  from @tblWorkers 
					  where [@tblWorkers].FAWStartDate < @eDate 
							and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
	update @tblFinalExport set Response = @fawCount where [@tblFinalExport].RowNumber = 2
	--End B3--

	--B4 row 3
	--Total FTEs in FAW Role
	declare @fawFTE numeric(5,2)
	set @fawFTE = ( select sum([@tblWorkers].FTE) 
					from @tblWorkers 
					where [@tblWorkers].FAWStartDate < @eDate 
							and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
    update @tblFinalExport set Response = @fawFTE where [@tblFinalExport].RowNumber = 3
	--End B4

	--B5 row 4
	--Number of people who worked in home visitor role at the end of the year
	declare @fswCount int
	set @fswCount = ( select count(workerprogrampk) 
					  from @tblWorkers 
					  where [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
	update @tblFinalExport set Response = @fswCount where [@tblFinalExport].RowNumber = 4
	--End B5

	--B6 row 5
	--Total FTEs in FSW Role
	declare @fswFTE numeric(5,2)
	set @fswFTE = ( select sum([@tblWorkers].FTE) 
					from @tblWorkers 
					where [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
    update @tblFinalExport set Response = @fswFTE where [@tblFinalExport].RowNumber = 5
	--End B6

	--B8 row 7
	--Number of Hispanic Home Visitors
	declare @HispanicFSW int
	set @HispanicFSW = ( select count(Race) 
						 from @tblWorkers
						 where Race = '03'
						 and (
								[@tblWorkers].FSWStartDate < @eDate 
								and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							  ) 
						) 
	update @tblFinalExport set Response = @HispanicFSW where RowNumber = 7

	--B8 row 8
	--Number of Non Hispanic Home Visitors
	declare @NonHispanicFSW int
	set @NonHispanicFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race <> '03'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @NonHispanicFSW where RowNumber = 8

	--B8 row 9 
	--Home Visitors ethnicity unknown
	declare @UnknownEthnicityFSW int
	set @UnknownEthnicityFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race is Null
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @UnknownEthnicityFSW where RowNumber = 9
	--end B8

	--B9 row 11
	--Number of white FSWs
	declare @WhiteFSW int
	set @WhiteFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '01'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @WhiteFSW where RowNumber = 11

	--B9 row 12
	--Number of black FSWs
	declare @AfAmFSW int
	set @AfAmFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '02'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @AfAmFSW where RowNumber = 12

	--B9 row 13
	--Number of Asian FSWs
	declare @AsianFSW int
	set @AsianFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '04'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @AsianFSW where RowNumber = 13

	--B9 row 14
	--Number of Native American FSWs
	declare @NativeFSW int
	set @NativeFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '05'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @NativeFSW where RowNumber = 14

	--B9 row 16
	--Number of Multi Race FSWs
	declare @MultiFSW int
	set @MultiFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '06'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @MultiFSW where RowNumber = 16

	--B9 row 17
	--Number of Multi Race FSWs
	declare @UnknownRaceFSW int
	set @UnknownRaceFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race is null
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @UnknownRaceFSW where RowNumber = 17

	--B9 row 18
	--Number of other race FSWs
	declare @OtherRaceFSW int
	set @OtherRaceFSW = ( select count(Race) 
					        from @tblWorkers
						    where Race = '07'
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @OtherRaceFSW where RowNumber = 18
	--end B9

	
	      
		  
	--B10 row 20
	declare @visitReceived int
	set @visitReceived = ( select count(distinct hvcasefk) from @tblHomeVisits where VisitStartTime BETWEEN @sDate AND @eDate )
	update @tblFinalExport set Response = @visitReceived where RowNumber = 20
	--End B10
	

	--B12 row 22
	declare @firstHomeVisit int
	set @firstHomeVisit = (select count(hvcasefk) from @tblHomeVisits
						   where RowNum = 1 and VisitStartTime between @sDate and @eDate)
	update @tblFinalExport set Response = @firstHomeVisit where RowNumber = 22
	--End B12

	--B13 row 23
	declare @firstHomeVisitPrenatal int
	set @firstHomeVisitPrenatal = (select count(hvcasefk) from @tblHomeVisits
						   where RowNum = 1 
						   and VisitStartTime between @sDate and @eDate
						   and EDC is not null)
	update @tblFinalExport set Response = @firstHomeVisitPrenatal where RowNumber = 23
	--End B13

	--B14 row 24
	declare @firstHomeVisitPrenatal31 int
	set @firstHomeVisitPrenatal31 = (select count(hvcasefk) from @tblHomeVisits
						   where RowNum = 1 
						   and VisitStartTime between @sDate and @eDate
						   and dateadd(week, -9 , EDC) >= VisitStartTime) 
	update @tblFinalExport set Response = @firstHomeVisitPrenatal31 where RowNumber = 24
    --End B14

	--B15 row 25
	declare @HomeVisitsWithFF int
	set @HomeVisitsWithFF = ( select count(sub.hvcasefk) from
							  (  select hvcasefk
									,VisitStartTime
									,FatherFigureParticipated
									,row_number() over (partition by hvcasefk order by VisitStartTime asc) as [row]						   
							     from @tblHomeVisits
							     where VisitStartTime between @sDate and @eDate
								       and FatherFigureParticipated = 1
							   ) as sub
							   where sub.[row] = 2
							)
	update @tblFinalExport set Response = @HomeVisitsWithFF where RowNumber = 25
	--End B15

	--B16 row 26
	declare @countTC int
	set @countTC = ( select sum(TCNumber) 
	                 from dbo.HVCase hc
					 where hc.HVCasePK in
					    ( select distinct hvcasefk 
						  from @tblHomeVisits thv
						  where thv.VisitStartTime between @sDate and @eDate
				        )
				   ) +
				   ( select count(EDC) from @tblHomeVisits thv
						  where thv.VisitStartTime between @sDate and @eDate 
						  and TCNumber is null
				   ) 
	update @tblFinalExport set Response = @countTC where RowNumber = 26
	--End B16

	--B17 row 27
	declare @countOtherChildren int
	set @countOtherChildren = ( select count(oc.OtherChildPK)
								from OtherChild oc 
								where oc.HVCaseFK in 
								( select distinct hvcasefk from @tblHomeVisits thv
								  where thv.VisitStartTime between @sDate and @eDate)
							  )
	update @tblFinalExport set Response = @countOtherChildren where RowNumber = 27
	--End B17

	--B18 row 29
	declare @countFemale int
	set @countFemale = ( select count(pc1fk)
						 from hvcase
						 inner join dbo.PC p on p.PCPK = HVCase.PC1FK
						 where p.Gender = '01'
						  and hvcasepk in ( 
						   select distinct hvcasefk from @tblHomeVisits thv
						   where thv.VisitStartTime between @sDate and @eDate
						 )
					   )
	update @tblFinalExport set Response = @countFemale where RowNumber = 29
	--End B18

	--B19 row 30
	declare @countMale int
	set @countMale = ( select count(pc1fk)
						 from hvcase
						 inner join dbo.PC p on p.PCPK = HVCase.PC1FK
						 where p.Gender = '02'
						  and hvcasepk in ( 
						   select distinct hvcasefk from @tblHomeVisits thv
						   where thv.VisitStartTime between @sDate and @eDate
						 )
					   )
	update @tblFinalExport set Response = @countMale where RowNumber = 30

select * from @tblFinalExport
end
GO
