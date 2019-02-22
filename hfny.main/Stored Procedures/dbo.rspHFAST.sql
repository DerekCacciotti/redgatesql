SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[rspHFAST]
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
	, PCID_Response char(13)
	, Header bit
	, Detail bit
	)

	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(1, 'B2', 'Number of home visits completed:', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(2, 'B3', 'How many PEOPLE worked in Assessment role at the end of last year?', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(3, 'B4', 'What was your total FTEs in Family Assessment Worker?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(4, 'B5', 'How many PEOPLE worked in Home Visitor role at the end?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(5, 'B6', 'What was your total FTEs in Home Visitor role?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(6, NULL, 'Ethnicity: Number of Home Visitors who are:', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(7, 'B8', 'Hispanic', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(8, 'B8', 'Non-Hispanic', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(9, 'B8', 'Ethnicity Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(10, NULL, 'Race: Number of Home Visitors who are:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(11, 'B9', 'White', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(12, 'B9', 'African-American', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(13, 'B9', 'Asian', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(14, 'B9', 'American Indian/Alaskan Native', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(15, 'B9', 'Native Hawaiian/Pacific Islander', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(16, 'B9', 'Multi-race', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(17, 'B9', 'Race Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(18, 'B9', 'Other Race', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(19, NULL, 'How many families:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(20, 'B10', 'Received at least 1 home visit?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(21, 'B11', 'Were MIECHV funded (at least 25%)?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(22, 'B12', 'Received their first home visit?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(23, 'B13', 'Received their first home visit prenatally?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(24, 'B14', 'Received their first home visit prenatally before 31 weeks?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(25, 'B15', 'With a father involved in home visiting (attended more than 1)?', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(26, 'B16', 'Number of target children served', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(27, 'B17', 'Number of non-target children served', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(28, NULL, 'How many primary participants were:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(29, 'B18', 'Female', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(30, 'B19', 'Male', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(31, 'B20', 'Gender Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(32, 'B21', 'First time parent', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(33, 'B22', 'Grandparent of target child', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(34, 'B23', 'HS graduate/GED or higher at enrollment', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(35, 'B24', 'Less than HS Graduate/GED at enrollment', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(36, 'B25', 'Education Level Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(37, 'B26', 'Developmentally delayed', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(38, 'B27', 'Medicaid Eligible', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(39, 'B28', 'Military personnel or spouse', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(40, 'B29', 'Have substance abuse history', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(41, 'B30', 'In need of substance abuse treatment', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(42, 'B31', 'Abused or neglected as a child', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(43, 'B32', 'Referred by Child Welfare as a caregiver.', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(44, 'B33', 'Single parent', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(45, 'B34', 'Over cutoff on depression screen', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(46, NULL, 'Insurance Status of PC1 (when last assessed):', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(47, 'B35', 'No insurance', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(48, 'B35', 'Title XIX (Meicaid) / Title XXI (SCHIP) or Tri-Care', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(49, 'B35', 'Private or other insurance', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(50, 'B35', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(51, NULL, 'Insurance Status of TC (when last assessed):', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(52, 'B35', 'No insurance', 0, 0)	
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(53, 'B35', 'Title XIX (Medicaid) / Title XXI (SCHIP) or Tri-Care', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(54, 'B35', 'Private or other insurance', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(55, 'B35', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(56, NULL, 'Housing Status of PC1 (when last assessed):', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(57, 'B36', 'renting or own home', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(58, 'B36', 'living with parent or family member', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(59, 'B36', 'sharing housing', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(60, 'B36', 'homeless', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(61, 'B36', 'unknown housing situation', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(62, NULL, 'PC1 employment status:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(63, 'B37', 'employed full time', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(64, 'B37', 'employed part time', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(65, 'B37', 'not employed (whether seeking work or not)', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(66, 'B37', 'unknown employment situation', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(67, NULL, 'How many PC1s were:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(68, 'B40', 'Low risk on Initial Assessment(Parent Survey < 25)', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(69, 'B40', 'Medium risk on Initial Assessment(Parent Survey 25-35)', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(70, 'B40', 'Higher risk on Initial Assessment(Parent Survey 40+)', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(71, NULL, 'TC age at Last Home Visit:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(72, 'B41', 'Prenatal', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(73, 'B41', '0-5 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(74, 'B41', '6-11 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(75, 'B41', '12-23 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(76, 'B41', '24-35 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(77, 'B41', '36-47 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(78, 'B41', '48-59 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(79, 'B41', '60-71 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(80, 'B41', '72-83 months', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(81, 'B41', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(82, NULL, 'Child Issues: Number of children who were:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(83, 'B42', 'Born at low birth weight, less than 2500 grams or 5lbs 8oz', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(84, 'B42', 'Born premature, born before 37 weeks completed', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(85, 'B42', 'Developmentally delayed or disabled (known or suspected)', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(86, 'B42', 'Medicaid eligible', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(87, NULL, 'PC1 Age at Enrollment:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(88, 'B43', 'Less than 18', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(89, 'B43', '18-19 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(90, 'B43', '20-21 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(91, 'B43', '22-24 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(92, 'B43', '25-29 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(93, 'B43', '30-34 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(94, 'B43', '35-44 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(95, 'B43', '45-54 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(96, 'B43', '55-64 years', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(97, 'B43', '65 or more', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(98, 'B43', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(99, NULL, 'Ethnicity: Number of Primary Participants who are:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(100, 'B44', 'Hispanic', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(101, 'B44', 'Non-Hispanic', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(102, 'B44', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(103, NULL, 'Race: Number of Primary Participants who are:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(104, 'B45', 'White', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(105, 'B45', 'African-American', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(106, 'B45', 'Asian', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(107, 'B45', 'American Indian/Alaskan Native', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(108, 'B45', 'Native Hawaiian/Pacific Islander', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(109, 'B45', 'Multi-race', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(110, 'B45', 'Unknown', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(111, 'B45', 'Other race', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(112, 'B45', 'Other race specify', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(113, NULL, 'Primary Participant Language:', 1, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(114, 'B46', 'Primary Language English', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(115, 'B46', 'Primary Language Spanish', 0, 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header, Detail) values(116, 'B46', 'Primary Language not English nor Spanish', 0, 0)

	

	--B3 - B9 Cohort Workers
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
		and (wp.TerminationDate is null or wp.TerminationDate > @eDate)

	--Cohort All home visit logs in period
	declare @tblHomeVisits as table (
		hvcasefk int index idx1 nonClustered
		,hvlogpk int
		,VisitStartTime date
		,FirstHomeVisit date
		,IntakeDate date
		,EDC date
		,TCDOB date
		,TCNumber int
		,PC1Participated bit
		,OBPParticipated bit
		,PCDOB date
		,Gender char(2)
		,GenderOBP char(2)
		,Race char(2)
		,Ethnicity varchar(max)
		,PC1Relation2TC int
		,RowNum int
	)

	insert into @tblHomeVisits(
	  hvcasefk
	 ,hvlogpk
	 ,VisitStartTime
	 ,IntakeDate
	 ,EDC
	 ,TCDOB
	 ,TCNumber
	 ,PC1Participated
	 ,OBPParticipated 
	 ,Gender
	 ,GenderOBP
	 ,Race
	 ,Ethnicity
	 ,PCDOB
	 ,PC1Relation2TC
	 ,RowNum
	)
	select hv.hvcasefk
	      , hv.hvlogpk
	      , hv.VisitStartTime
		  , hc.IntakeDate
		  , hc.EDC
		  , hc.TCDOB
		  , hc.TCNumber
		  , hv.PC1Participated
		  , hv.OBPParticipated 
		  , pc.Gender
		  , obp.Gender
		  , pc.Race
		  , pc.Ethnicity
		  , pc.PCDOB
		  , hc.PC1Relation2TC
		  , row_number() over(partition by hv.hvcasefk order by hv.VisitStartTime asc)
	from hvlog hv
	inner join dbo.HVCase hc on hc.HVCasePK = hv.HVCaseFK
	inner join pc on PC.PCPK = hc.PC1FK
	left join pc obp on obp.pcpk = hc.OBPFK
	inner join dbo.CaseProgram cp on cp.HVCaseFK = hc.HVCasePK
	inner join dbo.SplitString(@programfk,',') on hv.programfk  = listitem

	WHERE substring(VisitType, 4, 1) <> '1'
	      and VisitStartTime BETWEEN @sDate AND @eDate
		  AND cp.TransferredtoProgramFK IS NULL -- Weed out transfer cases
    option (OPTIMIZE FOR (@sDate UNKNOWN, @eDate UNKNOWN))	

	--Cohort - Current PC1IDs - removes duplicates eg. transfer back and forth
	declare @tblPC1IDs as table (
		hvcasefk int index idx1 nonClustered
		,PC1ID char(13)
	)
	insert into @tblPC1IDs (
		hvcasefk
		, PC1ID
	)
	select sub.hvcasefk,
		   sub.PC1ID
	from
	(select PC1ID
		, thv.hvcasefk
		,row_number() over (partition by thv.hvcasefk order by cp.CaseStartDate desc) as [row]
    from caseprogram cp
	inner join @tblHomeVisits thv on thv.hvcasefk = cp.HVCaseFK 
	) as sub
	where sub.[row] = 1

	--add first home visit date to cohort
	Declare @tblFirstVisit as table (
		hvcasefk int index idx1 nonClustered
	  , FirstHomeVisit date
	);

	Insert Into @tblFirstVisit
	 (hvcasefk
	 , FirstHomeVisit
	 )
	SELECT DISTINCT hl.hvcasefk, MIN(hl.VisitStartTime)
	from dbo.HVLog hl
	inner join @tblHomeVisits thv on thv.hvcasefk = hl.HVCaseFK
	group by hl.hvcasefk

	update @tblHomeVisits
	 set FirstHomeVisit = tfv.FirstHomeVisit
     from @tblHomeVisits thv
	 inner join @tblFirstVisit tfv on tfv.hvcasefk = thv.hvcasefk
	
	--Cohort last home visit in period
	declare @tblLastHomeVisit as table (
		    hvcasefk int index idx1 nonClustered
	      , VisitStartTime date
		  , EDC date
		  , TCDOB date
		  , TCNumber int
		  , Gender char(2)
	)
	insert into @tblLastHomeVisit (
		hvcasefk
		, VisitStartTime
		, EDC
		, TCDOB
		, TCNumber
		, Gender
	)
	select sub.hvcasefk
		   ,sub.VisitStartTime
		   ,sub.EDC
		   ,sub.TCDOB
		   ,sub.TCNumber
		   ,sub.Gender
    from(
	select thv.hvcasefk
	       , VisitStartTime
		   , EDC
		   , TCDOB
		   , TCNumber
		   , Gender
		   , row_number() over (partition by thv.hvcasefk order by thv.VisitStartTime desc) [row]
	from @tblHomeVisits thv) sub
	where sub.row = 1

	--Cohort Parity
	declare @tblParity as table (
		hvcasefk int index idx1 nonClustered
		,Parity int
		,KempeDate date
		,TCDOB date
	)
	insert into @tblParity (
		hvcasefk
		, Parity
		, KempeDate
		, TCDOB
	)
	select ca.HVCaseFK
		   ,ca.Parity as ParityKE
		   ,ca.FormDate as KempeDate
		   ,thv.TCDOB
		    from dbo.CommonAttributes ca
			inner join @tblHomeVisits thv on thv.hvcasefk = ca.HVCaseFK
	where ca.formtype = 'KE'
	
	--Cohort Intake Info
	declare @tblIntakeInfo as table (
		hvcasefk int index idx1 nonClustered
		,HighestGrade char(2)
		,MaritalStatus char(2)
		,PrimaryLanguage char(2)
		,PC1FamilyArmedForces char(1)
	)
	insert into @tblIntakeInfo (
	    hvcasefk
		,HighestGrade
		,MaritalStatus
		,PrimaryLanguage
		,PC1FamilyArmedForces	
	)

	select intake.hvcasefk
		, HighestGrade
		, MaritalStatus
		, PrimaryLanguage
		, PC1FamilyArmedForces
    from dbo.CommonAttributes
	inner join intake on Intake.HVCaseFK = CommonAttributes.HVCaseFK and Intake.IntakePK = CommonAttributes.FormFK
	where formtype = 'IN-PC1'
	and intake.hvcasefk in (select hvcasefk from @tblHomeVisits) 

	--Cohort followups for this years cases
	declare @tblFollowUpInfo as table (
		hvcasefk int index idx1 nonClustered
		,FollowUpPK int
		,FollowUpDate date
		,DevelopmentalDisability char(1)
		,SubstanceAbuse char(1)
		,PC1FamilyArmedForces char(1)
		,RowNum int
	)
	insert into @tblFollowUpInfo (
		hvcasefk
		, FollowUpPK
		, FollowUpDate
		, DevelopmentalDisability
		, SubstanceAbuse
		, PC1FamilyArmedForces
		, RowNum
	)
	select  fu.hvcasefk
		   ,fu.FollowUpPK
		   ,fu.FollowUpDate
		   ,pci.DevelopmentalDisability
		   ,pci.SubstanceAbuse
		   ,fu.PC1FamilyArmedForces
		   ,row_number() over (partition by fu.hvcasefk order by fu.FollowUpDate desc)
	from dbo.FollowUp fu
	inner join dbo.PC1Issues pci on pci.PC1IssuesPK = fu.PC1IssuesFK
	where fu.hvcasefk in (select hvcasefk from @tblHomeVisits)

	--Cohort Kempe Info
	declare @tblKempeInfo as table (
		hvcasefk int index idx1 nonClustered
		,PC1Neglected char(1)
		,PC1PhysicallyAbused char(1)
		,PC1SexuallyAbused char(1)
		,MomScore char(3)
		,DadScore char(3)

	)
	insert into @tblKempeInfo (
		hvcasefk
		, PC1Neglected
		, PC1PhysicallyAbused
		, PC1SexuallyAbused
		, MomScore
		, DadScore 
	)
	select distinct
	     hvcasefk
		,PC1Neglected
		,PC1PhysicallyAbused
		,PC1SexuallyAbused
		, MomScore
		, DadScore 
	from Kempe
	where hvcasefk in (select hvcasefk from @tblHomeVisits)
	
	--Cohort PC1 Health Insurance assessments in given year
	declare @tblPC1Insurance as table (
		 FormDate date 
	   , HIFamilyChildHealthPlus bit
	   , HIOther bit
	   , HIPCAP bit
	   , HIPrivate bit
	   , HIUninsured bit
	   , HIUnknown bit
	   , HVCaseFK int
	   , NumberInHouse int
	   , AvailableMonthlyIncome numeric(5,0)
	   , PBEmergencyAssistance char(1)
	   , PBFoodStamps char(1)
	   , PBSSI char(1)
	   , PBTANF char(1)
	   , PBWIC char(1)
	   , PC1ReceivingMedicaid bit
	   , RowNum int
	)
	insert into @tblPC1Insurance (
		FormDate 
	   , HIFamilyChildHealthPlus
	   , HIOther
	   , HIPCAP
	   , HIPrivate
	   , HIUninsured
	   , HIUnknown
	   , HVCaseFK
	   , NumberInHouse
	   , AvailableMonthlyIncome
	   , PBEmergencyAssistance
	   , PBFoodStamps
	   , PBSSI
	   , PBTANF
	   , PBWIC
	   , PC1ReceivingMedicaid
	   , RowNum 
	)
	select ca.FormDate
	   , ca.HIFamilyChildHealthPlus
	   , ca.HIOther
	   , ca.HIPCAP
	   , ca.HIPrivate
	   , ca.HIUninsured
	   , ca.HIUnknown
	   , ca.HVCaseFK
	   , ca.NumberInHouse
	   , ca.AvailableMonthlyIncome
	   , ca.PBEmergencyAssistance
	   , ca.PBFoodStamps
	   , ca.PBSSI
	   , ca.PBTANF
	   , ca.PBWIC
	   , ca2.PC1ReceivingMedicaid
	   , row_number() over (partition by ca.hvcasefk order by ca.FormDate desc) as [row]  
	   from commonattributes ca
	   inner join @tblHomeVisits thv on thv.hvcasefk = ca.hvcasefk
	   inner join commonattributes ca2 on  ca2.FormType = 'FU-PC1' and ca.FormFK = ca2.FormFK
	   where ca.FormType in ('FU', 'IN', 'KE')
	  and ca.FormDate between @sdate and @edate

	--Cohort TC Health insurance assessments in given year
	declare @tblTCInsurance as table (
		HVCaseFK int index idx1 nonClustered
		,FormDate date
		,TCHIFamilyChildHealthPlus bit
		,TCHIPrivateInsurance bit
		,TCHIOther bit
		,TCHIUninsured bit
		,TCHIUnknown bit
		,TCReceivingMedicaid char(1)
		,TCNumber int
		,RowNum int
	)
	insert into @tblTCInsurance (
	      HVCaseFK
		, FormDate
		, TCHIFamilyChildHealthPlus
		, TCHIPrivateInsurance
		, TCHIOther
		, TCHIUninsured
		, TCHIUnknown
		, TCReceivingMedicaid
		, TCNumber
		, RowNum
		)
	select ca.HVCaseFK
	    , FormDate
		, TCHIFamilyChildHealthPlus
		, TCHIPrivateInsurance
		, TCHIOther
		, TCHIUninsured
		, TCHIUnknown
		, TCReceivingMedicaid
		, hc.TCNumber
		, row_number() over (partition by ca.hvcasefk order by ca.FormDate desc)
	from dbo.CommonAttributes ca
	inner join HVCase hc on hc.HVCasePK = ca.HVCaseFK
	inner join @tblHomeVisits thv on thv.hvcasefk = ca.HVCaseFK
	where FormType in ('TC', 'FU') and FormDate between @sDate and @eDate

--Cohort TC Birth Info
    declare @tblTCBirthInfo as table (
		hvcasefk int index idx1 nonClustered
		,TCDOB date
		,BirthWtLbs int
		,BirthWtOz int
		,GestationalAge int
	)
	insert into @tblTCBirthInfo (
		hvcasefk
		, TCDOB
		, BirthWtLbs
		, BirthWtOz
		, GestationalAge
	)
	select t.hvcasefk
		   ,t.TCDOB
		   , BirthWtLbs
		   , BirthWtOz
		   , GestationalAge
	from dbo.TCID t 
	inner join @tblPC1IDs tpid on tpid.hvcasefk = t.HVCaseFK
	
--Cohort Living Arrangement assessments in given year
	declare @tblLivingArrangement as table (
		hvcasefk int index idx1 nonClustered
		,LivingArrangement char(2)
		,LivingArrangementSpecific char(2)
		,FormDate date
		,RowNum int
	)
	insert into @tblLivingArrangement (
		hvcasefk
		, LivingArrangement
		, LivingArrangementSpecific
		, FormDate
		, RowNum
	)
	select ca.hvcasefk
		,LivingArrangement
		,LivingArrangementSpecific
		,FormDate
		,row_number() over(partition by ca.hvcasefk order by FormDate desc)
		from dbo.CommonAttributes ca
		inner join @tblHomeVisits thv on thv.hvcasefk = ca.HVCaseFK
		where ca.FormType in ('IN', 'FU')

--Cohort Employment assessments in given year
	declare @tblEmployment as table (
		hvcasefk int index idx1 nonClustered
		,EmploymentMonthlyHours int
		,IsCurrentlyEmployed char(1)
		,FormDate date
		,RowNum int
	)
	insert into @tblEmployment (
		hvcasefk
		, EmploymentMonthlyHours
		, IsCurrentlyEmployed
		, FormDate	
		, RowNum	
	)
	select thv.hvcasefk
		, EmploymentMonthlyHours
		, IsCurrentlyEmployed
		, ca.FormDate	
		,row_number() over(partition by thv.hvcasefk order by ca.FormDate desc)
	from @tblPC1IDs thv	
	left join dbo.CommonAttributes ca on thv.hvcasefk = ca.HVCaseFK
	left join Employment e on e.FormFK = ca.FormFK
	where ca.FormType in ('FU-PC1', 'IN-PC1', 'KE')

	--Referral Source
	declare @tblReferrals as table (
		hvcasefk int index idx1 nonClustered
		,ReferralSource char(2)
	)
	insert into @tblReferrals (hvcasefk, ReferralSource)
	select hv.hvcasefk ,
		   ReferralSource
	from hvscreen hv
	inner join @tblPC1IDs tpid on tpid.hvcasefk = hv.HVCaseFK

				
--B2 row 1
	--Number of home visits completed
	declare @hvLogCount int
	set @hvLogCount = ( select count(hvcasefk) 
						from @tblHomeVisits thv
						where thv.VisitStartTime between @sDate and @eDate
						)
	update @tblFinalExport set Response = @hvLogCount where [@tblFinalExport].RowNumber = 1 
--end B2--

--B3 row 2
	--Number of people who worked in assessment role at the end of the year
	declare @fawCount int
	set @fawCount = ( select count(workerprogrampk) 
					  from @tblWorkers 
					  where [@tblWorkers].FAWStartDate < @eDate 
							and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
	update @tblFinalExport set Response = @fawCount where [@tblFinalExport].RowNumber = 2
--end B3--

--B4 row 3
	--Total FTEs in FAW Role
	declare @fawFTE numeric(5,2)
	set @fawFTE = ( select sum([@tblWorkers].FTE) 
					from @tblWorkers 
					where [@tblWorkers].FAWStartDate < @eDate 
							and ([@tblWorkers].FAWEndDate is null or [@tblWorkers].FAWEndDate > @eDate))
    update @tblFinalExport set Response = @fawFTE where [@tblFinalExport].RowNumber = 3
--end B4

--B5 row 4
	--Number of people who worked in home visitor role at the end of the year
	declare @fswCount int
	set @fswCount = ( select count(workerprogrampk) 
					  from @tblWorkers 
					  where [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
	update @tblFinalExport set Response = @fswCount where [@tblFinalExport].RowNumber = 4
--end B5

--B6 row 5
	--Total FTEs in FSW Role
	declare @fswFTE numeric(5,2)
	set @fswFTE = ( select sum([@tblWorkers].FTE) 
					from @tblWorkers 
					where [@tblWorkers].FSWStartDate < @eDate 
							and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate))
    update @tblFinalExport set Response = @fswFTE where [@tblFinalExport].RowNumber = 5
--end B6

--B8 
	--row 7 Number of Hispanic Home Visitors
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
	--end row 7

	--row 8 Number of Non Hispanic Home Visitors
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
	--end row 8

    -- row 9 Home Visitors ethnicity unknown
	declare @UnknownEthnicityFSW int
	set @UnknownEthnicityFSW = ( select count(*) 
					        from @tblWorkers
						    where Race is Null
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @UnknownEthnicityFSW where RowNumber = 9
	--end row 9

--end B8

--B9 
	--row 11 Number of white FSWs
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
	--end row 11

	--row 12 of black FSWs
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

--B9 
	--row 13 Number of Asian FSWs
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
	--end row 13

	--row 14 Number of Native American FSWs
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
	--end row 14

	--row 16 Number of Multi Race FSWs
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
	--end row 16

	--row 17 Number of Multi Race FSWs
	declare @UnknownRaceFSW int
	set @UnknownRaceFSW = ( select count(*) 
					        from @tblWorkers
						    where Race is null
						    and (
								 [@tblWorkers].FSWStartDate < @eDate 
								 and ([@tblWorkers].FSWEndDate is null or [@tblWorkers].FSWEndDate > @eDate)
							    )
					      )
	update @tblFinalExport set Response = @UnknownRaceFSW where RowNumber = 17
	--end row 17

	--row 18 Number of other race FSWs
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
	--end row 18
--end B9

--B10 row 20 Received at least one home visit					
    insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
    select 20, tpid.PC1ID, 0, 1
	 from @tblPC1IDs tpid where tpid.hvcasefk in 
	 ( select distinct hvcasefk from @tblHomeVisits)

	declare @visitReceived int
	set @visitReceived = (select count(*) from @tblFinalExport tfe where RowNumber = 20 and Detail = 1)
	update @tblFinalExport set Response = @visitReceived where RowNumber = 20 and Detail = 0
--end B10

--B11 row 21 MIECHV funded
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 21, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.PC1ID in 
	( select distinct me.PC1ID from MIECHVEligible me )
	declare @miechv int
	set @miechv = (select count(*) from @tblFinalExport tfe where RowNumber = 21 and Detail = 1)
	update @tblFinalExport set Response = @miechv where RowNumber = 21 and Detail = 0
--End B11
	
--B12 row 22 Received first home visit in time period
    insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 22, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in 
	(select thv.hvcasefk from @tblHomeVisits thv
	   where thv.FirstHomeVisit >= @sDate)
						   
	declare @firstHomeVisit int
	set @firstHomeVisit = (select count(*) from @tblFinalExport tfe where RowNumber = 22 and Detail = 1)
	update @tblFinalExport set Response = @firstHomeVisit where RowNumber = 22 and Detail = 0
--end B12

--B13 row 23 Received first home visit prenatally
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 23, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in
	(select thv.hvcasefk from @tblHomeVisits thv
				where thv.FirstHomeVisit >= @sDate
				and isnull(EDC, TCDOB) > thv.FirstHomeVisit)
	declare @firstHomeVisitPrenatal int
	set @firstHomeVisitPrenatal = (select count(*) from @tblFinalExport tfe where RowNumber = 23 and Detail = 1)
	update @tblFinalExport set Response = @firstHomeVisitPrenatal where RowNumber = 23 and Detail = 0
--end B13

--B14 row 24 Received first home visit prenatally before 31 weeks
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 24, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in
	 (select thv.hvcasefk from @tblHomeVisits thv
				where thv.FirstHomeVisit >= @sDate
						   and dateadd(day, -54 , isnull(EDC, TCDOB)) >= thv.FirstHomeVisit
						   )
	declare @firstHomeVisitPrenatal31 int
	set @firstHomeVisitPrenatal31 = (select count(*) from @tblFinalExport tfe where RowNumber = 24 and Detail = 1)
	update @tblFinalExport set Response = @firstHomeVisitPrenatal31 where RowNumber = 24 and Detail = 0
--end B14

--B15 row 25
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 25, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in
	( select sub.hvcasefk from
							  (  select hvcasefk
									,VisitStartTime
									,row_number() over (partition by hvcasefk order by VisitStartTime asc) as [row]						   
							     from @tblHomeVisits
							     where (PC1Participated = 1 and PC1Relation2TC = '01' and Gender = '02')										 
							   ) as sub
							   where sub.[row] = 2
	 union
	 select sub.hvcasefk from
							  (  select hvcasefk
									,VisitStartTime
									,row_number() over (partition by hvcasefk order by VisitStartTime asc) as [row]						   
							     from @tblHomeVisits
							     where (OBPParticipated = 1 and GenderOBP = '02')
										   
							   ) as sub
							   where sub.[row] = 2
	)
	declare @HomeVisitsWithFF int
	set @HomeVisitsWithFF = (select count(*) from @tblFinalExport tfe where RowNumber = 25 and Detail = 1)
	update @tblFinalExport set Response = @HomeVisitsWithFF where RowNumber = 25 and Detail = 0
--end B15

--B16 row 26
	declare @countTC int
	--postnatal
	set @countTC = ( select count(*) from TCID
					 inner join @tblLastHomeVisit thv on thv.hvcasefk = TCID.HVCaseFK
					 where TCID.TCDOB < thv.VisitStartTime					 
				   )
	--prenatal
    declare @preTC int
	set @preTC = (select count(*) from @tblLastHomeVisit
		where TCDOB is null or TCDOB > VisitStartTime  
	)
	update @tblFinalExport set Response = @countTC + @preTC where RowNumber = 26
--end B16

--B17 row 27
	declare @countOtherChildren int
	set @countOtherChildren = ( select count(oc.OtherChildPK)
								from OtherChild oc 
								where oc.HVCaseFK in (select hvcasefk from @tblHomeVisits)
							  )
	update @tblFinalExport set Response = @countOtherChildren where RowNumber = 27
--end B17

--B18 row 29
	declare @countFemale int
	set @countFemale = ( select count(Gender)
						 from @tblLastHomeVisit
						 where Gender = '01'
					   )
	update @tblFinalExport set Response = @countFemale where RowNumber = 29
--end B18

--B19 row 30
	declare @countMale int
	set @countMale = ( select count(Gender)
						 from @tblLastHomeVisit
						 where Gender = '02'
					   )
	update @tblFinalExport set Response = @countMale where RowNumber = 30
--end B19

--B20 row 31
	declare @countGenderUnknown int
	set @countGenderUnknown = ( select count(*)
								from @tblLastHomeVisit
								where Gender is null or Gender = ''
							  )
	update @tblFinalExport set Response = @countGenderUnknown where RowNumber = 31
--end B20

--B21 row 32
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 32, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		 select distinct hvcasefk from @tblParity
		 where (Parity = 0 and TCDOB is null)
			or (Parity = 0 and KempeDate < TCDOB)
			or (Parity = 1 and TCDOB < KempeDate)
	)
	declare @firstTimeParent int
	set @firstTimeParent = (select count(*) from @tblFinalExport tfe where RowNumber = 32 and Detail = 1)
	update @tblFinalExport set Response = @firstTimeParent where RowNumber = 32 and Detail = 0
--end B21

--B22 row 33
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 33, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select hvcasefk from @tblHomeVisits
        where PC1Relation2TC = '04'
		)
	declare @grandParent int
	set @grandParent = (select count(*) from @tblFinalExport tfe where RowNumber = 33 and Detail = 1)
    update @tblFinalExport set Response = @grandParent where RowNumber = 33 and Detail = 0
--end B22

--B23 row 34
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 34, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblIntakeInfo
		where HighestGrade in ('03', '04', '05', '06', '07', '08') 
	)
	declare @HSorBetter int
	set @HSorBetter = (select count(*) from @tblFinalExport tfe where RowNumber = 34 and Detail = 1)
	update @tblFinalExport set Response = @HSorBetter where RowNumber = 34 and Detail = 0
--end B23

--B24 row 35
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 35, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct hvcasefk from @tblIntakeInfo
		where HighestGrade in ('01', '02')
	)
	declare @lessThanHS int
	set @lessThanHS = (select count(*) from @tblFinalExport tfe where RowNumber = 35 and Detail = 1)
	update @tblFinalExport set Response = @lessThanHS where RowNumber = 35 and Detail = 0
--end B24

--B25 row 36
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 36, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct hvcasefk from @tblIntakeInfo
		where HighestGrade is null or HighestGrade = ''
	)
	declare @eduUnknown int
	set @eduUnknown = (select count(*) from @tblFinalExport tfe where RowNumber = 36 and Detail = 1)
	update @tblFinalExport set Response = @eduUnknown where RowNumber = 36 and Detail = 0
--end B25

--B26 row 37
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 37, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct hvcasefk from @tblFollowUpInfo
		where DevelopmentalDisability = '1'
	)
	declare @devDisabled int
	set @devDisabled = (select count(*) from @tblFinalExport tfe where RowNumber = 37 and Detail = 1)
	update @tblFinalExport set Response = @devDisabled where RowNumber = 37 and Detail = 0
--end B26

--B27 row 38
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 38, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance 
				where AvailableMonthlyIncome <= 1397 + ((NumberInHouse - 1) * 497)  
	)
	declare @mcEligible int
	set @mcEligible = (select count(*) from @tblFinalExport tfe where tfe.RowNumber = 38 and Detail = 1)
	update @tblFinalExport set Response = @mcEligible where RowNumber = 38 and Detail = 0
--end B27
	

--B28 row 39
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 39, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct fui.hvcasefk from @tblFollowUpInfo fui
		inner join @tblIntakeInfo ii on ii.hvcasefk = fui.hvcasefk
		where fui.PC1FamilyArmedForces = '1' or ii.PC1FamilyArmedForces = '1'
	)
	declare @militaryFam int
	set @militaryFam = (select count(*) from @tblFinalExport tfe where RowNumber = 39 and Detail = 1)
	update @tblFinalExport set Response = @militaryFam where RowNumber = 39  and Detail = 0
--end B28

--B29 row 40
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 40, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct hvcasefk from @tblFollowUpInfo
		where SubstanceAbuse = '1'
	)
	declare @substanceAbuse int
	set @substanceAbuse = (select count(*) from @tblFinalExport tfe where RowNumber = 40 and Detail = 1)
	update @tblFinalExport set Response = @substanceAbuse where RowNumber = 40 and Detail = 0
--end B29

--B30 row 41
	--PC1 in need of substance abuse treatment
--end B30

--B31 row 42
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 42, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in ( 
		select distinct hvcasefk from @tblKempeInfo
		where PC1Neglected = '1' or PC1PhysicallyAbused = '1' or PC1SexuallyAbused = '1'
	)
	declare @abused int
	set @abused = (select count(*) from @tblFinalExport tfe where RowNumber = 42 and Detail = 1)
	update @tblFinalExport set Response = @abused where RowNumber = 42 and Detail = 0
--end B31

--B32 row 43
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 43, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblReferrals tr
		where tr.ReferralSource = '05'
	)
	declare @welfare int
	set @welfare = (select count(*) from @tblFinalExport where RowNumber = 43 and Detail = 1)
	update @tblFinalExport set Response = @welfare where RowNumber = 43 and Detail = 0
--end B32

--B33 
	--row 44
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 44, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblIntakeInfo
		where MaritalStatus in ('02', '04', '05')
	)
	declare @singleParent int
	set @singleParent = (select count(*) from @tblFinalExport tfe where RowNumber = 44 and Detail = 1)
	update @tblFinalExport set Response = @singleParent where RowNumber = 44 and Detail = 0
	--end B33

	--B34 row 45
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 45, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from phq9 
		where Positive = 1 and hvcasefk in (select hvcasefk from @tblHomeVisits) 
    )
	declare @depressed int
	set @depressed = (select count(*) from @tblFinalExport tfe where RowNumber = 45 and Detail = 1)
	update @tblFinalExport set Response = @depressed where RowNumber = 45 and Detail = 0
	--end B34

--B35 
--	--row 47
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 47, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance
		where HIUninsured = 1 and RowNum = 1
	)
	declare @PC1uninsured int
	set @PC1uninsured = (select count(*) from @tblFinalExport tfe where RowNumber = 47 and Detail = 1)
	update @tblFinalExport set Response = @PC1uninsured where RowNumber = 47 and Detail = 0
--	--end row 47

	--row 48
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 48, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance
		where RowNum = 1 and PC1ReceivingMedicaid = 1 
	)
	declare @PC1Medicaid int
	set @PC1Medicaid = (select count(*) from @tblFinalExport tfe where RowNumber = 48 and Detail = 1)
	update @tblFinalExport set Response = @PC1Medicaid where RowNumber = 48 and Detail = 0
	--end row 48

	--row 49
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 49, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance
		where RowNum = 1
		and (HIOther = 1 or HIPrivate = 1 or HIFamilyChildHealthPlus = 1 or HIPCAP = 1)
	)
	declare @PC1PrivateOther int
	set @PC1PrivateOther = (select count(*) from @tblFinalExport tfe where RowNumber = 49 and Detail = 1)
	update @tblFinalExport set Response = @PC1PrivateOther where RowNumber = 49 and Detail = 0
	--end row 49

	--row 50
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 50, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance
		where RowNum = 1 and HIUnknown = 1
	)
	declare @PC1InsUnk int
	set @PC1InsUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 50 and Detail = 1)
	update @tblFinalExport set Response = @PC1InsUnk where RowNumber = 50 and Detail = 0
	--end row 50

	--row 52
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 52, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCInsurance
		where RowNum = 1 and TCHIUninsured = 1
	)
	declare @TCUninsured int
	set @TCUninsured = (select sum(isnull(TCNumber, 0)) from @tblTCInsurance
						where RowNum = 1 and TCHIUninsured = 1
						)
	update @tblFinalExport set Response = @TCUninsured where RowNumber = 52 and Detail = 0
	--end row 52

	--row 53
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 53, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCInsurance
		where RowNum = 1 and TCReceivingMedicaid = '1'
	)
	declare @TCMedicaid int
	set @TCMedicaid = (select sum(TCNumber) from @tblTCInsurance
					   where RowNum = 1 and TCReceivingMedicaid = '1'
					)
	update @tblFinalExport set Response = @TCMedicaid where RowNumber = 53 and Detail = 0
	--end row 53

	--row 54
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 54, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCInsurance
		where RowNum = 1 
		and (TCHIFamilyChildHealthPlus = 1 or TCHIOther = 1 or TCHIPrivateInsurance = 1)
	)
	declare @TCPrivateOther int
	set @TCPrivateOther = (select sum(TCNumber) from @tblTCInsurance
					   where RowNum = 1 
					   and (TCHIFamilyChildHealthPlus = 1 or TCHIOther = 1 or TCHIPrivateInsurance = 1)
					)
	update @tblFinalExport set Response = @TCPrivateOther where RowNumber = 54  and Detail = 0
	--end row 54

	--row 55
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 55, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCInsurance
		where RowNum = 1 and TCHIUnknown = 1 
	)
	declare @TCInsUnk int
	set @TCInsUnk = (select sum(TCNumber) from @tblTCInsurance
					   where RowNum = 1 and TCHIUnknown = 1 
					)
	update @tblFinalExport set Response = @TCInsUnk where RowNumber = 55 and Detail = 0
	--end row 55
--end B35

--B36 
	--row 57
	--renting or own home
	--cannot determine difference between own & share or rent & share
	--end row 57

	--row 58
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 58, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLivingArrangement
		where RowNum = 1 and LivingArrangementSpecific = '04'
	)
	declare @livesWithParents int
	set @livesWithParents = (select count(*) from @tblFinalExport tfe where RowNumber = 58 and Detail = 1)
	update @tblFinalExport set Response = @livesWithParents where RowNumber = 58 and Detail = 0
	--end row 58

	--row 59
	--sharing housing
	--cannot determine difference between own & share or rent & share
	--end row 59

	--row 60
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 60, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLivingArrangement
		where RowNum = 1 and LivingArrangement = '02'
	)
	declare @homeless int
	set @homeless = (select count(*) from @tblFinalExport tfe where RowNumber = 60 and Detail = 1)
	update @tblFinalExport set Response = @homeless where RowNumber = 60 and Detail = 0
	--end row 60

	--row 61
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 61, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLivingArrangement
		where RowNum = 1 and LivingArrangement = '03'
	)
	declare @homeUnk int
	set @homeUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 61 and Detail = 1)
	update @tblFinalExport set Response = @homeUnk where RowNumber = 61 and Detail = 0
	--end row 61
--end B36

--B37
	--row 63
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 63, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblEmployment
		where RowNum = 1 and IsCurrentlyEmployed = '1' and EmploymentMonthlyHours >= 140
	)
	declare @fullTime int
	set @fullTime = (select count(*) from @tblFinalExport tfe where RowNumber = 63 and Detail = 1)
	update @tblFinalExport set Response = @fullTime where RowNumber = 63 and Detail = 0
	--end row 63

	--row 64
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 64, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblEmployment
		where RowNum = 1 and IsCurrentlyEmployed = '1' and (EmploymentMonthlyHours < 140 or EmploymentMonthlyHours is null)
	)
	declare @partTime int
	set @partTime = (select count(*) from @tblFinalExport tfe where RowNumber = 64 and Detail = 1)
	update @tblFinalExport set Response = @partTime where RowNumber = 64 and Detail = 0
	--end row 64 

	--row 65
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 65, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblEmployment
		where RowNum = 1 and IsCurrentlyEmployed = '0'
	)
	declare @noJob int
	set @noJob = (select count(*) from @tblFinalExport tfe where RowNumber = 65 and Detail = 1)
	update @tblFinalExport set Response = @noJob where RowNumber = 65 and Detail = 0
	--end row 65

	--row 66
	--cases with no employment data
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 66, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select hvcasefk from @tblEmployment
		where RowNum = 1 and (IsCurrentlyEmployed is null or IsCurrentlyEmployed = ' ')
	)
	declare @jobUnk int
	set @jobUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 66 and Detail = 1)
	update @tblFinalExport set Response = @jobUnk where RowNumber = 66 and Detail = 0
	--end row 66 

--B40 Parent Survey Scores
	--row 68
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 68, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct tki.hvcasefk from @tblKempeInfo tki
		inner join @tblHomeVisits thv on thv.hvcasefk = tki.hvcasefk
		where (Gender = '01' and MomScore < 25)
		   or (Gender = '02' and DadScore < 25)
	)
	declare @lowRisk int
	set @lowRisk = (select count(*) from @tblFinalExport tfe where RowNumber = 68 and Detail = 1)
	update @tblFinalExport set Response = @lowRisk where RowNumber = 68 and Detail = 0
	--end row 68
	
	--row 69
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 69, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct tki.hvcasefk from @tblKempeInfo tki
		inner join @tblHomeVisits thv on thv.hvcasefk = tki.hvcasefk
		where (Gender = '01' and MomScore between 25 and 35)
	       or (Gender = '02' and DadScore between 25 and 35)
	)
	declare @medRisk int
	set @medRisk = (select count(*) from @tblFinalExport tfe where RowNumber = 69 and Detail = 1)
	update @tblFinalExport set Response = @medRisk where RowNumber = 69 and Detail = 0
	--end row 69
	
	--row 70
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 70, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct tki.hvcasefk from @tblKempeInfo tki
		inner join @tblHomeVisits thv on thv.hvcasefk = tki.hvcasefk
		where (Gender = '01' and MomScore >= 40)
		   or (Gender = '02' and DadScore >= 40)
	)
	declare @hiRisk int
	set @hiRisk = (select count(*) from @tblFinalExport tfe where RowNumber = 70 and Detail = 1)
	update @tblFinalExport set Response = @hiRisk where RowNumber = 70
	--end row 70    
--end B40

--B41
	--row 72
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 72, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where TCDOB is null or TCDOB > VisitStartTime  
	)
	declare @PreNatal int
	set @PreNatal = (select count(*) from @tblFinalExport tfe where tfe.RowNumber = 72 and Detail = 1)
	update @tblFinalExport set Response = @PreNatal where RowNumber = 72 and Detail = 0

	--end row 72

	--row 73
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 73, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where   datediff(day, TCDOB, VisitStartTime) >= 0
			and	datediff(day, TCDOB, VisitStartTime) < 183
			and TCDOB < @eDate
	)
	declare @0to5mo int
	set @0to5mo = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				  where	datediff(day, tlhv.TCDOB, VisitStartTime) >= 0
				    and datediff(day, tlhv.TCDOB, VisitStartTime) < 183
					and TCID.TCDOB < @eDate
				)
	update @tblFinalExport set Response = @0to5mo where RowNumber = 73 and Detail = 0
	--end row 73

	--row 74
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 74, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 183 
			and datediff(day, TCDOB, VisitStartTime) < 365
			and TCDOB < @eDate
	)
	declare @6to11mo int
	set @6to11mo = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				   where datediff(day, tlhv.TCDOB, VisitStartTime) >= 183 
					and datediff(day, tlhv.TCDOB, VisitStartTime) < 365
					and tlhv.TCDOB < @eDate
	)
	update @tblFinalExport set Response = @6to11mo where RowNumber = 74 and Detail = 0
	--end 74

	--row 75
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 75, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 365 
			and datediff(day, TCDOB, VisitStartTime) < 730
			and TCDOB < @eDate
	)
	declare @12to23 int
	set @12to23 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
					where datediff(day, tlhv.TCDOB, VisitStartTime) >= 365 
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 730
						and tlhv.TCDOB < @eDate
	)
	update @tblFinalExport set Response = @12to23 where RowNumber = 75 and Detail = 0
	--end 75

	--row 76
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 76, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 730 
			and datediff(day, TCDOB, VisitStartTime) < 1095
			and TCDOB < @eDate
	)
	declare @24to35 int
	set @24to35 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				    where datediff(day, tlhv.TCDOB, VisitStartTime) >= 730 
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 1095
						and tlhv.TCDOB < @eDate
	) 
	update @tblFinalExport set Response = @24to35 where RowNumber = 76 and Detail = 0
	--end 76

	--row 77
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 77, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 1095 
			and datediff(day, TCDOB, VisitStartTime) < 1460
			and TCDOB < @eDate
	)
	declare @36to47 int
	set @36to47 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				    where datediff(day, tlhv.TCDOB, VisitStartTime) >= 1095 
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 1460
						and tlhv.TCDOB < @eDate
	) 
	update @tblFinalExport set Response = @36to47 where RowNumber = 77 and Detail = 0
	--end 77

	--row 78
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 78, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 1460 
			and datediff(day, TCDOB, VisitStartTime) < 1825
			and TCDOB < @eDate
	)
	declare @48to59 int
	set @48to59 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				    where datediff(day, tlhv.TCDOB, VisitStartTime) >= 1460 
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 1825
						and tlhv.TCDOB < @eDate
	) 
	update @tblFinalExport set Response = @48to59 where RowNumber = 78 and Detail = 0
	--end 78

	--row 79
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 79, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 1825 
			and datediff(day, TCDOB, VisitStartTime) < 2190
			and TCDOB < @eDate
	)
	declare @60to71 int
	set @60to71 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				    where datediff(day, tlhv.TCDOB, VisitStartTime) >= 1825 
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 2190
						and tlhv.TCDOB < @eDate
	) 
	update @tblFinalExport set Response = @60to71 where RowNumber = 79 and Detail = 0
	--end 79

	--row 80
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 80, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where datediff(day, TCDOB, VisitStartTime) >= 2190 
			and datediff(day, TCDOB, VisitStartTime) < 2555
			and TCDOB < @eDate
	)
	declare @72to83 int
	set @72to83 = ( select count(*) from @tblLastHomeVisit tlhv
					left join TCID on TCID.HVCaseFK = tlhv.hvcasefk
				    where datediff(day, tlhv.TCDOB, VisitStartTime) >= 2190  
						and datediff(day, tlhv.TCDOB, VisitStartTime) < 2555
						and tlhv.TCDOB < @eDate
	) 
	update @tblFinalExport set Response = @72to83 where RowNumber = 80 and Detail = 0
	--end 80

	--row 81
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 81, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid 
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblLastHomeVisit
		where TCDOB is null and EDC is null
	)
	declare @TCAgeUnk int
	set @TCAgeUnk = (select count(*) from @tblFinalExport tfe where tfe.RowNumber = 81 and tfe.Detail = 1)
	update @tblFinalExport set Response = @TCAgeUnk where RowNumber = 81 and Detail = 0
	--end 81

--end B41

--B42
	--row 83
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 83, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCBirthInfo
						where BirthWtLbs <= 4 or (BirthWtLbs = 5 and BirthWtOz < 8)
	)
	declare @lowBirthWt int
	set @lowBirthWt = ( select count(*) from @tblTCBirthInfo
						where BirthWtLbs <= 4 or (BirthWtLbs = 5 and BirthWtOz < 8)
	)
	update @tblFinalExport set Response = @lowBirthWt where RowNumber = 83 and Detail = 0
	--end row 83

	--row 84
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 84, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select distinct hvcasefk from @tblTCBirthInfo
		where GestationalAge < 37
	)
	declare @premature int
	set @premature = ( select count(*) from @tblTCBirthInfo
					   where GestationalAge < 37
	)
	update @tblFinalExport set Response = @premature where RowNumber = 84 and Detail = 0
	--end row 84

	-- row 85
	-- Developmentally delayed or disabled (known or suspected)
	-- End row 85

	--row 86
	-- TC Medicaid eligible
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 86, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid where tpid.hvcasefk in (
		select distinct hvcasefk from @tblPC1Insurance 
				where AvailableMonthlyIncome <= 1558 + ((NumberInHouse - 1) * 555) --children to 18
				
				--where AvailableMonthlyIncome <= 2257 + ((NumberInHouse - 1) * 803)  --children up to one year
	)
	declare @tcMcEligible int
	set @tcMcEligible = (select count(*) from @tblFinalExport tfe where tfe.RowNumber = 86 and Detail = 1)
	update @tblFinalExport set Response = @mcEligible where RowNumber = 86 and Detail = 0
	--end row 86
--end B42

--B43 PC1 Age at Enrollment
	--row 88
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 88, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) < 18
	)
	declare @Under18 int
	set @Under18 = (select count(*) from @tblFinalExport tfe where RowNumber = 88 and Detail = 1)
	update @tblFinalExport set Response = @Under18 where RowNumber = 88 and Detail = 0
	--end row 88

	--row 89
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 89, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 18 and (datediff(dd, PCDOB, IntakeDate)/365) <= 19
	)
	declare @18to19 int
	set @18to19 = (select count(*) from @tblFinalExport tfe where RowNumber = 89 and Detail = 1)
	update @tblFinalExport set Response = @18to19 where RowNumber = 89 and Detail = 0
	--end row 89

	--row 90
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 90, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 20 and (datediff(dd, PCDOB, IntakeDate)/365) <= 21
	)
	declare @20to21 int
	set @20to21 = (select count(*) from @tblFinalExport tfe where RowNumber = 90 and Detail = 1)
	update @tblFinalExport set Response = @20to21 where RowNumber = 90 and Detail = 0
	--end row 90
	
	--row 91
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 91, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 22 and (datediff(dd, PCDOB, IntakeDate)/365) <= 24
	)
	declare @22to24 int
	set @22to24 = (select count(*) from @tblFinalExport tfe where RowNumber = 91 and Detail = 1)
	update @tblFinalExport set Response = @22to24 where RowNumber = 91 and Detail = 0
	--end row 91

	--row 92
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 92, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 25 and (datediff(dd, PCDOB, IntakeDate)/365) <= 29
	)
	declare @25to29 int
	set @25to29 = (select count(*) from @tblFinalExport tfe where RowNumber = 92 and Detail = 1)
	update @tblFinalExport set Response = @25to29 where RowNumber = 92 and Detail = 0
	--end row 92

	--row 93
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 93, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 30 and (datediff(dd, PCDOB, IntakeDate)/365) <= 34
	)
	declare @30to44 int
	set @30to44 = (select count(*) from @tblFinalExport tfe where RowNumber = 93 and Detail = 1)
	update @tblFinalExport set Response = @30to44 where RowNumber = 93 and Detail = 0
	--end row 93

	--row 94
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 94, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 35 and (datediff(dd, PCDOB, IntakeDate)/365) <= 44
	)
	declare @55to65 int
	set @55to65 = (select count(*) from @tblFinalExport tfe where RowNumber = 94 and Detail = 1)
	update @tblFinalExport set Response = @55to65 where RowNumber = 94 and Detail = 0
	--end row 94

	--row 95
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 95, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 45 and (datediff(dd, PCDOB, IntakeDate)/365) <= 54
	)
	declare @45to54 int
	set @45to54 = (select count(*) from @tblFinalExport tfe where RowNumber = 95 and Detail = 1)
	update @tblFinalExport set Response = @45to54 where RowNumber = 95 and Detail = 0
	--end row 95

	--row 96
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 96, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 55 and (datediff(dd, PCDOB, IntakeDate)/365) <= 64
	)
	declare @55to64 int
	set @55to64 = (select count(*) from @tblFinalExport tfe where RowNumber = 96 and Detail = 1)
	update @tblFinalExport set Response = @55to64 where RowNumber = 96 and Detail = 0
	--end row 96

	--row 97
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 97, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where (datediff(dd, PCDOB, IntakeDate)/365) >= 65
	)
	declare @Over64 int
	set @Over64 = (select count(*) from @tblFinalExport tfe where RowNumber = 97 and Detail = 1)
	update @tblFinalExport set Response = @Over64 where RowNumber = 97 and Detail = 0
	--end row 97

	--row 98
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 98, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where PCDOB is null
	)
	declare @PCageUnk int
	set @PCageUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 98 and Detail = 1)
	update @tblFinalExport set Response = @PCageUnk where RowNumber = 98 and Detail = 0
	--end row 98
--end B43

--B44 PC1 Ethnicity
	--row 100
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 100, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '03'
	)
	declare @pcHispanic int
	set @pcHispanic = (select count(*) from @tblFinalExport tfe where RowNumber = 100 and Detail = 1)
	update @tblFinalExport set Response = @pcHispanic where RowNumber = 100 and Detail = 0
	--end row 100

	--row 101
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 101, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race <> '03'
	)
	declare @pcNonHispanic int
	set @pcNonHispanic = (select count(*) from @tblFinalExport tfe where RowNumber = 101 and Detail = 1) 
	update @tblFinalExport set Response = @pcNonHispanic where RowNumber = 101 and Detail = 0
	--end row 101

	--row 102
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 102, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race is null and Ethnicity is null
	)
	declare @pcEthnicityUnk int
	set @pcEthnicityUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 102 and Detail = 1) 
    update @tblFinalExport set Response = @pcEthnicityUnk where RowNumber = 102  and Detail = 0
	--end row 102
--end B44

--B45 PC1 Race
	--row 104
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 104, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		 select hvcasefk from @tblHomeVisits
		 where Race = '01'
	)
	declare @pcWhite int
	set @pcWhite = (select count(*) from @tblFinalExport tfe where RowNumber = 104 and Detail = 1) 
	update @tblFinalExport set Response = @pcWhite where RowNumber = 104 and Detail = 0
	--end row 104

	--row 105
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 105, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '02'
	)
	declare @pcBlack int
	set @pcBlack = (select count(*) from @tblFinalExport tfe where RowNumber = 105 and Detail = 1)  
	update @tblFinalExport set Response = @pcBlack where RowNumber = 105
	--end row 105
	
	--row 106
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 106, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '04'
	)
	declare @pcAsian int
	set @pcAsian = (select count(*) from @tblFinalExport tfe where RowNumber = 106 and Detail = 1)
	update @tblFinalExport set Response = @pcAsian where RowNumber = 106
	--end row 106

	--row 107
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 107, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '05'
	)
	declare @pcAmInd int
	set @pcAmInd = (select count(*) from @tblFinalExport tfe where RowNumber = 107 and Detail = 1) 
	update @tblFinalExport set Response = @pcAmInd where RowNumber = 107
	--end row 107

	--row 108
	--Hawaiian/Pacific Islander not tracked
	--end row 108

	--row 109
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 109, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '06'
	)
	declare @pcMultiRace int
	set @pcMultiRace = (select count(*) from @tblFinalExport tfe where RowNumber = 109 and Detail = 1)
	update @tblFinalExport set Response = @pcMultiRace where RowNumber = 109
	--end row 109

	--row 110
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 110, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race is null
	)
	declare @pcRaceUnk int
	set @pcRaceUnk = (select count(*) from @tblFinalExport tfe where RowNumber = 110 and Detail = 1) 
	update @tblFinalExport set Response = @pcRaceUnk where RowNumber = 110
	--end row 110
	
	--row 111
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 111, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblHomeVisits
		where Race = '07'
	)
	declare @pcRaceOther int
	set @pcRaceOther = (select count(*) from @tblFinalExport tfe where RowNumber = 111 and Detail = 1)  
	update @tblFinalExport set Response = @pcRaceOther where RowNumber = 111
	--end row 111

	--row 112
	--Other race specify: How to calculate?
	--end row 112

--B46
	--row 114
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 114, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblIntakeInfo
		where PrimaryLanguage = '01'
	)
	declare @English int
	set @English = (select count(*) from @tblFinalExport tfe where RowNumber = 114 and Detail = 1) 
	update @tblFinalExport set Response = @English where RowNumber = 114
	--end row 114

	--row 115
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 115, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblIntakeInfo
		where PrimaryLanguage = '02'
	)
	declare @Spanish int
	set @Spanish = (select count(*) from @tblFinalExport tfe where RowNumber = 115 and Detail = 1)
	update @tblFinalExport set Response = @Spanish where RowNumber = 115
	--end row 115

	--row 116
	insert into @tblFinalExport (RowNumber, PCID_Response, Header, Detail)
	select 116, tpid.PC1ID, 0, 1
	from @tblPC1IDs tpid
	where tpid.hvcasefk in (
		select hvcasefk from @tblIntakeInfo
		where PrimaryLanguage = '03'
	)
	declare @OtherLang int
	set @OtherLang = (select count(*) from @tblFinalExport tfe where RowNumber = 116 and Detail = 1) 
	update @tblFinalExport set Response = @OtherLang where RowNumber = 116
--	end row 116
--end B46
				
select * from @tblFinalExport order by RowNumber asc, Detail asc


end
GO
