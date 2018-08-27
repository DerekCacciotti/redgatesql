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
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(53, 'B35', 'Title XIX (Medicaid) / Title XXI (SCHIP) or Tri-Care', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(54, 'B35', 'Private or other insurance', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(55, 'B35', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(56, 'B36', 'Housing Status of PC1 (when last assessed)', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(57, 'B36', 'renting or own home', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(58, 'B36', 'living with parent or family member', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(59, 'B36', 'sharing housing', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(60, 'B36', 'homeless', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(61, 'B36', 'unknown housing situation', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(62, 'B37', 'PC1 employment status', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(63, 'B37', 'employed full time', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(64, 'B37', 'employed part time', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(65, 'B37', 'not employed (whether seeking work or not)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(66, 'B37', 'unknown employment situation', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(67, 'B40', 'How many PC1s were', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(68, 'B40', 'Low risk on Initial Assessment(Parent Survey < 25', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(69, 'B40', 'Medium risk on Initial Assessment(Parent Survey 25-35)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(70, 'B40', 'Higher risk on Initial Assessment(Parent Survey 40+)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(71, 'B41', 'TC age at Last Home Visit', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(72, 'B41', '0-5 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(73, 'B41', '6-11 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(74, 'B41', '12-23 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(75, 'B41', '24-35 months', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(76, 'B41', '36 months or older', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(77, 'B41', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(78, 'B42', 'Child Issues: Number of children who were', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(79, 'B42', 'Born at low birth weight, less than 2500 grams or 5lbs 8oz', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(80, 'B42', 'Born premature, born before 37 weeks completed', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(81, 'B42', 'Developmentally delayed or disabled (known or suspected)', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(82, 'B42', 'Medicaid eligible', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(83, 'B43', 'PC1 Age at Enrollment', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(84, 'B43', 'Less than 18', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(85, 'B43', '18-19', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(86, 'B43', '20-21', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(87, 'B43', '22-24', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(88, 'B43', '25-34', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(89, 'B43', '35-54', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(90, 'B43', '55 or more', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(91, 'B43', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(92, 'B44', 'Ethnicity: Number of Primary Participants who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(93, 'B44', 'Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(94, 'B44', 'Non-Hispanic', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(95, 'B44', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(96, 'B45', 'Race: Number of Primary Participants who are:', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(97, 'B45', 'White', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(98, 'B45', 'African-American', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(99, 'B45', 'Asian', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(100, 'B45', 'American Indian/Alaskan Native', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(101, 'B45', 'Native Hawaiian/Pacific Islander', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(102, 'B45', 'Multi-race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(103, 'B45', 'Unknown', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(104, 'B45', 'Other race', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(105, 'B45', 'Other race specify', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(106, 'B46', 'Primary Participant Language', 1)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(107, 'B46', 'Primary Language English', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(108, 'B46', 'Primary Language Spanish', 0)
	insert into @tblFinalExport (RowNumber, ItemNumber, Item, Header) values(109, 'B46', 'Primary Language not English nor Spanish', 0)

	

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

	--Cohort All home visit logs for cases that had a home visit in given year
	declare @tblHomeVisits as table (
		hvcasefk int index idx1 nonClustered
		,VisitStartTime date
		,PC1ID varchar(13)
		,TCDOB date		
		,EDC date
		,IntakeDate date
		,PCDOB date
		,DischargeDate date
		,FatherFigureParticipated bit
		,PC1Gender char(2)
		,TCNumber int
		,PC1Relation2TC char(2)
		,HighestGrade char(2)
		,Parity int
		,DevelopmentalDisability char(1)
		,PC1SubAbuse char(1)
		,PC1FamilyArmedForces char(1)
		,PC1Neglected char (1)
		,PC1PhysicallyAbused char(1)
		,PC1SexuallyAbused char(1)
		,MaritalStatus char(2)
		,RowNum int
	)

	insert into @tblHomeVisits(
	  hvcasefk
	 ,VisitStartTime
	 ,PC1ID
	 ,TCDOB
	 ,EDC
	 ,IntakeDate
	 ,PCDOB
	 ,DischargeDate
	 ,FatherFigureParticipated
	 ,PC1Gender
	 ,TCNumber
	 ,PC1Relation2TC
	 ,HighestGrade
	 ,Parity
	 ,DevelopmentalDisability
	 ,PC1SubAbuse
	 ,PC1FamilyArmedForces
	 ,PC1Neglected
	 ,PC1PhysicallyAbused
	 ,PC1SexuallyAbused
	 ,MaritalStatus
	 ,RowNum
	)
	select hv.hvcasefk
	      , hv.VisitStartTime
		  , cp.PC1ID
		  , hc.TCDOB
		  , hc.EDC	  
		  , itk.IntakeDate
		  , PCDOB
		  , DischargeDate
		  , hv.FatherFigureParticipated
		  , p.gender
		  , hc.TCNumber
		  , hc.PC1Relation2TC
		  , ca.HighestGrade
		  , ca2.Parity
		  , kmp.PC1SubAbuse
		  , itk.PC1FamilyArmedForces
		  , kmp.PC1Neglected
		  , pci.DevelopmentalDisability
		  , kmp.PC1PhysicallyAbused
		  , kmp.PC1SexuallyAbused
		  , ca3.MaritalStatus	  
		  , row_number() over(partition by hv.hvcasefk order by hv.VisitStartTime asc)
	from hvlog hv
	inner join dbo.SplitString(@programfk,',') on hv.programfk  = listitem
	inner join dbo.HVCase hc on hc.HVCasePK = hv.HVCaseFK
	inner join dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK
	inner join PC p on p.pcpk = hc.pc1fk
	inner join Kempe kmp on kmp.hvcasefk = hc.hvcasepk
	inner join Intake itk on itk.hvcasefk = hc.hvcasepk
	inner join PC1Issues pci on pci.PC1IssuesPK = kmp.pc1issuesfk
	left outer join CommonAttributes ca on ca.hvcasefk = hv.hvcasefk and ca.formtype = 'KE'
	left outer join CommonAttributes ca2 on ca2.hvcasefk = hv.hvcasefk and ca2.formtype = 'TC'
	left outer join CommonAttributes ca3 on ca3.hvcasefk = hv.hvcasefk and ca3.formtype = 'IN-PC1'
	left outer join TCID tc on tc.HVCaseFK = hc.HVCasePK
	WHERE substring(VisitType, 4, 1) <> '1'
	      and hv.hvcasefk in (select hvcasefk from hvlog where VisitStartTime BETWEEN @sDate AND @eDate)
	
	--Cohort - Cases that received a home visit in given year
	declare @tblThisYearsCases as table (
		hvcasefk int
	   ,PC1Gender char(2)
	   ,PC1Relation2TC char(2)
	   ,HighestGrade char(2)
	   ,IntakeDate date
	   ,PCDOB date
	   ,TCDOB date
	   ,TCNumber int
	   ,Parity int
	   ,DevelopmentalDisability char(1)
	   ,PC1SubAbuse char(1)
	   ,PC1FamilyArmedForces char(1)
	   ,PC1Neglected char (1)
	   ,PC1PhysicallyAbused char(1)
	   ,PC1SexuallyAbused char(1)
	   ,MaritalStatus char(2)
	)
	insert into @tblThisYearsCases (
	    hvcasefk
	   ,PC1Gender
	   ,PC1Relation2TC
	   ,HighestGrade
	   ,IntakeDate
	   ,PCDOB
	   ,TCDOB
	   ,TCNumber
	   ,Parity
	   ,DevelopmentalDisability
	   ,PC1SubAbuse
	   ,PC1FamilyArmedForces
	   ,PC1Neglected
	   ,PC1PhysicallyAbused
	   ,PC1SexuallyAbused
	   ,MaritalStatus
	)
	select distinct hvcasefk 
				   ,PC1Gender
				   ,PC1Relation2TC
				   ,HighestGrade
				   ,IntakeDate
				   ,PCDOB
				   ,TCDOB
				   ,TCNumber
				   ,Parity
				   ,DevelopmentalDisability
				   ,PC1SubAbuse
				   ,PC1FamilyArmedForces
				   ,PC1Neglected
				   ,PC1PhysicallyAbused
				   ,PC1SexuallyAbused
				   ,MaritalStatus
    from @tblHomeVisits
	where VisitStartTime between @sDate and @eDate

	declare @tblLastHomeVisit as table (
		    hvcasefk int
	      , VisitStartTime date
		  , TCDOB date
		  , RowNum int
	)
	insert into @tblLastHomeVisit (
		hvcasefk
		, VisitStartTime
		, TCDOB
		, RowNum
	)
	select hvcasefk
	       , VisitStartTime
		   , TCDOB
		   , row_number() over (partition by hvcasefk order by thv.VisitStartTime desc)
	from @tblHomeVisits thv
	where VisitStartTime between @sDate and @eDate
	
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
	   , ca2.PC1ReceivingMedicaid
	   , row_number() over (partition by ca.hvcasefk order by ca.FormDate desc) as [row]  
	   from commonattributes ca
	   inner join @tblThisYearsCases ttyc on ttyc.hvcasefk = ca.hvcasefk
	   inner join commonattributes ca2 on  ca2.FormType = 'FU-PC1' and ca.FormFK = ca2.FormFK
	   where ca.FormType in ('FU', 'IN', 'KE')
	  and ca.FormDate between @sdate and @edate

	--Cohort TC Health insurance assessments in given year
	declare @tblTCInsurance as table (
		HVCaseFK int
		,FormDate date
		,TCHIFamilyChildHealthPlus bit
		,TCHIPrivateInsurance bit
		,TCHIOther bit
		,TCHIUninsured bit
		,TCHIUnknown bit
		,TCReceivingMedicaid char(1)
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
		, row_number() over (partition by ca.hvcasefk order by ca.FormDate desc)
	from dbo.CommonAttributes ca
	inner join @tblThisYearsCases ttyc on ttyc.hvcasefk = ca.HVCaseFK
	where FormType in ('TC', 'FU') and FormDate between @sDate and @eDate

	--Cohort TC Birth Info
    declare @tblTCBirthInfo as table (
		hvcasefk int
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
	select ttyc.hvcasefk
		   ,t.TCDOB
		   , BirthWtLbs
		   , BirthWtOz
		   , GestationalAge
	from dbo.TCID t 
	right join @tblThisYearsCases ttyc on ttyc.hvcasefk = t.HVCaseFK
	
	--Cohort Living Arrangement assessments in given year
	declare @tblLivingArrangement as table (
		hvcasefk int
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
		inner join @tblThisYearsCases ttyc on ttyc.hvcasefk = ca.HVCaseFK
		where ca.FormType in ('IN', 'FU')

	--Cohort Employment assessments in given year
	declare @tblEmployment as table (
		hvcasefk int
		,EmploymentMonthlyHours int
		,StillWorking char(1)
		,FormDate date
		,RowNum int
	)
	insert into @tblEmployment (
		hvcasefk
		, EmploymentMonthlyHours
		, StillWorking
		, FormDate	
		, RowNum	
	)
	select e.hvcasefk
		, EmploymentMonthlyHours
		, StillWorking
		, FormDate	
		,row_number() over(partition by e.hvcasefk order by FormDate desc)
	from Employment e
	inner join @tblThisYearsCases ttyc on ttyc.hvcasefk = e.HVCaseFK
	where FormType in ('FU', 'IN', 'KE')
	and PCType = 'PC1'
				
	--B2 row 1
	--Number of home visits completed
	declare @hvLogCount int
	set @hvLogCount = ( select count(hvcasefk) 
						from @tblHomeVisits thv
						where thv.VisitStartTime between @sDate and @eDate
						)
	update @tblFinalExport set Response = @hvLogCount where [@tblFinalExport].RowNumber = 1 
	--End B2--

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
	set @countTC = ( select sum(TCNumber) from @tblThisYearsCases
					 where TCDOB < @eDate
				   )
	update @tblFinalExport set Response = @countTC where RowNumber = 26
	--End B16

	--B17 row 27
	declare @countOtherChildren int
	set @countOtherChildren = ( select count(oc.OtherChildPK)
								from OtherChild oc 
								where oc.HVCaseFK in (select hvcasefk from @tblThisYearsCases)
							  )
	update @tblFinalExport set Response = @countOtherChildren where RowNumber = 27
	--End B17

	--B18 row 29
	declare @countFemale int
	set @countFemale = ( select count(pc1gender)
						 from @tblThisYearsCases ttyc
						 where pc1gender = '01'
					   )
	update @tblFinalExport set Response = @countFemale where RowNumber = 29
	--End B18

	--B19 row 30
	declare @countMale int
	set @countMale = ( select count(pc1gender)
						 from @tblThisYearsCases ttyc
						 where pc1gender = '02'
					   )
	update @tblFinalExport set Response = @countMale where RowNumber = 30
	--End B19

	--B20 row 31
	declare @countGenderUnknown int
	set @countGenderUnknown = ( select count(pc1gender)
								from @tblThisYearsCases ttyc
								where ttyc.pc1gender is null
							  )
	update @tblFinalExport set Response = @countGenderUnknown where RowNumber = 31
	--End B20

	--B21 row 32
	declare @firstTimeParent int
	set @firstTimeParent = ( select count(parity) from @tblThisYearsCases tyc
							 where parity = 1
						 )
	update @tblFinalExport set Response = @firstTimeParent where RowNumber = 32 
	--End B21

	--B22 row 33
	declare @grandParent int
	set @grandParent = ( select count(hvcasefk) from @tblThisYearsCases
                         where PC1Relation2TC = '04'
							   and PC1Gender = '01'
						)
    update @tblFinalExport set Response = @grandParent where RowNumber = 33
	--End B22

	--B23 row 34
	declare @HSorBetter int
	set @HSorBetter = ( select count(hvcasefk) from @tblThisYearsCases
						where HighestGrade in ('03', '04', '05', '06', '07', '08') 
					  )
	update @tblFinalExport set Response = @HSorBetter where RowNumber = 34
	--End B23

	--B24 row 35
	declare @lessThanHS int
	set @lessThanHS = ( select count(hvcasefk) from @tblThisYearsCases
						where HighestGrade in ('01', '02') 
					  )
	update @tblFinalExport set Response = @lessThanHS where RowNumber = 35
	--End B24

	--B25 row 36
	declare @eduUnknown int
	set @eduUnknown = ( select count(hvcasefk) from @tblThisYearsCases
						where HighestGrade is null
					  )
	update @tblFinalExport set Response = @eduUnknown where RowNumber = 36
	--End B25

	--B26 row 39
	declare @devDisabled int
	set @devDisabled = ( select  count(hvcasefk) from @tblThisYearsCases
						 where DevelopmentalDisability = '1'
					   )
	update @tblFinalExport set Response = @devDisabled where RowNumber = 37
	--End B26

	--B27 row 38
	--medicare elgibility
	--End B27
	

	--B28 row 39
	declare @militaryFam int
	set @militaryFam = ( select count(hvcasefk) from @tblThisYearsCases
						 where PC1FamilyArmedForces = '1'
					)
	update @tblFinalExport set Response = @militaryFam where RowNumber = 39
	--End B28

	--B29 row 40
	declare @substanceAbuse int
	set @substanceAbuse = ( select count(hvcasefk) from @tblThisYearsCases
						    where PC1SubAbuse = '1'
					      )
	update @tblFinalExport set Response = @substanceAbuse where RowNumber = 40
	--End B29

	--B30 row 41
	--PC1 in need of substance abuse treatment
	--End B30

	--B31 row 42
	declare @abused int
	set @abused = ( select count(hvcasefk) from @tblThisYearsCases
					   where PC1Neglected = '1' or PC1PhysicallyAbused = '1' or PC1SexuallyAbused = '1'
					 )
	update @tblFinalExport set Response = @abused where RowNumber = 42
	--End B31

	--B32 row 43
	--PC1 involved in Child Welfare as a caregiver
	--End B32

	--B33 row 44
	declare @singleParent int
	set @singleParent = (select count(hvcasefk) from @tblThisYearsCases
						 where MaritalStatus in ('02', '04', '05')
						)
	update @tblFinalExport set Response = @singleParent where RowNumber = 44
	--End B33

	--B34 row 45
	declare @depressed int
	set @depressed = (select count(distinct hvcasefk) from phq9 
					  where Positive = 1 and hvcasefk in (select hvcasefk from @tblThisYearsCases) 
                    )
	update @tblFinalExport set Response = @depressed where RowNumber = 45
	--End B34

	--B35 
	--row 47
	declare @PC1uninsured int
	set @PC1uninsured = (select count(hvcasefk) from @tblPC1Insurance
						 where HIUninsured = 1 and RowNum = 1
						)
	update @tblFinalExport set Response = @PC1uninsured where RowNumber = 47
	--End row 47

	--row 48
	declare @PC1Medicaid int
	set @PC1Medicaid = (select count(hvcasefk) from @tblPC1Insurance
						where RowNum = 1 and PC1ReceivingMedicaid = 1 
						)
	update @tblFinalExport set Response = @PC1Medicaid where RowNumber = 48
	--End row 48

	--row 49
	declare @PC1PrivateOther int
	set @PC1PrivateOther = (select count(hvcasefk) from @tblPC1Insurance
							where RowNum = 1
							and (HIOther = 1 or HIPrivate = 1 or HIFamilyChildHealthPlus = 1 or HIPCAP = 1)
							)
	update @tblFinalExport set Response = @PC1PrivateOther where RowNumber = 49
	--End row 49

	--row 50
	declare @PC1InsUnk int
	set @PC1InsUnk = (select count(hvcasefk) from @tblPC1Insurance
							where RowNum = 1 and HIUnknown = 1
					)
	update @tblFinalExport set Response = @PC1InsUnk where RowNumber = 50
	--End row 50

	--row 52
	declare @TCUninsured int
	set @TCUninsured = (select count(hvcasefk) from @tblTCInsurance
						where RowNum = 1 and TCHIUninsured = 1
						)
	update @tblFinalExport set Response = @TCUninsured where RowNumber = 52
	--End row 52

	--row 53
	declare @TCMedicaid int
	set @TCMedicaid = (select count(hvcasefk) from @tblTCInsurance
					   where RowNum = 1 and TCReceivingMedicaid = '1'
					)
	update @tblFinalExport set Response = @TCMedicaid where RowNumber = 53
	--End row 53

	--row 54
	declare @TCPrivateOther int
	set @TCPrivateOther = (select count(hvcasefk) from @tblTCInsurance
					   where RowNum = 1 and (TCHIFamilyChildHealthPlus = 1 or TCHIOther = 1 or TCHIPrivateInsurance = 1)
					)
	update @tblFinalExport set Response = @TCPrivateOther where RowNumber = 54
	--End row 54

	--row 55
	declare @TCInsUnk int
	set @TCInsUnk = (select count(hvcasefk) from @tblTCInsurance
					   where RowNum = 1 and TCHIUnknown = 1 
					)
	update @tblFinalExport set Response = @TCInsUnk where RowNumber = 55
	--End row 55
    --End B35

	--B36 
	--row 57
	--renting or own home
	--cannot determine difference between own & share or rent & share
	--End row 57

	--row 58
	declare @livesWithParents int
	set @livesWithParents = (select count(hvcasefk) from @tblLivingArrangement
							 where RowNum = 1 and LivingArrangementSpecific = '04'
							)
	update @tblFinalExport set Response = @livesWithParents where RowNumber = 58
	--End row 58

	--row 59
	--sharing housing
	--cannot determine difference between own & share or rent & share
	--End row 59

	--row 60
	declare @homeless int
	set @homeless = (select count(hvcasefk) from @tblLivingArrangement
					 where RowNum = 1 and LivingArrangement = '02'
					)
	update @tblFinalExport set Response = @homeless where RowNumber = 60
	--End row 60

	--row 61
	declare @homeUnk int
	set @homeUnk = (select count(hvcasefk) from @tblLivingArrangement
					 where RowNum = 1 and LivingArrangement = '03'
					)
	update @tblFinalExport set Response = @homeUnk where RowNumber = 61
	--End row 61
	--End B36

	--B37
	--row 63
	declare @fullTime int
	set @fullTime = (select count(hvcasefk) from @tblEmployment
					 where RowNum = 1 and StillWorking = 1 and EmploymentMonthlyHours >= 35
					)
	update @tblFinalExport set Response = @fullTime where RowNumber = 63
	--End row 63

	--row 64
	declare @partTime int
	set @partTime = (select count(hvcasefk) from @tblEmployment
					 where RowNum = 1 and StillWorking = '1' and EmploymentMonthlyHours < 35
					)
	update @tblFinalExport set Response = @partTime where RowNumber = 64
	--End row 64 

	--row 65
	declare @noJob int
	set @noJob = (select count(hvcasefk) from @tblEmployment
					 where RowNum = 1 and StillWorking = '0'
					)
	update @tblFinalExport set Response = @noJob where RowNumber = 65
	--End row 65

	--row 66
	declare @jobUnk int
	set @jobUnk = @visitReceived - @noJob - @partTime - @fullTime
	update @tblFinalExport set Response = @jobUnk where RowNumber = 66
	--End row 65 

	--B40 
	--(68, 'B40', 'Low risk on Initial Assessment(Parent Survey < 25', 0)
	--(69, 'B40', 'Medium risk on Initial Assessment(Parent Survey 25-35)', 0)
	--(70, 'B40', 'Higher risk on Initial Assessment(Parent Survey 40+)', 0)
	--End B40

	--B41
	--row 72
	declare @0To5 int
	set @0To5 = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and datediff(month, TCDOB, VisitStartTime) <= 5
					)
	update @tblFinalExport set Response = @0To5 where RowNumber = 72
	--End row 72

	--row 73
	declare @5To11 int
	set @5To11 = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and datediff(month, TCDOB, VisitStartTime) >= 6 and datediff(month, TCDOB, VisitStartTime) <= 11
					)
	update @tblFinalExport set Response = @5To11 where RowNumber = 73
	--End 73

	--row 74
	declare @12To23 int
	set @12To23 = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and datediff(month, TCDOB, VisitStartTime) >= 12 and datediff(month, TCDOB, VisitStartTime) <= 23
					)
	update @tblFinalExport set Response = @12To23 where RowNumber = 74
	--End 74

	--row 75
	declare @24To35 int
	set @24To35 = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and datediff(month, TCDOB, VisitStartTime) >= 24 and datediff(month, TCDOB, VisitStartTime) <= 35
					)
	update @tblFinalExport set Response = @24To35 where RowNumber = 75
	--End 75

	--row 76
	declare @36AndUp int
	set @36AndUp = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and datediff(month, TCDOB, VisitStartTime) >= 36
					)
	update @tblFinalExport set Response = @36AndUp where RowNumber = 76
	--End 76

	--row 77
	declare @TCAgeUnk int
	set @TCAgeUnk = ( select count(hvcasefk) from @tblLastHomeVisit
					 where RowNum = 1 and TCDOB is null
					)
	update @tblFinalExport set Response = @TCAgeUnk where RowNumber = 77
	--End 77
	--End B41

	--B42
	--row 79
	declare @lowBirthWt int
	set @lowBirthWt = ( select count(hvcasefk) from @tblTCBirthInfo
						where BirthWtLbs <= 4 or (BirthWtLbs = 5 and BirthWtOz < 8)
					  )
	update @tblFinalExport set Response = @lowBirthWt where RowNumber = 79
	--End row 79

	--row 80
	declare @premature int
	set @premature = ( select count(hvcasefk) from @tblTCBirthInfo
						where GestationalAge < 37
					  )
	update @tblFinalExport set Response = @premature where RowNumber = 80
	--End row 80

	-- row 81
	-- Developmentally delayed or disalbed (known or suspected)
	-- End row 81

	--row 82
	--Medicaid eligible
	--End row 82
	--End B42

	--B43 PC1 Age at Enrollment
	--row 84
	declare @Under18 int
	set @Under18 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) < 18
					)
	update @tblFinalExport set Response = @Under18 where RowNumber = 84
	--End row 84

	--row 85
	declare @18to19 int
	set @18to19 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 18 and datediff(year, PCDOB, IntakeDate) <= 19
					)
	update @tblFinalExport set Response = @18to19 where RowNumber = 85
	--End row 85

	--row 86
	declare @20to21 int
	set @20to21 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 20 and datediff(year, PCDOB, IntakeDate) <= 21
					)
	update @tblFinalExport set Response = @20to21 where RowNumber = 86
	--End row 86
	
	--row 87
	declare @22to24 int
	set @22to24 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 22 and datediff(year, PCDOB, IntakeDate) <= 24
					)
	update @tblFinalExport set Response = @22to24 where RowNumber = 87
	--End row 87

	--row 88
	declare @25to34 int
	set @25to34 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 25 and datediff(year, PCDOB, IntakeDate) <= 34
					)
	update @tblFinalExport set Response = @25to34 where RowNumber = 88
	--End row 88

	--row 89
	declare @35to54 int
	set @35to54 = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 35 and datediff(year, PCDOB, IntakeDate) <= 54
					)
	update @tblFinalExport set Response = @35to54 where RowNumber = 89
	--End row 89

	--row 90
	declare @55andUp int
	set @55andUp = (select count(hvcasefk) from @tblThisYearsCases
					where datediff(year, PCDOB, IntakeDate) >= 55
					)
	update @tblFinalExport set Response = @55andUp where RowNumber = 90
	--End row 90

	--row 91
	declare @PCageUnk int
	set @PCageUnk = (select count(hvcasefk) from @tblThisYearsCases
					where PCDOB is null
					)
	update @tblFinalExport set Response = @PCageUnk where RowNumber = 91
	--End row 91


					
select * from @tblFinalExport
end
GO
