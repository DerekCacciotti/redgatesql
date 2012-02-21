SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- =============================================
CREATE PROCEDURE [dbo].[rspRetentionRatesByDischargeReason]
	-- Add the parameters for the stored procedure here
	@programfk INT, @startdate DATETIME, @enddate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--region declarations
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
		, SixMonthsDischarge int
		, OneYearDischarge int
		, EighteenMonthsDischarge int
		, TwoYearsDischarge int);
	
	declare @tblPC1withStats table (
		PC1ID char(12)
		, IntakeDate datetime
		, DischargeDate datetime
		, ReportDischargeText char(80)
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int);
	
--endregion
--region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
with cteCaseLastHomeVisit AS 
	 ------------------------
		(SELECT HVCaseFK,MAX(vl.VisitStartTime) AS LastHomeVisit,COUNT(vl.VisitStartTime) AS CountOfHomeVisits
			FROM HVLog vl
			INNER JOIN hvcase c ON c.HVCasePK=vl.HVCaseFK 
			WHERE (IntakeDate is not null and IntakeDate between @startdate and @enddate)
				and vl.ProgramFK=@programfk
			GROUP BY HVCaseFK), 
--endregion
--region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	cteMain as
	------------------------
		(select PC1ID
			   ,IntakeDate
			   ,LastHomeVisit
			   ,DischargeDate
			   ,cp.DischargeReason AS DischargeReasonCode
               ,cd.ReportDischargeText
			   ,case 
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 182.125 then 1 
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 182.125 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 365.25 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 365.25 then 1
					else 0
				end as ActiveAt12Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 547.375 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 547.375 then 1
					else 0
				end as ActiveAt18Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 730.50 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 730.50 then 1
					else 0
				end as ActiveAt24Months
		FROM HVCase c
		inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK=c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
		left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason
		where (IntakeDate is not null and IntakeDate between @startdate and @enddate)
			  and cp.ProgramFK=@programfk)
--endregion
--select *
--from cteDischargeData
--select *
--from cteMain
--order by PC1ID
--region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
select distinct pc1id
		, IntakeDate
		, DischargeDate
		, ReportDischargeText
		, LastHomeVisit
		, datediff(mm,IntakeDate,LastHomeVisit) as RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07','17','18')
order BY ReportDischargeText, PC1ID, IntakeDate
--endregion

DECLARE @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1withStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  FROM @tblPC1withStats

--region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int

declare @AllEnrolledParticipants int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @SixMonthsAtDischarge int
		, @TwelveMonthsAtDischarge int
		, @EighteenMonthsAtDischarge int
		, @TwentyFourMonthsAtDischarge int
--endregion
--region Retention Rate %
select @SixMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt6Months=1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt12Months=1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months=1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months=1

set @RetentionRateSixMonths = case when @TotalCohortCount=0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount=0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount=0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount=0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--endregion
--region Enrolled Participants
select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months=1 and DischargeDate between dateadd(day, 6*30.44, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1withStats
where ActiveAt12Months=1 and DischargeDate between dateadd(day, 12*30.44, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months=1 and DischargeDate between dateadd(day, 18*30.44, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months=1 and DischargeDate > dateadd(day, 24*30.44, IntakeDate)
--endregion
--region Running Total Discharged
select @RunningTotalDischargedSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months=1 and DischargeDate is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt12Months=1 and DischargeDate is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt18Months=1 and DischargeDate is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt24Months=1 and DischargeDate is not null
--endregion
--region Total (N) - (Discharged)
select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months=1 and ActiveAt12Months = 0 and DischargeDate is not null

select @TotalNOneYear = count(*)
from @tblPC1withStats
where ActiveAt12Months=1 and ActiveAt18Months = 0 and DischargeDate is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months=1 and ActiveAt24Months = 0 and DischargeDate is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months=1 and DischargeDate is not null
--endregion

select *
from @tblPC1withStats

--select *
--from @tblResults

END

GO
