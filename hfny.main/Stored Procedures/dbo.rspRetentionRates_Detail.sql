SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Derived from main storedproc for Retention Rate report - this is the details
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates_Detail 1, '20090501', '20110430'
-- exec rspRetentionRates_Detail 37, '20090401', '20110331'
-- exec rspRetentionRates_Detail 13, '20090401', '20110331'

-- exec rspRetentionRatesByDischargeReason 1, '03/01/10', '02/29/12'
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
CREATE procedure [dbo].[rspRetentionRates_Detail]
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
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, OneYearIntake int 
		, OneYearDischarge int
		, EighteenMonthsIntake int
		, EighteenMonthsDischarge int
		, TwoYearsIntake int
		, TwoYearsDischarge int);

	declare @tblPC1withStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int
		, AgeAtIntake_Under18 int
		, AgeAtIntake_18UpTo20 int
		, AgeAtIntake_20UpTo30 int
		, AgeAtIntake_Over30 int
		, RaceWhite int
		, RaceBlack int
		, RaceHispanic int
		, RaceOther int
		, RaceUnknownMissing int
		, MarriedAtIntake int
		, MarriedAtDischarge int
		, NeverMarriedAtIntake int
		, NeverMarriedAtDischarge int
		, SeparatedAtIntake int
		, SeparatedAtDischarge int
		, DivorcedAtIntake int
		, DivorcedAtDischarge int
		, WidowedAtIntake int
		, WidowedAtDischarge int
		, MarriedUnknownMissingAtIntake int
		, MarriedUnknownMissingAtDischarge int
		, OtherChildrenInHouseholdAtIntake int
		, OtherChildrenInHouseholdAtDischarge int
		, NoOtherChildrenInHouseholdAtIntake int
		, NoOtherChildrenInHouseholdAtDischarge int
		, ReceivingTANFAtIntake int
		, ReceivingTANFAtDischarge int
		, NotReceivingTANFAtIntake int
		, NotReceivingTANFAtDischarge int
		, MomScore int
		, DadScore int
		, PartnerScore int
		, PC1EducationAtIntakeLessThan12 int
		, PC1EducationAtDischargeLessThan12 int
		, PC1EducationAtIntakeHSGED int
		, PC1EducationAtDischargeHSGED int
		, PC1EducationAtIntakeMoreThan12 int
		, PC1EducationAtDischargeMoreThan12 int
		, PC1EducationAtIntakeUnknownMissing int
		, PC1EducationAtDischargeUnknownMissing int
		, PC1EducationalEnrollmentAtIntakeYes int
		, PC1EducationalEnrollmentAtDischargeYes int
		, PC1EducationalEnrollmentAtIntakeNo int
		, PC1EducationalEnrollmentAtDischargeNo int
		, PC1EducationalEnrollmentAtIntakeUnknownMissing int
		, PC1EducationalEnrollmentAtDischargeUnknownMissing int
		, PC1EmploymentAtIntakeYes int
		, PC1EmploymentAtDischargeYes int
		, PC1EmploymentAtIntakeNo int
		, PC1EmploymentAtDischargeNo int
		, PC1EmploymentAtIntakeUnknownMissing int
		, PC1EmploymentAtDischargeUnknownMissing int
		, OBPInHouseholdAtIntake int
		, OBPInHouseholdAtDischarge int
		, OBPEmploymentAtIntakeYes int
		, OBPEmploymentAtDischargeYes int
		, OBPEmploymentAtIntakeNo int
		, OBPEmploymentAtDischargeNo int
		, OBPEmploymentAtIntakeNoOBP int
		, OBPEmploymentAtDischargeNoOBP int
		, OBPEmploymentAtIntakeUnknownMissing int
		, OBPEmploymentAtDischargeUnknownMissing int
		, PC2InHouseholdAtIntake int
		, PC2InHouseholdAtDischarge int
		, PC2EmploymentAtIntakeYes int
		, PC2EmploymentAtDischargeYes int
		, PC2EmploymentAtIntakeNo int
		, PC2EmploymentAtDischargeNo int
		, PC2EmploymentAtIntakeNoPC2 int
		, PC2EmploymentAtDischargeNoPC2 int
		, PC2EmploymentAtIntakeUnknownMissing int
		, PC2EmploymentAtDischargeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtIntakeYes int
		, PC1OrPC2OrOBPEmployedAtDischargeYes int
		, PC1OrPC2OrOBPEmployedAtIntakeNo int
		, PC1OrPC2OrOBPEmployedAtDischargeNo int
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing int
		, CountOfHomeVisits int
		, DischargedOnLevelX int
		, PC1DVAtIntake int
		, PC1DVAtDischarge int
		, PC1MHAtIntake int
		, PC1MHAtDischarge int
		, PC1SAAtIntake int
		, PC1SAAtDischarge int
		, PC1PrimaryLanguageAtIntakeEnglish int
		, PC1PrimaryLanguageAtIntakeSpanish int
		, PC1PrimaryLanguageAtIntakeOtherUnknown int
		, TrimesterAtIntakePostnatal int
		, TrimesterAtIntake3rd int
		, TrimesterAtIntake2nd int
		, TrimesterAtIntake1st int
		, CountOfFSWs int);

--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	with cteMain as
	------------------------
		(select trrm.PC1ID
			  , trrm.HVCaseFK
			  , trrm.IntakeDate
			  , trrm.LastHomeVisit
			  , trrm.CountOfFSWs
			  , trrm.CountOfHomeVisits
			  , trrm.DischargeDate
			  , trrm.LevelName
			  , trrm.DischargeReasonCode
			  , trrm.DischargeReason
			  , trrm.PC1AgeAtIntake
			  , trrm.ActiveAt6Months
			  , trrm.ActiveAt12Months
			  , trrm.ActiveAt18Months
			  , trrm.ActiveAt24Months
			  , trrm.Race
			  , trrm.RaceText
			  , trrm.MaritalStatus
			  , trrm.MaritalStatusAtIntake
			  , trrm.MomScore
			  , trrm.DadScore
			  , trrm.PartnerScore
			  , trrm.HighestGrade
			  , trrm.PC1EducationAtIntake
			  , trrm.PC1EmploymentAtIntake
			  , trrm.EducationalEnrollmentAtIntake
			  , trrm.PC1PrimaryLanguageAtIntake
			  , trrm.TCDOB
			  , trrm.PrenatalEnrollment
			  , trrm.OtherChildrenInHouseholdAtIntake
			  , trrm.AlcoholAbuseAtIntake
			  , trrm.SubstanceAbuseAtIntake
			  , trrm.DomesticViolenceAtIntake
			  , trrm.MentalIllnessAtIntake
			  , trrm.DepressionAtIntake
			  , trrm.OBPInHomeAtIntake
			  , trrm.PC2InHomeAtIntake
			  , trrm.MaritalStatusAtDischarge
			  , trrm.PC1EducationAtDischarge
			  , trrm.PC1EmploymentAtDischarge
			  , trrm.EducationalEnrollmentAtDischarge
			  , trrm.OtherChildrenInHouseholdAtDischarge
			  , trrm.AlcoholAbuseAtDischarge
			  , trrm.SubstanceAbuseAtDischarge
			  , trrm.DomesticViolenceAtDischarge
			  , trrm.MentalIllnessAtDischarge
			  , trrm.DepressionAtDischarge
			  , trrm.OBPInHomeAtDischarge
			  , trrm.OBPEmploymentAtDischarge
			  , trrm.OBPEmploymentAtIntake
			  , trrm.PC2InHomeAtDischarge
			  , trrm.PC2EmploymentAtIntake
			  , trrm.PC2EmploymentAtDischarge
			  , trrm.PC1TANFAtDischarge
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

--#region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
		(PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, AgeAtIntake_Under18
		, AgeAtIntake_18UpTo20
		, AgeAtIntake_20UpTo30
		, AgeAtIntake_Over30
		, RaceWhite
		, RaceBlack
		, RaceHispanic
		, RaceOther
		, RaceUnknownMissing
		, MarriedAtIntake
		, MarriedAtDischarge
		, NeverMarriedAtIntake
		, NeverMarriedAtDischarge
		, SeparatedAtIntake
		, SeparatedAtDischarge
		, DivorcedAtIntake
		, DivorcedAtDischarge
		, WidowedAtIntake
		, WidowedAtDischarge
		, MarriedUnknownMissingAtIntake
		, MarriedUnknownMissingAtDischarge
		, OtherChildrenInHouseholdAtIntake
		, OtherChildrenInHouseholdAtDischarge
		, NoOtherChildrenInHouseholdAtIntake
		, NoOtherChildrenInHouseholdAtDischarge
		, ReceivingTANFAtIntake
		, ReceivingTANFAtDischarge
		, NotReceivingTANFAtIntake
		, NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, PC1EducationAtIntakeLessThan12
		, PC1EducationAtDischargeLessThan12
		, PC1EducationAtIntakeHSGED
		, PC1EducationAtDischargeHSGED
		, PC1EducationAtIntakeMoreThan12
		, PC1EducationAtDischargeMoreThan12
		, PC1EducationAtIntakeUnknownMissing
		, PC1EducationAtDischargeUnknownMissing
		, PC1EducationalEnrollmentAtIntakeYes
		, PC1EducationalEnrollmentAtDischargeYes
		, PC1EducationalEnrollmentAtIntakeNo
		, PC1EducationalEnrollmentAtDischargeNo
		, PC1EducationalEnrollmentAtIntakeUnknownMissing
		, PC1EducationalEnrollmentAtDischargeUnknownMissing
		, PC1EmploymentAtIntakeYes
		, PC1EmploymentAtDischargeYes
		, PC1EmploymentAtIntakeNo
		, PC1EmploymentAtDischargeNo
		, PC1EmploymentAtIntakeUnknownMissing
		, PC1EmploymentAtDischargeUnknownMissing
		, OBPInHouseholdAtIntake
		, OBPInHouseholdAtDischarge
		, OBPEmploymentAtIntakeYes
		, OBPEmploymentAtDischargeYes
		, OBPEmploymentAtIntakeNo
		, OBPEmploymentAtDischargeNo
		, OBPEmploymentAtIntakeNoOBP
		, OBPEmploymentAtDischargeNoOBP
		, OBPEmploymentAtIntakeUnknownMissing
		, OBPEmploymentAtDischargeUnknownMissing
		, PC2InHouseholdAtIntake
		, PC2InHouseholdAtDischarge
		, PC2EmploymentAtIntakeYes
		, PC2EmploymentAtDischargeYes
		, PC2EmploymentAtIntakeNo
		, PC2EmploymentAtDischargeNo
		, PC2EmploymentAtIntakeNoPC2
		, PC2EmploymentAtDischargeNoPC2
		, PC2EmploymentAtIntakeUnknownMissing
		, PC2EmploymentAtDischargeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtIntakeYes
		, PC1OrPC2OrOBPEmployedAtDischargeYes
		, PC1OrPC2OrOBPEmployedAtIntakeNo
		, PC1OrPC2OrOBPEmployedAtDischargeNo
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, DischargedOnLevelX
		, PC1DVAtIntake
		, PC1DVAtDischarge
		, PC1MHAtIntake
		, PC1MHAtDischarge
		, PC1SAAtIntake
		, PC1SAAtDischarge
		, PC1PrimaryLanguageAtIntakeEnglish
		, PC1PrimaryLanguageAtIntakeSpanish
		, PC1PrimaryLanguageAtIntakeOtherUnknown
		, TrimesterAtIntakePostnatal
		, TrimesterAtIntake3rd
		, TrimesterAtIntake2nd
		, TrimesterAtIntake1st
		, CountOfFSWs)
select distinct PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		,case when DischargeDate is not null then 
				datediff(mm,IntakeDate,LastHomeVisit)
			else
				datediff(mm,IntakeDate,current_timestamp)
			end as RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, case when PC1AgeAtIntake < 18 then 1 else 0 end as AgeAtIntake_Under18
		, case when PC1AgeAtIntake between 18 and 19 then 1 else 0 end as AgeAtIntake_18UpTo20
		, case when PC1AgeAtIntake between 20 and 29 then 1 else 0 end as AgeAtIntake_20UpTo30
		, case when PC1AgeAtIntake >= 30 then 1 else 0 end as AgeAtIntake_Over30
		, case when left(RaceText,5)='White' then 1 else 0 end as RaceWhite
		, case when left(RaceText,5)='Black' then 1 else 0 end as RaceBlack
		, case when left(RaceText,8)='Hispanic' then 1 else 0 end as RaceHispanic
		, case when left(RaceText,5) in('Asian','Nativ','Multi','Other') then 1 else 0 end as RaceOther
		, case when RaceText is null or RaceText='' then 1 else 0 end as RaceUnknownMissing
		, case when MaritalStatusAtIntake = 'Married' then 1 else 0 end as MarriedAtIntake
		, case when MaritalStatusAtDischarge = 'Married' then 1 else 0 end as MarriedAtDischarge
		, case when MaritalStatusAtIntake = 'Never married' then 1 else 0 end as NeverMarriedAtIntake
		, case when MaritalStatusAtDischarge = 'Never married' then 1 else 0 end as NeverMarriedAtDischarge
		, case when MaritalStatusAtIntake = 'Separated' then 1 else 0 end as SeparatedAtIntake
		, case when MaritalStatusAtDischarge = 'Separated' then 1 else 0 end as SeparatedAtDischarge
		, case when MaritalStatusAtIntake = 'Divorced' then 1 else 0 end as DivorcedAtIntake
		, case when MaritalStatusAtDischarge= 'Divorced' then 1 else 0 end as DivorcedAtDischarge
		, case when MaritalStatusAtIntake = 'Widowed' then 1 else 0 end as WidowedAtIntake
		, case when MaritalStatusAtDischarge = 'Widowed' then 1 else 0 end as WidowedAtDischarge
		, case when MaritalStatusAtIntake is null or MaritalStatusAtIntake='' or left(MaritalStatusAtIntake,7) = 'Unknown' then 1 else 0 end as MarriedUnknownMissingAtIntake
		, case when MaritalStatusAtDischarge is null or MaritalStatusAtDischarge='' or left(MaritalStatusAtDischarge,7) = 'Unknown' then 1 else 0 end as MarriedUnknownMissingAtDischarge
		, case when OtherChildrenInHouseholdAtIntake > 0 then 1 else 0 end as OtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge > 0 then 1 else 0 end as OtherChildrenInHouseholdAtDischarge
		, case when OtherChildrenInHouseholdAtIntake = 0 or OtherChildrenInHouseholdAtIntake is null then 1 else 0 end as NoOtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge = 0 or OtherChildrenInHouseholdAtDischarge is null then 1 else 0 end as NoOtherChildrenInHouseholdAtDischarge
		, case when PC1TANFAtIntake = 1 then 1 else 0 end as ReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 1 then 1 else 0 end as ReceivingTANFAtDischarge
		, case when PC1TANFAtIntake = 0 or PC1TANFAtIntake is null or PC1TANFAtIntake = '' then 1 else 0 end as NotReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 0 or PC1TANFAtDischarge is null or PC1TANFAtDischarge='' then 1 else 0 end as NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, case when PC1EducationAtIntake in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtIntakeLessThan12
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeLessThan12
		, case when PC1EducationAtIntake in ('High school grad','GED') then 1 else 0 end as PC1EducationAtIntakeHSGED
		, case when PC1EducationAtDischarge in ('High school grad','GED') then 1 else 0 end as PC1EducationAtDischargeHSGED
		, case when PC1EducationAtIntake in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtIntakeMoreThan12
		, case when PC1EducationAtDischarge in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtDischargeMoreThan12
		, case when PC1EducationAtIntake is null or PC1EducationAtIntake = '' then 1 else 0 end as PC1EducationAtIntakeUnknownMissing
		, case when PC1EducationAtDischarge is null or PC1EducationAtDischarge = '' then 1 else 0 end as PC1EducationAtDischargeUnknownMissing
		, case when EducationalEnrollmentAtIntake = '1' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeYes
		, case when EducationalEnrollmentAtDischarge = '1' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeYes
		, case when EducationalEnrollmentAtIntake = '0' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeNo
		, case when EducationalEnrollmentAtDischarge = '0' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeNo
		, case when EducationalEnrollmentAtIntake is null or EducationalEnrollmentAtIntake = '' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeUnknownMissing
		, case when EducationalEnrollmentAtDischarge is null or EducationalEnrollmentAtDischarge = '' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = '1' then 1 else 0 end as PC1EmploymentAtIntakeYes
		, case when PC1EmploymentAtDischarge = '1' then 1 else 0 end as PC1EmploymentAtDischargeYes
		, case when PC1EmploymentAtIntake = '0' then 1 else 0 end as PC1EmploymentAtIntakeNo
		, case when PC1EmploymentAtDischarge = '0' then 1 else 0 end as PC1EmploymentAtDischargeNo
		, case when PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '' then 1 else 0 end as PC1EmploymentAtIntakeUnknownMissing
		, case when PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '' then 1 else 0 end as PC1EmploymentAtDischargeUnknownMissing
		, case when OBPInHomeAtIntake = 1 then 1 else 0 end as OBPInHouseholdAtIntake
		, case when OBPInHomeAtDischarge = 1 then 1 else 0 end as OBPInHouseholdAtDischarge
		, case when OBPEmploymentAtIntake = 1 then 1 else 0 end as OBPEmploymentAtIntakeYes
		, case when OBPEmploymentAtDischarge = 1 then 1 else 0 end as OBPEmploymentAtDischargeYes
		, case when OBPEmploymentAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNo
		, case when OBPEmploymentAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNo
		, case when OBPInHomeAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNoOBP
		, case when OBPinHomeAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNoOBP
		, case when OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is null or OBPEmploymentAtIntake = '') then 1 else 0 end as OBPEmploymentAtIntakeUnknownMissing
		, case when OBPInHomeAtDischarge = 1 and (OBPEmploymentAtDischarge is null or OBPEmploymentAtDischarge = '') then 1 else 0 end as OBPEmploymentAtDischargeUnknownMissing
		, case when PC2InHomeAtIntake = 1 then 1 else 0 end as PC2InHouseholdAtIntake
		, case when PC2InHomeAtDischarge = 1 then 1 else 0 end as PC2InHouseholdAtDischarge
		, case when PC2EmploymentAtIntake = 1 then 1 else 0 end as PC2EmploymentAtIntakeYes
		, case when PC2EmploymentAtDischarge = 1 then 1 else 0 end as PC2EmploymentAtDischargeYes
		, case when PC2EmploymentAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNo
		, case when PC2EmploymentAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNo
		, case when PC2InHomeAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNoPC2
		, case when PC2inHomeAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNoPC2
		, case when PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '') then 1 else 0 end as PC2EmploymentAtIntakeUnknownMissing
		, case when PC2InHomeAtDischarge = 1 and (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = '') then 1 else 0 end as PC2EmploymentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = '1' or PC2EmploymentAtIntake = '1' or OBPEmploymentAtIntake = '1' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeYes
		, case when PC1EmploymentAtDischarge = '1' or PC2EmploymentAtDischarge = '1' or OBPEmploymentAtDischarge = '1' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeYes
		, case when PC1EmploymentAtIntake = '0' and PC2EmploymentAtIntake = '0' and OBPEmploymentAtIntake = '0' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeNo
		, case when PC1EmploymentAtDischarge = '0' and PC2EmploymentAtDischarge = '0' and OBPEmploymentAtDischarge = '0' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeNo
		, case when (PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '') 
					and (PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '')) 
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is NULL or OBPEmploymentAtIntake = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, case when (PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '') 
					and (PC2InHomeAtIntake = 1 and  (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = ''))
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtDischarge is NULL or OBPEmploymentAtDischarge = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, case when left(LevelName,7)='Level X' then 1 else 0 end as DischargedOnLevelX
		, case when DomesticViolenceAtIntake = 1 then 1 else 0 end as PC1DVAtIntake
		, case when DomesticViolenceAtDischarge = 1 then 1 else 0 end as PC1DVAtDischarge
		, case when MentalIllnessAtIntake = 1 or DepressionAtIntake = 1 then 1 else 0 end as PC1MHAtIntake
		, case when MentalIllnessAtDischarge = 1 or DepressionAtDischarge = 1 then 1 else 0 end as PC1MHAtDischarge
		, case when AlcoholAbuseAtIntake = 1 or SubstanceAbuseAtIntake = 1 then 1 else 0 end as PC1SAAtIntake
		, case when AlcoholAbuseAtDischarge = 1 or SubstanceAbuseAtDischarge = 1 then 1 else 0 end as PC1SAAtDischarge
		, case when PC1PrimaryLanguageAtIntake = '01' then 1 else 0 end as PC1PrimaryLanguageAtIntakeEnglish
		, case when PC1PrimaryLanguageAtIntake = '02' then 1 else 0 end as PC1PrimaryLanguageAtIntakeSpanish
		, case when PC1PrimaryLanguageAtIntake = '03' or PC1PrimaryLanguageAtIntake is null or PC1PrimaryLanguageAtIntake = '' then 1 else 0 end as PC1PrimaryLanguageAtIntakeOtherUnknown
		, case when IntakeDate>=TCDOB then 1 else 0 end as TrimesterAtIntakePostnatal
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) > round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake3rd
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) between round(30.44*3,0)+1 and round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake2nd
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) < 3*30.44  then 1 else 0 end as TrimesterAtIntake1st
		, CountOfFSWs
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37')
		-- (DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') or datediff(day,IntakeDate,DischargeDate)>=(4*6*30.44))
order by PC1ID,IntakeDate
--#endregion

select PC1ID
	 , IntakeDate
	 , DischargeDate
	 , LastHomeVisit
	 , RetentionMonths
	 , ActiveAt6Months
	 , ActiveAt12Months
	 , ActiveAt18Months
	 , ActiveAt24Months
	 , AgeAtIntake_Under18
	 , AgeAtIntake_18UpTo20
	 , AgeAtIntake_20UpTo30
	 , AgeAtIntake_Over30
	 , RaceWhite
	 , RaceBlack
	 , RaceHispanic
	 , RaceOther
	 , RaceUnknownMissing
	 , MarriedAtIntake
	 , MarriedAtDischarge
	 , NeverMarriedAtIntake
	 , NeverMarriedAtDischarge
	 , SeparatedAtIntake
	 , SeparatedAtDischarge
	 , DivorcedAtIntake
	 , DivorcedAtDischarge
	 , WidowedAtIntake
	 , WidowedAtDischarge
	 , MarriedUnknownMissingAtIntake
	 , MarriedUnknownMissingAtDischarge
	 , OtherChildrenInHouseholdAtIntake
	 , OtherChildrenInHouseholdAtDischarge
	 , NoOtherChildrenInHouseholdAtIntake
	 , NoOtherChildrenInHouseholdAtDischarge
	 , ReceivingTANFAtIntake
	 , ReceivingTANFAtDischarge
	 , NotReceivingTANFAtIntake
	 , NotReceivingTANFAtDischarge
	 , MomScore
	 , DadScore
	 , PartnerScore
	 , PC1EducationAtIntakeLessThan12
	 , PC1EducationAtDischargeLessThan12
	 , PC1EducationAtIntakeHSGED
	 , PC1EducationAtDischargeHSGED
	 , PC1EducationAtIntakeMoreThan12
	 , PC1EducationAtDischargeMoreThan12
	 , PC1EducationAtIntakeUnknownMissing
	 , PC1EducationAtDischargeUnknownMissing
	 , PC1EducationalEnrollmentAtIntakeYes
	 , PC1EducationalEnrollmentAtDischargeYes
	 , PC1EducationalEnrollmentAtIntakeNo
	 , PC1EducationalEnrollmentAtDischargeNo
	 , PC1EducationalEnrollmentAtIntakeUnknownMissing
	 , PC1EducationalEnrollmentAtDischargeUnknownMissing
	 , PC1EmploymentAtIntakeYes
	 , PC1EmploymentAtDischargeYes
	 , PC1EmploymentAtIntakeNo
	 , PC1EmploymentAtDischargeNo
	 , PC1EmploymentAtIntakeUnknownMissing
	 , PC1EmploymentAtDischargeUnknownMissing
	 , OBPInHouseholdAtIntake
	 , OBPInHouseholdAtDischarge
	 , OBPEmploymentAtIntakeYes
	 , OBPEmploymentAtDischargeYes
	 , OBPEmploymentAtIntakeNo
	 , OBPEmploymentAtDischargeNo
	 , OBPEmploymentAtIntakeNoOBP
	 , OBPEmploymentAtDischargeNoOBP
	 , OBPEmploymentAtIntakeUnknownMissing
	 , OBPEmploymentAtDischargeUnknownMissing
	 , PC2InHouseholdAtIntake
	 , PC2InHouseholdAtDischarge
	 , PC2EmploymentAtIntakeYes
	 , PC2EmploymentAtDischargeYes
	 , PC2EmploymentAtIntakeNo
	 , PC2EmploymentAtDischargeNo
	 , PC2EmploymentAtIntakeNoPC2
	 , PC2EmploymentAtDischargeNoPC2
	 , PC2EmploymentAtIntakeUnknownMissing
	 , PC2EmploymentAtDischargeUnknownMissing
	 , PC1OrPC2OrOBPEmployedAtIntakeYes
	 , PC1OrPC2OrOBPEmployedAtDischargeYes
	 , PC1OrPC2OrOBPEmployedAtIntakeNo
	 , PC1OrPC2OrOBPEmployedAtDischargeNo
	 , PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
	 , PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
	 , CountOfHomeVisits
	 , DischargedOnLevelX
	 , PC1DVAtIntake
	 , PC1DVAtDischarge
	 , PC1MHAtIntake
	 , PC1MHAtDischarge
	 , PC1SAAtIntake
	 , PC1SAAtDischarge
	 , PC1PrimaryLanguageAtIntakeEnglish
	 , PC1PrimaryLanguageAtIntakeSpanish
	 , PC1PrimaryLanguageAtIntakeOtherUnknown
	 , TrimesterAtIntakePostnatal
	 , TrimesterAtIntake3rd
	 , TrimesterAtIntake2nd
	 , TrimesterAtIntake1st
	 , CountOfFSWs
from @tblPC1withStats
-- order by HVCaseFK_old
order by PC1ID

end


GO
