SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates 9, '05/01/09', '04/30/11'
-- exec rspRetentionRates 19, '20080101', '20121231'
-- exec rspRetentionRates 37, '20090401', '20110331'
-- exec rspRetentionRates 17, '20090401', '20110331'
-- exec rspRetentionRates 20, '20080401', '20110331'
-- exec rspRetentionRates '15,16', '20091201', '20111130'
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', 85, null, '' 85 = Daisy Flores
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, 1, '' 1 = Children Youth & Families
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
-- =============================================
CREATE PROC [dbo].[rspRetentionRates]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max)
	, @StartDate datetime
	, @EndDate datetime
    , @WorkerFK int = null
	, @SiteFK int = null
	, @CaseFiltersPositive varchar(100) = ''
as
BEGIN 
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--#region declarations
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end
	--declare @tblResults table (
	--	LineDescription varchar(50)
	--	, LineGroupingLevel int
	--	, DisplayPercentages bit
	--	, TotalEnrolledParticipants int
	--	, RetentionRateThreeMonths decimal(5,3)
	--	, RetentionRateSixMonths decimal(5,3)
	--	, RetentionRateOneYear decimal(5,3)
	--	, RetentionRateEighteenMonths decimal(5,3)
	--	, RetentionRateTwoYears decimal(5,3)
	--	, RetentionRateThreeYears decimal(5,3)
	--	, EnrolledParticipantsThreeMonths int
	--	, EnrolledParticipantsSixMonths int
	--	, EnrolledParticipantsOneYear int
	--	, EnrolledParticipantsEighteenMonths int
	--	, EnrolledParticipantsTwoYears int
	--	, EnrolledParticipantsThreeYears int
	--	, RunningTotalDischargedThreeMonths int
	--	, RunningTotalDischargedSixMonths int
	--	, RunningTotalDischargedOneYear int
	--	, RunningTotalDischargedEighteenMonths int
	--	, RunningTotalDischargedTwoYears int
	--	, RunningTotalDischargedThreeYears int
	--	, TotalNThreeMonths int
	--	, TotalNSixMonths int
	--	, TotalNOneYear int
	--	, TotalNEighteenMonths int
	--	, TotalNTwoYears int
	--	, TotalNThreeYears int
	--	, AllParticipants int
	--	, ThreeMonthsIntake int
	--	, SixMonthsIntake int
	--	, OneYearIntake int 
	--	, EighteenMonthsIntake int
	--	, TwoYearsIntake int
	--	, ThreeYearsIntake int);

	--declare @tblPC1withStats table (
	--	PC1ID char(13)
	--  , ScreenDate datetime
	--  , KempeDate datetime
	--	, DaysBetween int
	--	, IntakeDate datetime
	--	, DischargeDate datetime
	--	, LastHomeVisit datetime
	--	, RetentionMonths int
	--	, ActiveAt3Months int
	--	, ActiveAt6Months int
	--	, ActiveAt12Months int
	--	, ActiveAt18Months int
	--	, ActiveAt24Months int
	--	, ActiveAt36Months int
	--	, AgeAtIntake_Under18 int
	--	, AgeAtIntake_18UpTo20 int
	--	, AgeAtIntake_20UpTo30 int
	--	, AgeAtIntake_Over30 int
	--	, RaceWhite int
	--	, RaceBlack int
	--	, RaceHispanic int
	--	, RaceAsian int
	--	, RaceNativeAmerican int
	--	, RaceMultiracial int
	--	, RaceOther int
	--	, RaceUnknownMissing int
	--	, MarriedAtIntake int
	--	, NeverMarriedAtIntake int
	--	, SeparatedAtIntake int
	--	, DivorcedAtIntake int
	--	, WidowedAtIntake int
	--	, MarriedUnknownMissingAtIntake int
	--	, OtherChildrenInHouseholdAtIntake int
	--	, NoOtherChildrenInHouseholdAtIntake int
	--	, ReceivingTANFAtIntake int
	--	, NotReceivingTANFAtIntake int
	--	, MomScore int
	--	, DadScore int
	--	, PartnerScore int
	--	, PC1EducationAtIntakeLessThan12 int
	--	, PC1EducationAtIntakeHSGED int
	--	, PC1EducationAtIntakeMoreThan12 int
	--	, PC1EducationAtIntakeUnknownMissing int
	--	, PC1EmploymentAtIntakeYes int
	--	, PC1EmploymentAtIntakeNo int
	--	, PC1EmploymentAtIntakeUnknownMissing int
	--	, CountOfHomeVisits int
	--	, CurrentLevelAtDischarge1 int
	--	, CurrentLevelAtDischarge2 int
	--	, CurrentLevelAtDischarge3 int
	--	, CurrentLevelAtDischarge4 int
	--	, CurrentLevelAtDischargeX int
	--	, CurrentLevelAtDischargePrenatal int
	--	, CurrentLevelAtDischargeOther int
	--	, PC1DVAtIntake int
	--	, PC1MHAtIntake int
	--	, PC1SAAtIntake int
	--	, PC1PrimaryLanguageAtIntakeEnglish int
	--	, PC1PrimaryLanguageAtIntakeSpanish int
	--	, PC1PrimaryLanguageAtIntakeOtherUnknown int
	--	, TrimesterAtIntakePostnatal int
	--	, TrimesterAtIntake3rd int
	--	, TrimesterAtIntake2nd int
	--	, TrimesterAtIntake1st int
	--	, CountOfFSWs int);

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#tmpCohort'))
	-- where charindex('#',name)>0 order by name
	drop table #tmpCohort

create table #tmpCohort
	(HVCasePK int
		, PC1ID char(13)
		, PC1FK int
		, ScreenDate date
		, KempeDate date
		, IntakeDate date
		, EDC date
		, TCDOB date
		, OBPInHomeIntake bit
		, PC2InHomeIntake bit);

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#tmpDischargeData'))
	-- where charindex('#',name)>0 order by name
	drop table #tmpDischargeData

create table #tmpDischargeData
	(HVCaseFK int
	,DischargeReason char(100)
	,PC1TANFAtDischarge char(1)
	,MaritalStatusAtDischarge char(100)
	,PC1EducationAtDischarge char(100)
	,PC1EmploymentAtDischarge char(1)
	,AlcoholAbuseAtDischarge bit
	,SubstanceAbuseAtDischarge bit
	,DomesticViolenceAtDischarge bit
	,MentalIllnessAtDischarge bit
	,DepressionAtDischarge bit
);

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#tmpMain'))
	-- where charindex('#',name)>0 order by name
	drop table #tmpMain

create table #tmpMain (
	[ProgramFK] [varchar](max) null,
	[PC1ID] [char](13) null,
	[HVCaseFK] [int] null,
	[IntakeDate] [date] null,
	[LastHomeVisit] [date] null,
	[CountOfFSWs] [int] null,
	[CountOfHomeVisits] [int] null,
	[DischargeDate] [date] null,
	[LevelName] [varchar](50) null,
	[DischargeReasonCode] [char](2) null,
	[DischargeReason] [char](100) null,
	[PC1AgeAtIntake] [int] null,
	[ActiveAt6Months] [bit] null,
	[ActiveAt12Months] [bit] null,
	[ActiveAt18Months] [bit] null,
	[ActiveAt24Months] [bit] null,
	Race_AmericanIndian BIT NULL,
	Race_Asian BIT NULL,
	Race_Black BIT NULL,
	Race_Hawaiian BIT NULL,
	Race_White BIT NULL,
	Race_Other BIT NULL,
	Race_Hispanic BIT NULL,
	RaceSpecify VARCHAR(500) NULL,
	[MaritalStatus] [char](2) null,
	[MaritalStatusAtIntake] [char](100) null,
	[MomScore] [int] null,
	[DadScore] [int] null,
	[PartnerScore] [int] null,
	[HighestGrade] [char](2) null,
	[PC1EducationAtIntake] [char](100) null,
	[PC1EmploymentAtIntake] [char](1) null,
	[PC1PrimaryLanguageAtIntake] [char](2) null,
	[TCDOB] [date] null,
	[PrenatalEnrollment] [bit] null,
	[AlcoholAbuseAtIntake] [bit] null,
	[SubstanceAbuseAtIntake] [bit] null,
	[DomesticViolenceAtIntake] [bit] null,
	[MentalIllnessAtIntake] [bit] null,
	[DepressionAtIntake] [bit] null,
	[ActiveAt3Months] [bit] null,
	[ActiveAt36Months] [bit] null,
	[PC1TANFAtIntake] [char](1) null,
	[ConceptionDate] [date] null,
	[ScreenDate] [date] null,
	[KempeDate] [date] null,
	[MaxParity] [int] null,
	[EffectiveKempeScore] [int] null
);

--#endregion
--#region tmpCohort - Get the cohort for the report
with cteCohort as
	(select max(CaseProgramPK) as CaseProgramPK
			from CaseProgram cp
			inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join SplitStringToInt(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			where IntakeDate is not null and IntakeDate between @StartDate and @EndDate
			group by HVCaseFK
	)
	insert into #tmpCohort 
		select HVCasePK
				, PC1ID
				, PC1FK
				, cast(hc.ScreenDate as date) as ScreenDate
				, cast(hc.KempeDate as date) as KempeDate
				, cast(hc.IntakeDate as date) as IntakeDate
				, EDC
				, TCDOB
				, OBPinHomeIntake
				, PC2inHomeIntake
			from cteCohort co
			inner join CaseProgram cp on cp.CaseProgramPK = co.CaseProgramPK
			inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @programfk) cf on cf.HVCaseFK = hc.HVCasePK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
					and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK);
--#endregion
--#region cteLastFollowUp - Get last follow up completed for all cases in cohort
	with cteLastFollowUp as 
	-----------------------
		(select max(FollowUpPK) as FollowUpPK
			   , max(FollowUpDate) as FollowUpDate
			   , fu.HVCaseFK
			from FollowUp fu
			inner join #tmpCohort c on c.HVCasePK = fu.HVCaseFK
			group by fu.HVCaseFK
		)
--#endregion
--#region cteFollowUp* - get follow up common attribute rows and columns that we need for each person from the last follow up
	, cteFollowUpPC1 as
	-------------------
		(select MaritalStatus
				, PBTANF as PC1TANFAtDischarge
				, cappmarital.AppCodeText as MaritalStatusAtDischarge
				, cappgrade.AppCodeText as PC1EducationAtDischarge
				, IsCurrentlyEmployed AS PC1EmploymentAtDischarge
				, EducationalEnrollment AS EducationalEnrollmentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   left outer join codeApp cappmarital ON cappmarital.AppCode=MaritalStatus and cappmarital.AppCodeGroup='MaritalStatus'
		   left outer join codeApp cappgrade ON cappgrade.AppCode=HighestGrade and cappgrade.AppCodeGroup='Education'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC1'
		)
	, cteFollowUpOBP as
	-------------------
		(select IsCurrentlyEmployed as OBPEmploymentAtDischarge
				, OBPInHome as OBPInHomeAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-OBP'
		)
	, cteFollowUpPC2 as
	-------------------
		(select IsCurrentlyEmployed AS PC2EmploymentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC2'
		)
--#endregion
--#region tmpDischargeData - Get all discharge related data into temp table
    insert into #tmpDischargeData
	------------------------
		select co.HVCasePK as HVCaseFK
			    ,cd.DischargeReason as DischargeReason
				,PC1TANFAtDischarge
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,case 
					when pc1is.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtDischarge
				,case
					when pc1is.SubstanceAbuse = '1' 
						then 1
					else 0
				end as SubstanceAbuseAtDischarge
				,case 
					when pc1is.DomesticViolence = '1' 
						then 1
					else 0
				end as DomesticViolenceAtDischarge
				,case 
					when pc1is.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtDischarge
				,case 
					when pc1is.Depression = '1'
						then 1
					else 0
				end as DepressionAtDischarge
		from #tmpCohort co
		inner join CaseProgram cp on cp.PC1ID = co.PC1ID
		inner join Kempe k on k.HVCaseFK = co.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK = CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode = cp.DischargeReason 
		left outer join cteLastFollowUp lfu on lfu.HVCaseFK = co.HVCasePK
		left outer join FollowUp fu ON fu.FollowUpPK = lfu.FollowUpPK
		left outer join PC1Issues pc1is ON pc1is.PC1IssuesPK = fu.PC1IssuesFK
		left outer join cteFollowUpPC1 pc1fuca ON pc1fuca.HVCaseFK = co.HVCasePK
		left outer join cteFollowUpOBP obpfuca ON obpfuca.HVCaseFK = co.HVCasePK
		left outer join cteFollowUpPC2 pc2fuca ON pc2fuca.HVCaseFK = co.HVCasePK;

--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	with cteCaseLastHomeVisit AS 
	-----------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog vl
			inner join #tmpCohort co on co.HVCasePK = vl.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
			where substring(VisitType, 4, 1) <> '1'
			group by HVCaseFK
		)
--#endregion
--#region cteCaseFSWCount - get the count of FSWs for each case in the cohort, i.e. how many times it's changed
	, cteCaseFSWCount AS 
	------------------------
		(select HVCaseFK
					, count(wa.WorkerAssignmentPK) as CountOfFSWs
			from dbo.WorkerAssignment wa
			inner join #tmpCohort co on co.HVCasePK = wa.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			group by HVCaseFK
		)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, ctePC1AgeAtIntake as
	------------------------
		(select c.HVCasePK as HVCaseFK
				,datediff(year,PCDOB,co.IntakeDate) as PC1AgeAtIntake
			from PC 
			inner join HVCase c on c.PC1FK=PCPK
			inner join #tmpCohort co on co.HVCasePK = c.HVCasePK
		)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, cteTCInformation as
	------------------------
		(select t.HVCaseFK
				, max(t.TCDOB) as TCDOB
				, max(GestationalAge) as GestationalAge
			from TCID t
			inner join #tmpCohort co on co.HVCasePK = t.HVCaseFK
			inner join HVCase c on c.HVCasePK = co.HVCasePK
			group by t.HVCaseFK
		)
	, cteParity as 
	----------------------
		(select cp.HVCaseFK
				, max(case when ca.Parity is null
					then -1
					else convert(int, ca.Parity)
				end) as MaxParity
			from #tmpCohort tc
			inner join CaseProgram cp on cp.PC1ID = tc.PC1ID
			inner join CommonAttributes ca on ca.HVCaseFK = cp.HVCaseFK and ca.FormType in ('KE', 'TC')
			group by cp.HVCaseFK
		)
--#endregion
--#region cteMain - get data at intake, join to data at discharge and add to report cache table
	insert into #tmpMain
           ([ProgramFK]
           ,[PC1ID]
           ,[HVCaseFK]
		   ,[ScreenDate]
		   ,[KempeDate]
           ,[IntakeDate]
           ,[LastHomeVisit]
           ,[CountOfFSWs]
           ,[CountOfHomeVisits]
           ,[DischargeDate]
           ,[LevelName]
           ,[DischargeReasonCode]
           ,[DischargeReason]
           ,[PC1AgeAtIntake]
           ,[ActiveAt3Months]
           ,[ActiveAt6Months]
           ,[ActiveAt12Months]
           ,[ActiveAt18Months]
           ,[ActiveAt24Months]
           ,[ActiveAt36Months]
		   ,Race_AmericanIndian
		   ,Race_Asian
		   ,Race_Black
		   ,Race_Hawaiian
		   ,Race_White
		   ,Race_Other
		   ,Race_Hispanic
           ,RaceSpecify
		   ,[MaxParity]
           ,[MaritalStatus]
           ,[MaritalStatusAtIntake]
           ,[MomScore]
           ,[DadScore]
           ,[PartnerScore]
		   ,[EffectiveKempeScore]
           ,[HighestGrade]
           ,[PC1EducationAtIntake]
           ,[PC1EmploymentAtIntake]
           ,[PC1PrimaryLanguageAtIntake]
           ,[TCDOB]
           ,[PrenatalEnrollment]
           ,[AlcoholAbuseAtIntake]
           ,[SubstanceAbuseAtIntake]
           ,[DomesticViolenceAtIntake]
           ,[MentalIllnessAtIntake]
           ,[DepressionAtIntake]
           ,[PC1TANFAtIntake]
           ,[ConceptionDate])
		select @ProgramFK as ProgramFK
			   ,c.PC1ID
			   ,c.HVCasePK as HVCaseFK
			   ,c.ScreenDate
			   ,c.KempeDate
			   ,c.IntakeDate
			   ,LastHomeVisit
			   ,CountOfFSWs
			   ,CountOfHomeVisits
			   ,DischargeDate
			   ,LevelName
			   ,cp.DischargeReason AS DischargeReasonCode
               ,dd.DischargeReason
			   ,PC1AgeAtIntake
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 3 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 3 then 1
					else 0
				end	as ActiveAt3Months
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
					else 0
				end	as ActiveAt12Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 18 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 18 then 1
					else 0
				end as ActiveAt18Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 24 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 24 then 1
					else 0
				end as ActiveAt24Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 36 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 36 then 1
					else 0
				end as ActiveAt36Months
			   ,Race_AmericanIndian
			   ,Race_Asian
			   ,Race_Black
			   ,Race_Hawaiian
			   ,Race_White
			   ,Race_Other
			   ,Race_Hispanic
			   ,RaceSpecify
			   ,p.MaxParity
			   ,MaritalStatus
			   ,MaritalStatusAtIntake
			   ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
			   ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore
			   ,case when PartnerScore = 'U' then 0 else cast(PartnerScore as int) end as PartnerScore
			   ,case when cast(MomScore as int) > cast(DadScore as int) 
						then cast(MomScore as int) 
						else cast(DadScore as int)
					end as EffectiveKempeScore
			   ,HighestGrade
			   ,PC1EducationAtIntake
			   ,PC1EmploymentAtIntake
			   ,PrimaryLanguage as PC1PrimaryLanguageAtIntake
			   ,case 
			   		when c.TCDOB is NULL then EDC
					else c.TCDOB
				end as TCDOB
			   ,case 
					when c.TCDOB is null and EDC is not null then 1
					when c.TCDOB is not null and c.TCDOB > IntakeDate then 1
					when c.TCDOB is not null and c.TCDOB <= IntakeDate then 0
				end
				as PrenatalEnrollment
				,case 
					when pc1i.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtIntake
				,case 
					when pc1i.SubstanceAbuse = '1'
						then 1
					else 0
				end as SubstanceAbuseAtIntake
				,case 
					when pc1i.DomesticViolence = '1'
						then 1
					else 0
				end as DomesticViolenceAtIntake
				,case 
					when pc1i.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtIntake
				,case 
					when pc1i.Depression = '1'
						then 1
					else 0
				end as DepressionAtIntake
				,PC1TANFAtIntake
				, case when c.TCDOB is null then dateadd(week, -40, c.EDC) 
						when tci.HVCaseFK is null and c.TCDOB is not null
							then dateadd(week, -40, c.TCDOB)
						when tci.HVCaseFK is not NULL and c.TCDOB is not null 
							then dateadd(week, -40, dateadd(week, (40 - isnull(GestationalAge, 40)), c.TCDOB) )
					end as ConceptionDate
			FROM #tmpCohort c 
			left outer join #tmpDischargeData dd ON dd.HVCaseFK = c.HVCasePK
			inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK = c.HVCasePK
			inner join cteCaseFSWCount fc ON fc.HVCaseFK = c.HVCasePK
			inner join ctePC1AgeAtIntake aai on aai.HVCaseFK = c.HVCasePK
			inner join CaseProgram cp on cp.PC1ID = c.PC1ID
			inner join PC on PC.PCPK = c.PC1FK
			inner join Kempe k on k.HVCaseFK = c.HVCasePK
			inner join PC1Issues pc1i ON pc1i.HVCaseFK = k.HVCaseFK AND pc1i.PC1IssuesPK = k.PC1IssuesFK
			inner join codeLevel cl ON cl.codeLevelPK = CurrentLevelFK
			left outer join cteTCInformation tci on tci.HVCaseFK = c.HVCasePK
			left outer join cteParity p on p.HVCaseFK = cp.HVCaseFK
			left outer join (select PBTANF as PC1TANFAtIntake
									,HVCaseFK 
							   from CommonAttributes ca
							  where FormType='IN') inca ON inca.HVCaseFK = c.HVCasePK
			left outer join (select MaritalStatus
									,AppCodeText as MaritalStatusAtIntake
									,IsCurrentlyEmployed AS PC1EmploymentAtIntake
									,EducationalEnrollment
									,PrimaryLanguage
									,HVCaseFK 
							   from CommonAttributes ca
							   left outer join codeApp capp ON capp.AppCode = MaritalStatus and AppCodeGroup = 'MaritalStatus'
							  where FormType = 'IN-PC1') pc1ca ON pc1ca.HVCaseFK = c.HVCasePK
			left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtIntake
									,HVCaseFK 
							   FROM CommonAttributes ca
							  WHERE FormType = 'IN-OBP') obpca ON obpca.HVCaseFK = c.HVCasePK
			left outer join (SELECT HVCaseFK
									, IsCurrentlyEmployed AS PC2EmploymentAtIntake
							   FROM CommonAttributes ca
							  WHERE FormType = 'IN-PC2') pc2ca ON pc2ca.HVCaseFK = c.HVCasePK
			left outer join (SELECT AppCodeText as PC1EducationAtIntake,HighestGrade,HVCaseFK 
							   FROM CommonAttributes ca
							   LEFT OUTER JOIN codeApp capp ON capp.AppCode = HighestGrade and AppCodeGroup = 'Education'
							  WHERE FormType = 'IN-PC1') pc1eduai ON pc1eduai.HVCaseFK = c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)

--#endregion

--#region declarations
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @casefilterspositive = case	when @casefilterspositive = '' then null
									else @casefilterspositive
							   end

	declare @tblResults table (
		FactorType varchar(30)
		, LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateThreeMonths decimal(5,3)
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, RetentionRateThreeYears decimal(5,3)
		, EnrolledParticipantsThreeMonths int
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, EnrolledParticipantsThreeYears int
		, RunningTotalDischargedThreeMonths int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, RunningTotalDischargedThreeYears int
		, TotalNThreeMonths int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, TotalNThreeYears int
		, AllParticipants int
		, ThreeMonthsIntake int
		, SixMonthsIntake int
		, OneYearIntake int 
		, EighteenMonthsIntake int
		, TwoYearsIntake int
		, ThreeYearsIntake int);

	declare @tblPC1WithStats table (
		PC1ID char(13)
		, ScreenDate date
		, KempeDate date
		, DaysBetween int
		, IntakeDate date
		, DischargeDate datetime
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt3Months int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int
		, ActiveAt36Months int
		, AgeAtIntake_Under18 int
		, AgeAtIntake_18UpTo20 int
		, AgeAtIntake_20UpTo30 int
		, AgeAtIntake_Over30 int
		, Race_AmericanIndian BIT NULL
		, Race_Asian BIT NULL
		, Race_Black BIT NULL
		, Race_Hawaiian BIT NULL
		, Race_White BIT NULL
		, Race_Other BIT NULL
		, Race_Hispanic BIT NULL
		, RaceSpecify VARCHAR(500) NULL
		, MarriedAtIntake int
		, NeverMarriedAtIntake int
		, SeparatedAtIntake int
		, DivorcedAtIntake int
		, WidowedAtIntake int
		, MarriedUnknownMissingAtIntake int
		, OtherChildrenInHouseholdAtIntake int
		, NoOtherChildrenInHouseholdAtIntake int
		, ReceivingTANFAtIntake int
		, NotReceivingTANFAtIntake int
		, MomScore int
		, DadScore int
		, PartnerScore int
		, EffectiveKempeScore int
		, PC1EducationAtIntakeLessThan12 int
		, PC1EducationAtIntakeHSGED int
		, PC1EducationAtIntakeMoreThan12 int
		, PC1EducationAtIntakeUnknownMissing int
		, PC1EmploymentAtIntakeYes int
		, PC1EmploymentAtIntakeNo int
		, PC1EmploymentAtIntakeUnknownMissing int
		, CountOfHomeVisits int
		, CurrentLevelAtDischarge1 int
		, CurrentLevelAtDischarge2 int
		, CurrentLevelAtDischarge3 int
		, CurrentLevelAtDischarge4 int
		, CurrentLevelAtDischargeX int
		, CurrentLevelAtDischargePrenatal int
		, CurrentLevelAtDischargeOther int
		, PC1DVAtIntake int
		, PC1MHAtIntake int
		, PC1SAAtIntake int
		, PC1PrimaryLanguageAtIntakeEnglish int
		, PC1PrimaryLanguageAtIntakeSpanish int
		, PC1PrimaryLanguageAtIntakeOtherUnknown int
		, TrimesterAtIntakePostnatal int
		, TrimesterAtIntake3rd int
		, TrimesterAtIntake2nd int
		, TrimesterAtIntake1st int
		, CountOfFSWs int
		, ParityFirstTime int
		, Parity1Prior int
		, Parity2OrMorePrior int
		, ParityUnknownMissing int);

--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	with cteMain as
	------------------------
		(select tm.PC1ID
			  , tm.HVCaseFK
			  , tm.ScreenDate
			  , tm.KempeDate
			  , datediff(day, tm.ScreenDate, tm.KempeDate) as DaysBetween
			  , tm.IntakeDate
			  , tm.LastHomeVisit
			  , tm.CountOfFSWs
			  , tm.CountOfHomeVisits
			  , tm.DischargeDate
			  , tm.LevelName
			  , tm.DischargeReasonCode
			  , tm.DischargeReason
			  , tm.PC1AgeAtIntake
			  , tm.ActiveAt3Months
			  , tm.ActiveAt6Months
			  , tm.ActiveAt12Months
			  , tm.ActiveAt18Months
			  , tm.ActiveAt24Months
			  , tm.ActiveAt36Months
			  , tm.Race_AmericanIndian
			  , tm.Race_Asian
			  , tm.Race_Black
			  , tm.Race_Hawaiian
			  , tm.Race_White
			  , tm.Race_Other
			  , tm.Race_Hispanic
			  , tm.RaceSpecify
			  , tm.MaxParity
			  , tm.MaritalStatus
			  , tm.MaritalStatusAtIntake
			  , tm.MomScore
			  , tm.DadScore
			  , tm.PartnerScore
			  , tm.EffectiveKempeScore
			  , tm.HighestGrade
			  , tm.PC1EducationAtIntake
			  , tm.PC1EmploymentAtIntake
			  , tm.PC1PrimaryLanguageAtIntake
			  , tm.TCDOB
			  , tm.PrenatalEnrollment
			  , tm.AlcoholAbuseAtIntake
			  , tm.SubstanceAbuseAtIntake
			  , tm.DomesticViolenceAtIntake
			  , tm.MentalIllnessAtIntake
			  , tm.DepressionAtIntake
			  , tm.PC1TANFAtIntake
			  , tm.ConceptionDate
			from #tmpMain tm
			inner join CaseProgram cp on cp.PC1ID = tm.PC1ID
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = tm.HVCaseFK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where tm.ProgramFK = @ProgramFK
					and case when @SiteFK = 0 then 1
								 when wp.SiteFK = @SiteFK then 1
								 else 0
							end = 1
					and (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
					and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
		)

--#endregion

--select *
--from cteDischargeData

--select *
--from cteMain

--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#region Add rows to @tblPC1WithStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1WithStats 
		(PC1ID
		, ScreenDate
		, KempeDate
		, DaysBetween
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt3Months
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, ActiveAt36Months
		, AgeAtIntake_Under18
		, AgeAtIntake_18UpTo20
		, AgeAtIntake_20UpTo30
		, AgeAtIntake_Over30
		, Race_AmericanIndian
		, Race_Asian
		, Race_Black
		, Race_Hawaiian
		, Race_White
		, Race_Other
		, Race_Hispanic
		, RaceSpecify
		, MarriedAtIntake
		, NeverMarriedAtIntake
		, SeparatedAtIntake
		, DivorcedAtIntake
		, WidowedAtIntake
		, MarriedUnknownMissingAtIntake
		, ReceivingTANFAtIntake
		, NotReceivingTANFAtIntake
		, MomScore
		, DadScore
		, PartnerScore
		, EffectiveKempeScore
		, PC1EducationAtIntakeLessThan12
		, PC1EducationAtIntakeHSGED
		, PC1EducationAtIntakeMoreThan12
		, PC1EducationAtIntakeUnknownMissing
		, PC1EmploymentAtIntakeYes
		, PC1EmploymentAtIntakeNo
		, PC1EmploymentAtIntakeUnknownMissing
		, CountOfHomeVisits
		, CurrentLevelAtDischarge1
		, CurrentLevelAtDischarge2
		, CurrentLevelAtDischarge3
		, CurrentLevelAtDischarge4
		, CurrentLevelAtDischargeX
		, CurrentLevelAtDischargePrenatal
		, CurrentLevelAtDischargeOther
		, PC1DVAtIntake
		, PC1MHAtIntake
		, PC1SAAtIntake
		, PC1PrimaryLanguageAtIntakeEnglish
		, PC1PrimaryLanguageAtIntakeSpanish
		, PC1PrimaryLanguageAtIntakeOtherUnknown
		, TrimesterAtIntakePostnatal
		, TrimesterAtIntake3rd
		, TrimesterAtIntake2nd
		, TrimesterAtIntake1st
		, CountOfFSWs
		, ParityFirstTime
		, Parity1Prior
		, Parity2OrMorePrior
		, ParityUnknownMissing)
select distinct PC1ID
		, ScreenDate
		, KempeDate
		, DaysBetween
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		,case when DischargeDate is not null then 
				datediff(mm,IntakeDate,LastHomeVisit)
			else
				datediff(mm,IntakeDate,current_timestamp)
			end as RetentionMonths
		, ActiveAt3Months
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, ActiveAt36Months
		, case when PC1AgeAtIntake < 18 then 1 else 0 end as AgeAtIntake_Under18
		, case when PC1AgeAtIntake between 18 and 19 then 1 else 0 end as AgeAtIntake_18UpTo20
		, case when PC1AgeAtIntake between 20 and 29 then 1 else 0 end as AgeAtIntake_20UpTo30
		, case when PC1AgeAtIntake >= 30 then 1 else 0 end as AgeAtIntake_Over30
		, cteMain.Race_AmericanIndian
		, cteMain.Race_Asian
		, cteMain.Race_Black
		, cteMain.Race_Hawaiian
		, cteMain.Race_White
		, cteMain.Race_Other
		, cteMain.Race_Hispanic
		, cteMain.RaceSpecify
		, case when MaritalStatusAtIntake = 'Married' then 1 else 0 end as MarriedAtIntake
		, case when MaritalStatusAtIntake = 'Never married' then 1 else 0 end as NeverMarriedAtIntake
		, case when MaritalStatusAtIntake = 'Separated' then 1 else 0 end as SeparatedAtIntake
		, case when MaritalStatusAtIntake = 'Divorced' then 1 else 0 end as DivorcedAtIntake
		, case when MaritalStatusAtIntake = 'Widowed' then 1 else 0 end as WidowedAtIntake
		, case when MaritalStatusAtIntake is null or MaritalStatusAtIntake='' or left(MaritalStatusAtIntake,7) = 'Unknown' then 1 else 0 end as MarriedUnknownMissingAtIntake
		, case when PC1TANFAtIntake = 1 then 1 else 0 end as ReceivingTANFAtIntake
		, case when PC1TANFAtIntake = 0 or PC1TANFAtIntake is null or PC1TANFAtIntake = '' then 1 else 0 end as NotReceivingTANFAtIntake
		, MomScore
		, DadScore
		, PartnerScore
		, EffectiveKempeScore
		, case when PC1EducationAtIntake in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtIntakeLessThan12
		, case when PC1EducationAtIntake in ('High school grad','GED') then 1 else 0 end as PC1EducationAtIntakeHSGED
		, case when PC1EducationAtIntake in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtIntakeMoreThan12
		, case when PC1EducationAtIntake is null or PC1EducationAtIntake = '' then 1 else 0 end as PC1EducationAtIntakeUnknownMissing
		, case when PC1EmploymentAtIntake = '1' then 1 else 0 end as PC1EmploymentAtIntakeYes
		, case when PC1EmploymentAtIntake = '0' then 1 else 0 end as PC1EmploymentAtIntakeNo
		, case when PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '' then 1 else 0 end as PC1EmploymentAtIntakeUnknownMissing
		, CountOfHomeVisits
		, case when left(LevelName,7) = 'Level 1' and charindex('Prenatal', LevelName) = 0
				then 1 else 0 end as CurrentLevelAtDischarge1
		, case when left(LevelName,7) = 'Level 2' and charindex('Prenatal', LevelName) = 0
				then 1 else 0 end as CurrentLevelAtDischarge2
		, case when left(LevelName,7) = 'Level 3' then 1 else 0 end as CurrentLevelAtDischarge3
		, case when left(LevelName,7) = 'Level 4' then 1 else 0 end as CurrentLevelAtDischarge4
		, case when left(LevelName,8) = 'Level CO' then 1 else 0 end as CurrentLevelAtDischargeX
		, case when charindex('Prenatal', LevelName) >= 1 then 1 else 0 end as CurrentLevelAtDischargePrenatal
		, case when left(LevelName,7) <> 'Level 1' and left(LevelName,7) <> 'Level 2' and 
					left(LevelName,7) <> 'Level 3' and left(LevelName,7) <> 'Level 4' and 
					left(LevelName,8) <> 'Level CO'
				then 1 else 0 end as CurrentLevelAtDischargeOther
		, case when DomesticViolenceAtIntake = 1 then 1 else 0 end as PC1DVAtIntake
		, case when MentalIllnessAtIntake = 1 or DepressionAtIntake = 1 then 1 else 0 end as PC1MHAtIntake
		, case when AlcoholAbuseAtIntake = 1 or SubstanceAbuseAtIntake = 1 then 1 else 0 end as PC1SAAtIntake
		, case when PC1PrimaryLanguageAtIntake = '01' then 1 else 0 end as PC1PrimaryLanguageAtIntakeEnglish
		, case when PC1PrimaryLanguageAtIntake = '02' then 1 else 0 end as PC1PrimaryLanguageAtIntakeSpanish
		, case when PC1PrimaryLanguageAtIntake = '03' or PC1PrimaryLanguageAtIntake is null or PC1PrimaryLanguageAtIntake = '' then 1 else 0 end as PC1PrimaryLanguageAtIntakeOtherUnknown
		, case when IntakeDate >= TCDOB then 1 else 0 end as TrimesterAtIntakePostnatal
		, case when IntakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) > round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake3rd
		, case when IntakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) between round(30.44*3,0)+1 and round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake2nd
		, case when IntakeDate < TCDOB and datediff(dd, ConceptionDate, IntakeDate) < 3*30.44  then 1 else 0 end as TrimesterAtIntake1st
		, CountOfFSWs
		, case when MaxParity = 0 then 1 else 0 end as ParityFirstTime
		, case when MaxParity = 1 then 1 else 0 end as Parity1Prior
		, case when MaxParity >= 2 then 1 else 0 end as Parity2OrMorePrior
		, case when MaxParity = -1 then 1 else 0 end as ParityUnknownMissing
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is null or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37')
		-- (DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') or datediff(day,IntakeDate,DischargeDate)>=(4*6*30.44))
order by PC1ID,IntakeDate
--#endregion
--SELECT * FROM @tblPC1WithStats

declare @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1WithStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  from @tblPC1WithStats

--#region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateThreeMonths decimal(5,3)
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @RetentionRateThreeYears decimal(5,3)
		, @EnrolledParticipantsThreeMonths int
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @EnrolledParticipantsThreeYears int
		, @RunningTotalDischargedThreeMonths int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @RunningTotalDischargedThreeYears int
		, @TotalNThreeMonths int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int
		, @TotalNThreeYears int

declare @AllEnrolledParticipants int
		, @ThreeMonthsTotal int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @ThirtySixMonthsTotal int
		, @ThreeMonthsAtIntake int
		, @SixMonthsAtIntake int
		, @TwelveMonthsAtIntake int
		, @EighteenMonthsAtIntake int
		, @TwentyFourMonthsAtIntake int
		, @ThirtySixMonthsAtIntake int
--#endregion
--#region Retention Rate %
select @ThreeMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt3Months = 1

select @SixMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt6Months = 1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1WithStats
where ActiveAt12Months = 1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months = 1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months = 1

select @ThirtySixMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt36Months = 1

set @RetentionRateThreeMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@ThreeMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateSixMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount = 0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount = 0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateThreeYears = case when @TotalCohortCount = 0 then 0.0000 else round((@ThirtySixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--#endregion
--#region Enrolled Participants
select @EnrolledParticipantsThreeMonths = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 

select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1WithStats
where ActiveAt12Months = 1

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1

select @EnrolledParticipantsThreeYears = count(*)
from @tblPC1withStats
where ActiveAt36Months = 1
--#endregion
--#region Running Total Discharged
select @RunningTotalDischargedThreeMonths = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedSixMonths = count(*) + @RunningTotalDischargedThreeMonths
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedThreeYears = count(*) + @RunningTotalDischargedTwoYears
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and LastHomeVisit is not null

--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1WithStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1WithStats
--where ActiveAt24Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Total (N) - (Discharged)
select @TotalNThreeMonths = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and LastHomeVisit is not null

select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null

select @TotalNThreeYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and LastHomeVisit is not null
--#endregion
--#region Age @ Intake
--			Under 18
--			18 up to 20
--			20 up to 30
--			30 and over
set @LineGroupingLevel = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Age @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where AgeAtIntake_Under18 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and AgeAtIntake_Under18 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and AgeAtIntake_Under18 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Under18 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Under18 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Under18 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and AgeAtIntake_Under18 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Under 18'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where AgeAtIntake_18upto20 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and AgeAtIntake_18upto20 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and AgeAtIntake_18upto20 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_18upto20 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_18upto20 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_18upto20 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and AgeAtIntake_18upto20 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    18 up to 20'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_20upto30 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and AgeAtIntake_20upto30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and AgeAtIntake_20upto30 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_20upto30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_20upto30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_20upto30 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and AgeAtIntake_20upto30 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    20 up to 30'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_Over30 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and AgeAtIntake_Over30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and AgeAtIntake_Over30 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Over30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Over30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Over30 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and AgeAtIntake_Over30 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    30 and Over'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Marital Status
--			Married
--			Not Married
--			Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Marital Status'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and MarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and MarriedAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and MarriedAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NeverMarriedAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and NeverMarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and NeverMarriedAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NeverMarriedAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NeverMarriedAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NeverMarriedAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and NeverMarriedAtIntake  = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Never Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where SeparatedAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and SeparatedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and SeparatedAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and SeparatedAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and SeparatedAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and SeparatedAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and SeparatedAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Separated'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DivorcedAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and DivorcedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and DivorcedAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DivorcedAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DivorcedAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DivorcedAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and DivorcedAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Divorced'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where WidowedAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and WidowedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and WidowedAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and WidowedAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and WidowedAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and WidowedAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and WidowedAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Widowed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedUnknownMissingAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and MarriedUnknownMissingAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and MarriedUnknownMissingAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedUnknownMissingAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedUnknownMissingAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedUnknownMissingAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and MarriedUnknownMissingAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Parity
-- Parity
--		First-time parent
--		1 prior child
--		2 or more prior children
--		Unknown/Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Parity'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where ParityFirstTime = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and ParityFirstTime = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and ParityFirstTime = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ParityFirstTime = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ParityFirstTime = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ParityFirstTime = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and ParityFirstTime = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    First-time parent'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where Parity1Prior = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity1Prior = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity1Prior = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity1Prior = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity1Prior = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity1Prior = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity1Prior = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    1 prior child'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where Parity2OrMorePrior = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity2OrMorePrior = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity2OrMorePrior = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity2OrMorePrior = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity2OrMorePrior = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity2OrMorePrior = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity2OrMorePrior = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    2 or more prior children'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where ParityUnknownMissing = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and ParityUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and ParityUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ParityUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ParityUnknownMissing = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ParityUnknownMissing = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and ParityUnknownMissing = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Unknown/Missing'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Education
-- Education
--		Less than 12
--		HS / GED
--		More than 12
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'PC1 Education'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeLessThan12 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EducationAtIntakeLessThan12 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Less than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeHSGED = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EducationAtIntakeHSGED = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EducationAtIntakeHSGED = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeHSGED = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeHSGED = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeHSGED = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EducationAtIntakeHSGED = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    HS / GED'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeMoreThan12 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    More Than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeUnknownMissing = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region PC1 Employed
-- PC1 Employed
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'PC1 Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeYes = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EmploymentAtIntakeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeYes = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EmploymentAtIntakeYes = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeNo = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EmploymentAtIntakeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeNo = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EmploymentAtIntakeNo = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeUnknownMissing = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Primary Language @ Intake
-- Primary Language @ Intake
--		English
--		Spanish
--		Other / Unknown
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Primary Language @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeEnglish = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    English'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeSpanish = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Spanish'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Other/Missing/Unk.'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Race
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Race'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_AmericanIndian = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_AmericanIndian = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_AmericanIndian = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_AmericanIndian = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_AmericanIndian = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_AmericanIndian = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_AmericanIndian = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    American Indian or Alaskan Native'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Asian = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Asian = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Asian = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Asian = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Asian = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Asian = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Asian = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Asian'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Black = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Black = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Black = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Black = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Black = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Black = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Black = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Black or African-American'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Hawaiian = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Hawaiian = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Hawaiian = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Hawaiian = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Hawaiian = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Hawaiian = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Hawaiian = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Native Hawaiian or Other Pacific Islander'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_White = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_White = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_White = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_White = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_White = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_White = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_White = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    White'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Other = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Other = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Other = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Other = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Other = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Other = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Other = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Other'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Unknown / Missing'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
		
--#endregion
--#region Ethnicity

set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Demographic Factors at Intake'
		, 'Ethnicity'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Hispanic = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Hispanic = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Hispanic = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Hispanic = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Hispanic = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Hispanic = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Hispanic = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Hispanic'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Hispanic = 0

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Hispanic = 0

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Hispanic = 0

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Hispanic = 0

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Hispanic = 0

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Hispanic = 0

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Hispanic = 0

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Non-Hispanic'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where Race_Hispanic IS NULL

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and Race_Hispanic IS NULL

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Race_Hispanic IS NULL

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Race_Hispanic IS NULL

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Race_Hispanic IS NULL

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Race_Hispanic IS NULL

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Race_Hispanic IS NULL

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Demographic Factors at Intake'
		, '    Unknown / Missing'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

--#endregion
--#region Average # of Actual Home Visits
-- Average # of Actual Home Visits
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Programmatic Factors'
		, 'Average # of Actual Home Visits'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfHomeVisits between 0 and 10

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and CountOfHomeVisits between 0 and 10

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CountOfHomeVisits between 0 and 10

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfHomeVisits between 0 and 10

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfHomeVisits between 0 and 10

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfHomeVisits between 0 and 10

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CountOfHomeVisits between 0 and 10

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    0-10'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfHomeVisits between 11 and 20

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and CountOfHomeVisits between 11 and 20

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CountOfHomeVisits between 11 and 20

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfHomeVisits between 11 and 20

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfHomeVisits between 11 and 20

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfHomeVisits between 11 and 20

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CountOfHomeVisits between 11 and 20

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    11-20'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfHomeVisits > 20

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and CountOfHomeVisits > 20

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CountOfHomeVisits > 20

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfHomeVisits > 20

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfHomeVisits > 20

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfHomeVisits > 20

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CountOfHomeVisits > 20

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    > 20'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Level at Discharge
-- Level At Discharge
--		Level 1
--		Level 2
--		Level 3
--		Level 4
--		Level X
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Programmatic Factors'
		, 'Level at Discharge'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischarge1 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischarge1 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischarge1 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischarge1 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischarge1 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischarge1 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischarge1 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Level 1'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischarge2 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischarge2 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischarge2 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischarge2 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischarge2 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischarge2 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischarge2 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Level 2'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischarge3 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischarge3 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischarge3 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischarge3 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischarge3 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischarge3 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischarge3 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Level 3'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischarge4 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischarge4 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischarge4 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischarge4 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischarge4 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischarge4 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischarge4 = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Level 4'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischargeX = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischargeX = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischargeX = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischargeX = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischargeX = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischargeX = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischargeX = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Level X'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischargePrenatal = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischargePrenatal = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischargePrenatal = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischargePrenatal = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischargePrenatal = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischargePrenatal = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischargePrenatal = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Prenatal'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
		
select @AllEnrolledParticipants = count(*)
from @tblPC1WithStats
where CurrentLevelAtDischargeOther = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and CurrentLevelAtDischargeOther = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CurrentLevelAtDischargeOther = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CurrentLevelAtDischargeOther = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CurrentLevelAtDischargeOther = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CurrentLevelAtDischargeOther = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CurrentLevelAtDischargeOther = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Other'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
		
--#endregion
--#region Cases with More than 1 Home Visitor
-- Cases with More than 1 Home Visitor
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Programmatic Factors'
		, 'More than 1 Home Visitor Since Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfFSWs>1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and CountOfFSWs > 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CountOfFSWs > 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfFSWs > 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfFSWs > 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfFSWs > 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CountOfFSWs > 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfFSWs <= 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and CountOfFSWs <= 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and CountOfFSWs <= 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfFSWs <= 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfFSWs <= 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfFSWs <= 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and CountOfFSWs <= 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Time Between Screen and Assessment
-- Time Between Screen and Assessment
--		Between 0 and 30 days
--		Between 31 and 90 days
--		More than 90 days

set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Programmatic Factors'
		, 'Time Between Screen and Assessment (days)'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DaysBetween between 0 and 30

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and DaysBetween between 0 and 30

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and DaysBetween between 0 and 30

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DaysBetween between 0 and 30

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DaysBetween between 0 and 30

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DaysBetween between 0 and 30

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and DaysBetween between 0 and 30

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Between 0 and 30'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DaysBetween between 31 and 90

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and DaysBetween between 31 and 90

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and DaysBetween between 31 and 90

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DaysBetween between 31 and 90

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DaysBetween between 31 and 90

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DaysBetween between 31 and 90

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and DaysBetween between 31 and 90

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Between 31 and 90'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DaysBetween > 90

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and DaysBetween > 90

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and DaysBetween > 90

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DaysBetween > 90

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DaysBetween > 90

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DaysBetween > 90

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and DaysBetween > 90

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    More than 90'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Trimester @ Intake
-- Trimester @ Intake
--		Postnatal
--		1st
--		2nd
--		3rd
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Programmatic Factors'
		, 'Trimester @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntakePostnatal = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and TrimesterAtIntakePostnatal = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntakePostnatal = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntakePostnatal = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and TrimesterAtIntakePostnatal = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    Postnatal'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake1st = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and TrimesterAtIntake1st = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and TrimesterAtIntake1st = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake1st = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake1st = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake1st = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and TrimesterAtIntake1st = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    1st'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake2nd = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and TrimesterAtIntake2nd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and TrimesterAtIntake2nd = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake2nd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake2nd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake2nd = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and TrimesterAtIntake2nd = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    2nd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake3rd = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and TrimesterAtIntake3rd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and TrimesterAtIntake3rd = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake3rd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake3rd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake3rd = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and TrimesterAtIntake3rd = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Programmatic Factors'
		, '    3rd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Kempe Score
-- Kempe Score
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Social Factors at Intake'
		, 'Parent Survey Score'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where EffectiveKempeScore between 25 and 49

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and EffectiveKempeScore between 25 and 49

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and EffectiveKempeScore between 25 and 49

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and EffectiveKempeScore between 25 and 49

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and EffectiveKempeScore between 25 and 49

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and EffectiveKempeScore between 25 and 49

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and EffectiveKempeScore between 25 and 49

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    25-49'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where EffectiveKempeScore between 50 and 74

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and EffectiveKempeScore between 50 and 74

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and EffectiveKempeScore between 50 and 74

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and EffectiveKempeScore between 50 and 74

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and EffectiveKempeScore between 50 and 74

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and EffectiveKempeScore between 50 and 74

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and EffectiveKempeScore between 50 and 74

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    50-74'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where EffectiveKempeScore > 74

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and EffectiveKempeScore > 74

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and EffectiveKempeScore > 74

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and EffectiveKempeScore > 74

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and EffectiveKempeScore > 74

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and EffectiveKempeScore > 74

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and EffectiveKempeScore > 74

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    75+'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region Whose Kempe Score Qualifies
-- Whose Kempe Score Qualifies
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Social Factors at Intake'
		, 'Whose Parent Survey Score Qualifies'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MomScore > 24 and DadScore <= 24

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and MomScore > 24 and DadScore <= 24

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and MomScore > 24 and DadScore <= 24

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MomScore > 24 and DadScore <= 24

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MomScore > 24 and DadScore <= 24

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MomScore > 24 and DadScore <= 24

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and MomScore > 24 and DadScore <= 24

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    Mother Only'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MomScore <= 24 and DadScore > 24

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and MomScore <= 24 and DadScore > 24

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and MomScore <= 24 and DadScore > 24

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MomScore <= 24 and DadScore > 24

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MomScore <= 24 and DadScore > 24

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MomScore <= 24 and DadScore > 24

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and MomScore <= 24 and DadScore > 24

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    Father Only'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MomScore > 24 and DadScore > 24

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and MomScore > 24 and DadScore > 24

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and MomScore > 24 and DadScore > 24

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MomScore > 24 and DadScore > 24

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MomScore > 24 and DadScore > 24

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MomScore > 24 and DadScore > 24

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and MomScore > 24 and DadScore > 24

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    Both Parents'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region PC1 Current Issues
-- PC1 Current Issues
--		DV
--		MH
--		SA
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears)
values ('Social Factors at Intake'
		, 'PC1 Current Issues at Parent Survey'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1DVAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1DVAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1DVAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1DVAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1DVAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1DVAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1DVAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    DV'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1MHAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1MHAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1MHAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1MHAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1MHAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1MHAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1MHAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    MH'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1SAAtIntake = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and PC1SAAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and PC1SAAtIntake = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1SAAtIntake = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1SAAtIntake = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1SAAtIntake = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and PC1SAAtIntake = 1

insert into @tblResults (FactorType
						, LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateThreeMonths
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, RetentionRateThreeYears
						, EnrolledParticipantsThreeMonths
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, EnrolledParticipantsThreeYears
						, RunningTotalDischargedThreeMonths
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, RunningTotalDischargedThreeYears
						, TotalNThreeMonths
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, TotalNThreeYears
						, AllParticipants
						, ThreeMonthsIntake
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake
						, ThreeYearsIntake)
values ('Social Factors at Intake'
		, '    SA'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateThreeMonths
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @RetentionRateThreeYears
		, @EnrolledParticipantsThreeMonths
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @EnrolledParticipantsThreeYears
		, @RunningTotalDischargedThreeMonths
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @RunningTotalDischargedThreeYears
		, @TotalNThreeMonths
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @TotalNThreeYears
		, @AllEnrolledParticipants
		, @ThreeMonthsAtIntake
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake
		, @ThirtySixMonthsAtIntake)
--#endregion
--#region final select
--Chris Papas (3/29/2012) Modified this final select to get the proper retention rates for period requested
select FactorType
		, LineDescription
		, LineGroupingLevel
		, DisplayPercentages
		, TotalEnrolledParticipants
		, case when datediff(ww,@enddate,getdate()) >= 13 then RetentionRateThreeMonths else null end as RetentionRateThreeMonths
		, case when datediff(ww,@enddate,getdate()) >= 26 then RetentionRateSixMonths else null end as RetentionRateSixMonths
		, case when datediff(ww,@enddate,getdate()) >= 52 then RetentionRateOneYear else null end as RetentionRateOneYear
		, case when datediff(ww,@enddate,getdate()) >= 78 then RetentionRateEighteenMonths else null end as RetentionRateEighteenMonths
		, case when datediff(ww,@enddate,getdate()) >= 104 then RetentionRateTwoYears else null end as RetentionRateTwoYears
		, case when datediff(ww,@enddate,getdate()) >= 156 then RetentionRateThreeYears else null end as RetentionRateThreeYears
		, case when datediff(ww,@enddate,getdate()) >= 13 then EnrolledParticipantsThreeMonths else null end as EnrolledParticipantsThreeMonths
		, case when datediff(ww,@enddate,getdate()) >= 26 then EnrolledParticipantsSixMonths else null end as EnrolledParticipantsSixMonths
		, case when datediff(ww,@enddate,getdate()) >= 52 then EnrolledParticipantsOneYear else null end as EnrolledParticipantsOneYear
		, case when datediff(ww,@enddate,getdate()) >= 78 then EnrolledParticipantsEighteenMonths else null end as EnrolledParticipantsEighteenMonths
		, case when datediff(ww,@enddate,getdate()) >= 104 then EnrolledParticipantsTwoYears else null end as EnrolledParticipantsTwoYears
		, case when datediff(ww,@enddate,getdate()) >= 156 then EnrolledParticipantsThreeYears else null end as EnrolledParticipantsThreeYears
		, case when datediff(ww,@enddate,getdate()) >= 13 then RunningTotalDischargedThreeMonths else null end as RunningTotalDischargedThreeMonths
		, case when datediff(ww,@enddate,getdate()) >= 26 then RunningTotalDischargedSixMonths else null end as RunningTotalDischargedSixMonths
		, case when datediff(ww,@enddate,getdate()) >= 52 then RunningTotalDischargedOneYear else null end as RunningTotalDischargedOneYear
		, case when datediff(ww,@enddate,getdate()) >= 78 then RunningTotalDischargedEighteenMonths else null end as RunningTotalDischargedEighteenMonths
		, case when datediff(ww,@enddate,getdate()) >= 104 then RunningTotalDischargedTwoYears else null end as RunningTotalDischargedTwoYears
		, case when datediff(ww,@enddate,getdate()) >= 156 then RunningTotalDischargedThreeYears else null end as RunningTotalDischargedThreeYears
		, case when datediff(ww,@enddate,getdate()) >= 13 then TotalNThreeMonths else null end as TotalNThreeMonths
		, case when datediff(ww,@enddate,getdate()) >= 26 then TotalNSixMonths else null end as TotalNSixMonths
		, case when datediff(ww,@enddate,getdate()) >= 52 then TotalNOneYear else null end as TotalNOneYear
		, case when datediff(ww,@enddate,getdate()) >= 78 then TotalNEighteenMonths else null end as TotalNEighteenMonths
		, case when datediff(ww,@enddate,getdate()) >= 104 then TotalNTwoYears else null end as TotalNTwoYears
		, case when datediff(ww,@enddate,getdate()) >= 156 then TotalNThreeYears else null end as TotalNThreeYears
		, AllParticipants
		, case when datediff(ww,@enddate,getdate()) >= 13 then ThreeMonthsIntake else null end as ThreeMonthsIntake
		, case when datediff(ww,@enddate,getdate()) >= 26 then SixMonthsIntake else null end as SixMonthsIntake
		, case when datediff(ww,@enddate,getdate()) >= 52 then OneYearIntake else null end as OneYearIntake
		, case when datediff(ww,@enddate,getdate()) >= 78 then EighteenMonthsIntake else null end as EighteenMonthsIntake
		, case when datediff(ww,@enddate,getdate()) >= 104 then TwoYearsIntake else null end as TwoYearsIntake
		, case when datediff(ww,@enddate,getdate()) >= 156 then ThreeYearsIntake else null end as ThreeYearsIntake
from @tblResults
--SELECT * from @tblResults
--#endregion
--select VendorID, Employee, Orders
--from
--   (SELECT ActiveAt6Months, ActiveAt12Months, ActiveAt18Months, ActiveAt24Months
--   FROM @tblPC1withStats) p
--UNPIVOT
--   (Orders FOR Employee IN 
--      (Emp1, Emp2, Emp3, Emp4, Emp5)
--)AS unpvt;

end
GO
