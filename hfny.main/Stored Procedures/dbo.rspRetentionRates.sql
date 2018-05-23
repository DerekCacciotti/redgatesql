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
CREATE procedure [dbo].[rspRetentionRates]
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
	set @casefilterspositive = case	when @casefilterspositive = '' then null
									else @casefilterspositive
							   end

	declare @tblResults table (
		FactorType varchar(20)
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
		, RaceWhite int
		, RaceBlack int
		, RaceHispanic int
		, RaceAsian int
		, RaceNativeAmerican int
		, RaceMultiracial int
		, RaceOther int
		, RaceUnknownMissing int
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
		, Parity0 int
		, Parity1 int
		, Parity2 int
		, Parity3 int
		, Parity4 int
		, Parity5Plus int);

--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	with cteMain as
	------------------------
		(select trrm.PC1ID
			  , trrm.HVCaseFK
			  , trrm.ScreenDate
			  , trrm.KempeDate
			  , datediff(day, trrm.ScreenDate, trrm.KempeDate) as DaysBetween
			  , trrm.IntakeDate
			  , trrm.LastHomeVisit
			  , trrm.CountOfFSWs
			  , trrm.CountOfHomeVisits
			  , trrm.DischargeDate
			  , trrm.LevelName
			  , trrm.DischargeReasonCode
			  , trrm.DischargeReason
			  , trrm.PC1AgeAtIntake
			  , trrm.ActiveAt3Months
			  , trrm.ActiveAt6Months
			  , trrm.ActiveAt12Months
			  , trrm.ActiveAt18Months
			  , trrm.ActiveAt24Months
			  , trrm.ActiveAt36Months
			  , trrm.Race
			  , trrm.RaceText
			  , trrm.MaxParity
			  , trrm.MaritalStatus
			  , trrm.MaritalStatusAtIntake
			  , trrm.MomScore
			  , trrm.DadScore
			  , trrm.PartnerScore
			  , trrm.EffectiveKempeScore
			  , trrm.HighestGrade
			  , trrm.PC1EducationAtIntake
			  , trrm.PC1EmploymentAtIntake
			  , trrm.PC1PrimaryLanguageAtIntake
			  , trrm.TCDOB
			  , trrm.PrenatalEnrollment
			  , trrm.AlcoholAbuseAtIntake
			  , trrm.SubstanceAbuseAtIntake
			  , trrm.DomesticViolenceAtIntake
			  , trrm.MentalIllnessAtIntake
			  , trrm.DepressionAtIntake
			  , trrm.PC1TANFAtIntake
			  , trrm.ConceptionDate
			from __Temp_Retention_Rates_Main trrm
			inner join CaseProgram cp on cp.PC1ID = trrm.PC1ID
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = trrm.HVCaseFK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where trrm.ProgramFK = @ProgramFK
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
		, RaceWhite
		, RaceBlack
		, RaceHispanic
		, RaceAsian
		, RaceNativeAmerican
		, RaceMultiracial
		, RaceOther
		, RaceUnknownMissing
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
		, Parity0
		, Parity1
		, Parity2
		, Parity3
		, Parity4
		, Parity5Plus)
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
		, case when left(RaceText,5) = 'White' then 1 else 0 end as RaceWhite
		, case when left(RaceText,5) = 'Black' then 1 else 0 end as RaceBlack
		, case when left(RaceText,8) = 'Hispanic' then 1 else 0 end as RaceHispanic
		, case when left(RaceText,5) = 'Asian' then 1 else 0 end as RaceAsian
		, case when left(RaceText,5) = 'Nativ' then 1 else 0 end as RaceNativeAmerican
		, case when left(RaceText,5) = 'Multi' then 1 else 0 end as RaceMultiracial
		, case when left(RaceText,5) = 'Other' then 1 else 0 end as RaceOther
		, case when RaceText is null or RaceText='' then 1 else 0 end as RaceUnknownMissing
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
		, case when left(LevelName,7) = 'Level 1' then 1 else 0 end as CurrentLevelAtDischarge1
		, case when left(LevelName,7) = 'Level 2' then 1 else 0 end as CurrentLevelAtDischarge2
		, case when left(LevelName,7) = 'Level 3' then 1 else 0 end as CurrentLevelAtDischarge3
		, case when left(LevelName,7) = 'Level 4' then 1 else 0 end as CurrentLevelAtDischarge4
		, case when left(LevelName,7) = 'Level X' then 1 else 0 end as CurrentLevelAtDischargeX
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
		, case when MaxParity = 0 then 1 else 0 end as Parity0
		, case when MaxParity = 1 then 1 else 0 end as Parity1
		, case when MaxParity = 2 then 1 else 0 end as Parity2
		, case when MaxParity = 3 then 1 else 0 end as Parity3
		, case when MaxParity = 4 then 1 else 0 end as Parity4
		, case when MaxParity >= 5 then 1 else 0 end as Parity5Plus
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
--		0
--		1
--		2
--		3
--		4
--		5+
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
values ('Demographic Factors'
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
where Parity0 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity0 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity0 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity0 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity0 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity0 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity0 = 1

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
values ('Demographic Factors'
		, '    0'
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
where Parity1 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity1 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity1 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity1 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity1 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity1 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity1 = 1

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
values ('Demographic Factors'
		, '    1'
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
where Parity2 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity2 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity2 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity2 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity2 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity2 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity2 = 1

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
values ('Demographic Factors'
		, '    2'
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
where Parity3 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity3 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity3 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity3 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity3 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity3 = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity3 = 1

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
values ('Demographic Factors'
		, '    3'
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
where Parity4 = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity4 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity4 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity4 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity4 = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity4 = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity4 = 1

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
values ('Demographic Factors'
		, '    4'
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
where Parity5Plus = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 0 and Parity5Plus = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and Parity5Plus = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1WithStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and Parity5Plus = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and Parity5Plus = 1
                                                        
select @TwentyFourMonthsAtIntake = count(*)             
from @tblPC1withStats                                   
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and Parity5Plus = 1
                                                        
select @ThirtySixMonthsAtIntake = count(*)              
from @tblPC1withStats                                   
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and Parity5Plus = 1

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
values ('Demographic Factors'
		, '    5+'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
values ('Demographic Factors'
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
--			White
--			Black
--			Hispanic
--			Asian
--			Native American
--			Multi-racial
--			Other
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
values ('Demographic Factors'
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
where RaceWhite = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceWhite = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceWhite = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceWhite = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceWhite = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceWhite = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceWhite = 1

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
values ('Demographic Factors'
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
where RaceBlack = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceBlack = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceBlack = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceBlack = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceBlack = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceBlack = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceBlack = 1

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
values ('Demographic Factors'
		, '    Black'
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
where RaceHispanic = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceHispanic = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceHispanic = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceHispanic = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceHispanic = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceHispanic = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceHispanic = 1

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
values ('Demographic Factors'
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
where RaceAsian = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceAsian = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceAsian = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceAsian = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceAsian = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceAsian = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceAsian = 1

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
values ('Demographic Factors'
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
where RaceNativeAmerican = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceNativeAmerican = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceNativeAmerican = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceNativeAmerican = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceNativeAmerican = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceNativeAmerican = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceNativeAmerican = 1

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
values ('Demographic Factors'
		, '    Native American'
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
where RaceMultiracial = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceMultiracial = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceMultiracial = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceMultiracial = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceMultiracial = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceMultiracial = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceMultiracial = 1

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
values ('Demographic Factors'
		, '    Multi-Racial'
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
where RaceOther = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceOther = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceOther = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceOther = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceOther = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceOther = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceOther = 1

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
values ('Demographic Factors'
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
where RaceUnknownMissing = 1

select @ThreeMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 0 and RaceUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt3Months = 1 and ActiveAt6Months = 0 and RaceUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceUnknownMissing = 1

select @ThirtySixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and ActiveAt36Months = 0 and RaceUnknownMissing = 1

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
values ('Demographic Factors'
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
		, 'More than 1 Home Visitor'
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
values ('Social Factors'
		, 'Kempe Score'
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
values ('Social Factors'
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
values ('Social Factors'
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
values ('Social Factors'
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
values ('Social Factors'
		, 'Whose Kempe Score Qualifies'
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
values ('Social Factors'
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
values ('Social Factors'
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
values ('Social Factors'
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
values ('Social Factors'
		, 'PC1 Current Issues'
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
values ('Social Factors'
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
values ('Social Factors'
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
values ('Social Factors'
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
